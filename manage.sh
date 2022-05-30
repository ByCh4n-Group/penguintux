#!/bin/bash

# Configure the script.
set -e

# Define variables.
export status="true"

# Define functions.

get:discordsh() (
    local project="https://github.com/ChaoticWeg/discord.sh"
    local bin="${TOOL}/${project##*/}/discord.sh"
    local i="" status="true"

    for i in "git" "ln" "jq" "curl" ; do
        if ! command -v "${i}" &> /dev/null ; then
            echo "'${i}' not found..[-]"
            export status="false"
        fi
    done

    if [[ "${status}" = "false" ]] ; then
        echo "requirements could not be resolved, this is a fatal error."
        return 1
    fi

    if ! [[ -d "${TOOL}/${project##*/}" ]] ; then
        cd "${TOOL}"
        git clone "${project}" || return "$?"
        chmod +x "${bin}"
        ln -s "${bin}" "${BIN}" 
    fi
)

tmp:manager() {
    case "${1}" in
        --create|-c)
            mkdir -p "${TMP}"
        ;;
        --remove|-r)
            rm -rf "${TMP}"
        ;;
        *)
            if ! [[ -d "${TMP}" ]] ; then
                mkdir -p "${TMP}"
            elif [[ -d "${TMP}" ]] ; then
                rm -rf "${TMP}" && mkdir -p "${TMP}" || return 1
            fi
        ;;
    esac
}

# Check requirements.
for i in "auxiliaries" "conf.sh" "src" "src/submitproject.sh" ; do
    if ! [[ -e "${i}" ]] ; then
        echo "'${i}' not found..[-]"
        export status="false"
    fi
done

unset i

for i in "stat" ; do
    if ! command -v "${i}" &> /dev/null ; then
        echo "'${i}' not found..[-]"
        export status="false"
    fi
done

if [[ "${status}" = "false" ]] ; then
    echo "requirements could not be resolved, this is a fatal error."
    exit 1
fi

# Get additional configurations.
source "conf.sh"
export PATH="${PATH}:${BIN}"

# Update permissions.
for i in "${BIN}/submitproject.sh" ; do
    if ! [[ "$(stat -c "%a" "${i}")" -eq "755" ]] ; then
        chmod 755 "${i}"
    fi
done

# Parse arguments.
while [[ "${#}" -gt 0 ]] ; do
    case "${1}" in
        --subproject|-s)
            shift
            get:discordsh || exit "$?"
            submitproject.sh ${@}
            exit "$?"
        ;;
        --notification|-n)
            shift
            get:discordsh || exit "$?"
            discord.sh  --username "${servername} Notification" --avatar "${servericon}" ${@} --footer "${servername}" --footer-icon "${servericon}" --timestamp
            exit "$?"
        ;;
        --lockserver|-l)
            
        ;;
        *)
            echo "'${1}' unknown argument."
            shift
        ;;
    esac
done