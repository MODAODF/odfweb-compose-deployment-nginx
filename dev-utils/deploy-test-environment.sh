#!/usr/bin/env bash
# Deploy a test environment on a remote host via SSH
#
# Copyright 2025 Buo-ren Lin (OSSII) <buoren.lin@ossii.com.tw>
# SPDX-License-Identifier: AGPL-3.0-or-later

TEST_HOST="${TEST_HOST:-brlin-test.local}"
TEST_USER="${TEST_USER:-"${USER}"}"
TEST_PORT="${TEST_PORT:-22}"

if ! set -eu; then
    printf 'Error: Unable to set the required shell options.\n' 1>&2
fi

if ! trap 'printf "Error: An unhandled error occurred.\n" 1>&2' ERR; then
    printf 'Error: Unable to set the ERR trap.\n' 1>&2
fi

flag_required_command_check_failed=false
required_commands=(
    realpath
    rsync
    ssh
)
for command in "${required_commands[@]}"; do
    if ! command -v "$command" &> /dev/null; then
        printf \
            'Error: This program requires the "%s" command to be available in the command search PATHs.\n' \
            "${command}" \
            1>&2
        flag_required_command_check_failed=true
    fi
done
if test "${flag_required_command_check_failed}" = true; then
    printf 'Error: Please install the required command(s) and try again.\n' 1>&2
    exit 1
fi

script="${BASH_SOURCE[0]}"
if ! script="$(realpath "${script}")"; then
    printf 'Error: Unable to resolve the absolute path of the program.\n' 1>&2
    exit 1
fi
script_dir="${script%/*}"
script_filename="${script##*/}"
script_name="${script_filename%.*}"

product_dir="${script_dir%/*}"

rsync_opts=(
    --archive
    --exclude-from "${script_dir}/${script_name}.rsync-exclude"
    --verbose
    --human-readable
    --human-readable
    --delete
    --delete-excluded
    --delete-after
    --progress
)
if ! rsync "${rsync_opts[@]}" "${product_dir}" "${TEST_USER}@${TEST_HOST}:"; then
    printf 'Error: Unable to deploy the product files to the test host.\n' 1>&2
    exit 1
fi

printf 'Info: Operation completed successfully.\n'
