#!/usr/bin/env bash
# Setup product environment to a runnnable state
#
# Copyright 2025 Buo-ren Lin (OSSII) <buoren@ossii.com.tw>
# SPDX-License-Identifier: AGPL-3.0-or-later

init(){
    operation_timestamp="$(printf '%(%Y%m%d-%H%M%S)T\n')"

    printf \
        'Info: Please answer the following questions to setup the product environment.\n'
    while true; do
        printf \
            'Info: What is the host/domain name of the ODFWEB service [odfweb.example.com]? '
        if ! read -r odfweb_host; then
            printf \
                'Error: Unable to read the host/domain name of the ODFWEB service.\n' \
                1>&2
            continue
        fi

        # Check if the input is empty
        if test -z "${odfweb_host}"; then
            printf \
                'Info: Using the default value "odfweb.example.com" for the host/domain name of the ODFWEB service.\n'
            odfweb_host="odfweb.example.com"
            break
        fi

        if is_ip_address "${odfweb_host}"; then
            if ! is_valid_ip_address "${odfweb_host}"; then
                printf \
                    'Error: The specified IP address "%s" is invalid.\n' \
                    "${odfweb_host}" \
                    1>&2
                continue
            fi

            if [[ "${odfweb_host}" =~ ^127\. ]]; then
                printf \
                    'Error: Loopback address "%s" is NOT supported, please use a physical network address.\n' \
                    "${odfweb_host}" \
                    1>&2
                continue
            fi
        else
            if ! is_valid_domain_name "${odfweb_host}"; then
                printf \
                    'Error: The specified domain name "%s" is invalid.\n' \
                    "${odfweb_host}" \
                    1>&2
                continue
            fi

            if ! odfweb_domain_resolved_raw="$(getent hosts "${odfweb_host}")"; then
                printf \
                    'Error: The specified domain name "%s" is not resolvable.\n' \
                    "${odfweb_host}" \
                    1>&2
                continue
            fi

            if ! odfweb_domain_resolved_ip="$(echo "${odfweb_domain_resolved_raw}" | awk '{print $1}')"; then
                printf \
                    'Error: Unable to parse out the resolved IP address of the "%s" domain name.\n' \
                    "${odfweb_host}" \
                    1>&2
                continue
            fi

            if [[ "${odfweb_domain_resolved_ip}" =~ ^127\. ]] || test "${odfweb_domain_resolved_ip}" == "::1"; then
                printf \
                    'Error: Loopback address "%s" is NOT supported, please use a physical network address.\n' \
                    "${odfweb_domain_resolved_ip}" \
                    1>&2
                continue
            fi
        fi

        # Input is valid, next question
        break
    done

    while true; do
        printf \
            'Info: What is the port number of the ODFWEB service over HTTPS [443]? '
        if ! read -r odfweb_port_https; then
            printf \
                'Error: Unable to read the port number of the ODFWEB service over HTTPS.\n' \
                1>&2
            continue
        fi

        # Check if the input is empty
        if test -z "${odfweb_port_https}"; then
            printf \
                'Info: Using the default value "443" for the port number of the ODFWEB service over HTTPS.\n'
            odfweb_port_https=443
            break
        fi

        # Check if the input is a valid port number
        if [[ "${odfweb_port_https}" =~ ^[0-9]+$ && ! ("${odfweb_port_https}" -ge 1 && "${odfweb_port_https}" -le 65535) ]]; then
            printf \
                'Error: The port number of the ODFWEB service is invalid.\n' \
                1>&2
            continue
        fi
        break
    done

    db_environment_file="${script_dir}/db.env"
    if ! test -e "${db_environment_file}"; then
        while true; do
            printf \
                'Info: What is the password of the "root" MariaDB adminstrative account [_randomly generated_]? '
            if ! read -rs mariadb_root_password; then
                # NOTE: In silent mode the user-inputted newline won't be printed
                printf \
                    '\nError: Unable to read the password of the "root" MariaDB adminstrative account from the user.\n' \
                    1>&2
                continue
            fi

            if test -z "${mariadb_root_password}"; then
                if ! mariadb_root_password="$(print_random)"; then
                    printf \
                        '\nError: Unable to generate a random password for the "root" MariaDB adminstrative account.\n' \
                        1>&2
                    exit 2
                fi
                printf \
                    '\nInfo: Using the randomly generated password "%s" for the "root" MariaDB adminstrative account.\n' \
                    "${mariadb_root_password}"
                break
            fi
            printf '\n'
            break
        done

        while true; do
            printf \
                'Info: What is the password of the ODFWEB MariaDB service account(odfweb) [_randomly generated_]? '
            if ! read -rs mariadb_password; then
                # NOTE: In silent mode the user-inputted newline won't be printed
                printf \
                    '\nError: Unable to read the password of the ODFWEB MariaDB service account(odfweb) from the user.\n' \
                    1>&2
                continue
            fi

            if test -z "${mariadb_password}"; then
                if ! mariadb_password="$(print_random)"; then
                    printf \
                        '\nError: Unable to generate a random password for the ODFWEB MariaDB service account(odfweb).\n' \
                        1>&2
                    exit 2
                fi
                printf \
                    '\nInfo: Using the randomly generated password "%s" for the ODFWEB MariaDB service account(odfweb).\n' \
                    "${mariadb_password}"
                break
            fi
            break
        done
    else
        flag_db_env_load_failed=false
        printf \
            'Info: Existing database environment file "%s" detected, using the existing values...\n' \
            "${db_environment_file}"
        if ! mariadb_root_password="$(awk -F= '/^MYSQL_ROOT_PASSWORD=/ {print $2}' "${db_environment_file}")"; then
            printf \
                'Error: Unable to parse out the "root" MariaDB adminstrative account password from the database environment file "%s".\n' \
                "${db_environment_file}" \
                1>&2
            flag_db_env_load_failed=true
        fi

        if ! mariadb_password="$(awk -F= '/^MYSQL_PASSWORD=/ {print $2}' "${db_environment_file}")"; then
            printf \
                'Error: Unable to parse out the ODFWEB MariaDB service account(odfweb) password from the database environment file "%s".\n' \
                "${db_environment_file}" \
                1>&2
            flag_db_env_load_failed=true
        fi

        if test "${flag_db_env_load_failed}" == true; then
            printf \
                'Error: Unable to load existing settings from the database environment file "%s".\n' \
                "${db_environment_file}" \
                1>&2
            exit 2
        fi
    fi

    app_environment_file="${script_dir}/app.env"
    if ! test -e "${app_environment_file}"; then
        while true; do
            printf \
                'Info: What is the password of the ODFWEB admin account [_randomly_generated_]? '
            if ! read -rs odfweb_admin_password; then
                # NOTE: In silent mode the user-inputted newline won't be printed
                printf \
                    '\nError: Unable to read the password of the ODFWEB admin account from the user.\n' \
                    1>&2
                continue
            fi

            # Check if the input is empty
            if test -z "${odfweb_admin_password}"; then
                odfweb_admin_password="$(generate_word_passphrase 4)"
                printf \
                    '\nInfo: Using "%s" as the password of the ODFWEB admin account.\n' \
                    "${odfweb_admin_password}"
                break
            fi
            break
        done
    else
        printf \
            'Info: Existing app environment file "%s" detected, using the existing values...\n' \
            "${app_environment_file}"
        if ! odfweb_admin_password="$(awk -F= '/^ODFWEB_ADMIN_PASSWORD=/ {print $2}' "${app_environment_file}")"; then
            printf \
                'Error: Unable to parse out the ODFWEB admin account password from the app environment file "%s".\n' \
                "${app_environment_file}" \
                1>&2
            exit 2
        fi
    fi

    config_templates=(
        "${script_dir}/app.env.in"
        "${script_dir}/app-hooks/post-installation/initialize-richdocuments-app.sh.in"
        "${script_dir}/db.env.in"
        "${script_dir}/docker-compose.yml.in"
        "${script_dir}/nginx.conf.d/odfweb.conf.in"
        "${script_dir}/modaodfweb-config/modaodfweb.xml.in"
        "${script_dir}/ssl/odfweb.openssl.cnf.in"
    )
    for template in "${config_templates[@]}"; do
        printf \
            'Info: Generating the configuration file "%s" from the template "%s"...\n' \
            "${template%.in}" \
            "${template}"
        config_file="${template%.in}"

        # Check if the config file exists
        if test -e "${config_file}"; then
            backup_file="${config_file}.backup-${operation_timestamp}"
            printf \
                'Info: Backing up the existing configuration file "%s" to "%s"...\n' \
                "${config_file}" \
                "${backup_file}"
            if ! cp -a "${config_file}" "${backup_file}"; then
                printf \
                    'Error: Unable to backup the existing configuration file "%s" to "%s".\n' \
                    "${config_file}" \
                    "${backup_file}" \
                    1>&2
                exit 2
            fi
        fi

        sed_opts=(
            -e "s|__ODFWEB_DOMAIN_NAME__|${odfweb_host}|g"
            -e "s|__ODFWEB_PORT_HTTPS__|${odfweb_port_https}|g"
            -e "s|__MYSQL_ROOT_PASSWORD__|${mariadb_root_password}|g"
            -e "s|__MYSQL_PASSWORD__|${mariadb_password}|g"
            -e "s|__ODFWEB_ADMIN_PASSWORD__|${odfweb_admin_password}|g"
        )
        if ! sed "${sed_opts[@]}" "${template}" > "${config_file}"; then
            printf \
                'Error: Unable to generate the configuration file "%s" from the template "%s".\n' \
                "${config_file}" \
                "${template}" \
                1>&2
            exit 2
        fi
    done

    printf \
        'Info: Setting execution permission for the post-installation hook...\n'
    for hook in "${script_dir}/app-hooks/post-installation/"*.sh; do
        if ! chmod +x "${hook}"; then
            printf \
                'Error: Unable to set execution permission for the post-installation hook "%s".\n' \
                "${hook}" \
                1>&2
            exit 2
        fi
    done

    tls_cert="${script_dir}/ssl/${odfweb_host}.crt"
    tls_key="${script_dir}/ssl/${odfweb_host}.key"
    if ! test -e "${tls_cert}" \
        || ! test -e "${tls_key}"; then
        while true; do
            printf \
                'Info: TLS certificate and/or key not detected, do you want me to generate a self-signed one for you [Y/n]? '
            if ! read -r yn; then
                printf \
                    'Error: Unable to read the answer from the user.\n' \
                    1>&2
                continue
            fi

            regex_yes_no='^[yYnN]?$'
            if ! [[ "${yn}" =~ ${regex_yes_no} ]]; then
                printf \
                    'Error: The answer must be "y" or "n" or absent.\n' \
                    1>&2
                continue
            fi

            # Convert to lowercase
            yn="${yn,,}"

            if test -z "${yn}" \
                || test "${yn}" == y; then
                printf \
                    'Info: Generating self-signed certificate for "%s"...\n' \
                    "${odfweb_host}"
                if ! openssl req \
                    -config "${script_dir}/ssl/odfweb.openssl.cnf" \
                    -x509 \
                    -nodes \
                    -days 30 \
                    -newkey rsa:2048 \
                    -keyout "${tls_key}" \
                    -out "${tls_cert}" \
                    -utf8; then
                    printf \
                        'Error: Unable to generate self-signed certificate for "%s".\n' \
                        "${odfweb_host}" \
                        1>&2
                    exit 2
                fi
                break
            else
                printf \
                    'Error: The TLS certificate and/or key are not detected, please generate them manually before running this program.\n' \
                    1>&2
                exit 2
            fi
        done
    fi

    printf \
        'Info: Operation completed, you may now start the service by running the "docker compose up" command.\n'
    printf \
        'Info: Your ODFWEB service will be run at this address: https://%s\n' \
        "${odfweb_host}"
    printf \
        'Info: Your ODFWEB admin account: admin\n'
    printf \
        'Info: Your ODFWEB admin password: %s\n' \
        "${odfweb_admin_password}"
    printf \
        'Info: Please change the password in the user settings web UI.\n'
}

