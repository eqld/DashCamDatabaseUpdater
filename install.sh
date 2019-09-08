#!/usr/bin/env bash

# This script is valid for MacOS X only due to usage of "LaunchAgents".

TARGET_DIR="${HOME}/bin"
TARGET_FILE="dashcam_database_update.sh"
PLACEHOLDER_PATH="{{path}}"

function main {
    local dir_root="$(dirname $0)"
    local file_script_source="${dir_root}/main.sh"
    local file_script_target="${TARGET_DIR}/${TARGET_FILE}"
    local file_launchagent_template_source="${dir_root}/dashcam_database_update.plist.template"
    local file_launchagent_target="${HOME}/Library/LaunchAgents/dashcam_database_update.plist"

    case "$1" in
    "-u")
        uninstall
        ;;
    *)
        install
        ;;
    esac
}

function install {
    if ! mkdir -p "${TARGET_DIR}"; then
        fatal "fail to create target directory '${TARGET_DIR}'"
    fi

    # copy the script
    if ! cp "${file_script_source}" "${file_script_target}"; then
        fatal "fail to copy script from '${file_script_source}' to '${file_script_target}'"
    fi

    # create and write LaunchAgent file
    if ! cat "${file_launchagent_template_source}" | sed -e "s~${PLACEHOLDER_PATH}~${file_script_target}~g" > "${file_launchagent_target}"; then
        fatal "fail to create 'LaunchAgent' file '${file_launchagent_target}' from the template '${file_launchagent_template_source}'"
    fi

    if ! launchctl load -w "${file_launchagent_target}" 2>/dev/null; then
        fatal "fail to load 'LaunchAgent' '${file_launchagent_target}'"
    fi
}

function uninstall {
    if ! launchctl unload "${file_launchagent_target}"; then
        fatal "fail to unload 'LaunchAgent' '${file_launchagent_target}'"
    fi

    if ! rm "${file_launchagent_target}" "${file_script_target}"; then
        fatal "fail to delete installed files '${file_launchagent_target}' or '${file_script_target}'"
    fi
}

function fatal {
    echo "${@:1}" >&2
    exit 1
}

main "$@"
