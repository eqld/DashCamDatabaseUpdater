#!/usr/bin/env bash

# This script is valid for MacOS X only due to hardcoded paths to the utilities and the mounted volume,
# and due to the usage of `osascript` utility.

URI="https://trend-vision.ru/media/files/simple/productfile/FULL_Base.rar"
FILENAME_ARCHIVE="FULL_Base.rar"
FILENAME_PATTERN_DATABASE="data_*.bin"
DIR_EXTERNAL="/Volumes/TrendVision"

# `launchd` does not know about user defined custom `PATH`s
DIR_UTILITIES="/usr/local/homebrew/bin"
U_WGET="${DIR_UTILITIES}/wget"
U_UNRAR="${DIR_UTILITIES}/unrar"

function main {
    if check; then update; fi
}

function update {
    if ! cd "${DIR_EXTERNAL}"; then
        fatal "fail to change working directory to '${DIR_EXTERNAL}'"
    fi

    if [ ! -f "${U_WGET}" ]; then
        fatal "`wget` utility not found at '${U_WGET}'"
    fi

    if [ ! -f "${U_UNRAR}" ]; then
        fatal "`unrar` utility not found at '${U_UNRAR}'"
    fi

    # get rid of annoying 'wget' warning "Failed to set locale category ..."
    export LC_ALL=en_US.UTF-8

    if ! ${U_WGET} -q "${URI}" -O "${FILENAME_ARCHIVE}"; then
        fatal "fail to download new archived database from '${URI}' and write it to '${FILENAME_ARCHIVE}'"
    fi

    if ! ${U_UNRAR} e -u -y -inul "${FILENAME_ARCHIVE}"; then
        fatal "fail to unpack archived database '${FILENAME_ARCHIVE}'"
    fi

    if ! rm "${FILENAME_ARCHIVE}"; then
        fatal "fail to remove archived database '${FILENAME_ARCHIVE}'"
    fi

    osascript -e 'display dialog "TrendVision: speed cam database has been saved"'
}

function check {
    if [ ! -d "${DIR_EXTERNAL}" ]; then
        # external SD card is not mounted
        return 1
    fi

    # wait for external SD card to be fully mounted in case of early detection of newly created directory
    # just after inserting the card
    sleep 3

    if compgen -G "${DIR_EXTERNAL}/${FILENAME_PATTERN_DATABASE}" >/dev/null; then
        # database file already exists in SD card (it is auro-removed by dash cam after successfull upgrading)
        return 1
    fi

    return 0
}

function fatal {
    local message="[$(date)] [FATAL ERROR] [${FUNCNAME[1]}] ${@:1}"
    echo "${message}" >&2
    osascript -e "display dialog \"${message}\""
    exit 1
}

main "$@"