generate_word_passphrase() {
    local word_num="${1}"; shift
    local wordlist="/usr/share/dict/words"

    local regex_positive_integer='^[1-9][0-9]*$'
    if ! [[ "${word_num}" =~ ${regex_positive_integer} ]]; then
        printf 'Error (generate_word_passphrase): Number of words must be a positive integer, got "%s".\\n' "${word_num}" 1>&2
        return 1
    fi

    local -a words=()
    local -i i=0
    local word_draw
    local regex_desired_word='^[[:alpha:]]+$'
    while (( i < word_num )); do
        word_draw="$(shuf -n 1 "${wordlist}")"

        # Lowercase the word
        word_draw="${word_draw,,}"

        if ! [[ "${word_draw}" =~ ${regex_desired_word} ]]; then
            # Skip the word if it contains undesired characters
            continue
        fi

        words+=("${word_draw}")
        (( i++ ))
    done

    printf '%s\n' "${words[*]}"
    return 0
}

print_random () {
    local -a tr_opts=(
        --delete
        --complement
    )
    if ! LC_ALL=C.UTF-8 \
        tr "${tr_opts[@]}" \
            'A-Za-z0-9!#%&()*+,-./:;<=>?@[\]^_{}~' \
            </dev/urandom \
            | head -c 16; then
        printf \
            'Error: Unable to generate a random string.\n' \
            1>&2
        return 1
    fi
}

