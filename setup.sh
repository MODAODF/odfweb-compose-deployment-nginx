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
        else
            if ! is_valid_domain_name "${odfweb_host}"; then
                printf \
                    'Error: The specified domain name "%s" is invalid.\n' \
                    "${odfweb_host}" \
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

    config_templates=(
        "${script_dir}/app.env.in"
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
        'Info: Operation completed without errors.\n'
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
        'Error: The program has encountered an unhandled error and is prematurely aborted.\n' \
        1>&2
}
if ! trap trap_err ERR; then
    printf \
        'Error: Unable to set the ERR trap.\n' \
        1>&2
    exit 1
fi

init