is_ip_address() {
    local input="$1"
    if [[ "$input" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        return 0
    fi
    return 1
}

is_valid_ip_address() {
    local ip="${1}"
    local IFS='.'
    read -ra ip_address_segments <<< "${ip}"

    if test ${#ip_address_segments[@]} -ne 4; then
        return 1
    fi

    for segment in "${ip_address_segments[@]}"; do
        if ! [[ "${segment}" =~ ^[0-9]+$ ]]; then
            return 1
        fi

        if test "${segment}" -lt 0 || test "${segment}" -gt 255; then
            return 1
        fi

        if test ${#segment} -gt 1 && test "${segment:0:1}" = "0"; then
            return 1
        fi
    done

    return 0
}

is_valid_domain_name() {
    local domain_name="$1"

    if [ "${#domain_name}" -gt 253 ]; then
        return 1
    fi

    local ascii_domain
    if ! ascii_domain="$(idn --quiet --allow-unassigned --no-tld -a "${domain_name}" 2>/dev/null)"; then
        return 1
    fi

    if ! [[ "${ascii_domain}" =~ ^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?)*$ ]]; then
        return 1
    fi

    IFS='.' read -ra labels <<< "${ascii_domain}"
    for label in "${labels[@]}"; do
        if [ "${#label}" -gt 63 ]; then
            return 1
        fi
    done

    return 0
}

printf \
    'Info: Configuring the defensive interpreter behaviors...\n'
set_opts=(
    # Terminate script execution when an unhandled error occurs
    -o errexit
    -o errtrace

    # Terminate script execution when an unset parameter variable is
    # referenced
    -o nounset
)
if ! set "${set_opts[@]}"; then
    printf \
        'Error: Unable to configure the defensive interpreter behaviors.\n' \
        1>&2
    exit 1
fi

printf \
    'Info: Checking the existence of the required commands...\n'
required_commands=(
    # For parsing the output of the "getent" command
    # For parsing out the existing values from the configuration files
    awk

    # For resolving hostnames to IP addresses
    getent

    # For generating random passwords
    head
    paste
    shuf
    tr

    # For checking international domain names
    idn

    realpath

    # For generating configuration files from templates
    sed
)
flag_required_command_check_failed=false
for command in "${required_commands[@]}"; do
    if ! command -v "${command}" >/dev/null; then
        flag_required_command_check_failed=true
        printf \
            'Error: This program requires the "%s" command to be available in your command search PATHs.\n' \
            "${command}" \
            1>&2
    fi
done
if test "${flag_required_command_check_failed}" == true; then
    printf \
        'Error: Required command check failed, please check your installation.\n' \
        1>&2
    exit 1
fi

if ! test -e /usr/share/dict/words; then
    printf \
        'Error: The wordlist file "/usr/share/dict/words" is not found, please install the "wamerican" package.\n' \
        1>&2
    exit 1
fi

printf \
    'Info: Configuring the convenience variables...\n'
if test -v BASH_SOURCE; then
    # Convenience variables may not need to be referenced
    # shellcheck disable=SC2034
    {
        printf \
            'Info: Determining the absolute path of the program...\n'
        if ! script="$(
            realpath \
                --strip \
                "${BASH_SOURCE[0]}"
            )"; then
            printf \
                'Error: Unable to determine the absolute path of the program.\n' \
                1>&2
            exit 1
        fi
        script_dir="${script%/*}"
        script_filename="${script##*/}"
        script_name="${script_filename%%.*}"
    }
fi
# Convenience variables may not need to be referenced
# shellcheck disable=SC2034
{
    script_basecommand="${0}"
    script_args=("${@}")
}

printf \
    'Info: Setting the ERR trap...\n'
trap_err(){
    printf \
        '\nError: The program has encountered an unhandled error and is prematurely aborted.\n' \
        1>&2
}
if ! trap trap_err ERR; then
    printf \
        'Error: Unable to set the ERR trap.\n' \
        1>&2
    exit 1
fi

init
