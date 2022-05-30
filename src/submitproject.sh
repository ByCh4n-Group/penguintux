#!/bin/bash

# Define variables.
export status="true"

# Define functions.
github:parse:project() {
    # Şimdilik github projeleri için otomasyon yeterli olacaktır ilerleyen zamanlarda diğer
    # versiyon yönetim sistemleri de eklenebilir.
    if git ls-remote "${1}" &> /dev/null ; then
        {
            export maintainer="${1#*//*/}"
            export maintainer="${maintainer%%/*}"
            export repository="${1/.git/}"
            export repository="${repository##*/}"
            export branch="$(git remote show "https://github.com/${maintainer}/${repository}" | sed -n '/HEAD branch/s/.*: //p')"
            export version="$(curl -s "https://github.com/${maintainer}/${repository}/releases" | grep "/${maintainer}/${repository}/tree" | sed "s/<a href=\"\/${maintainer}\/${repository}\/tree\///g;s/\" data-view-component=\"true\" class=\"Link--muted\">//g" | xargs | awk '{print $1}')"
            export about="$(curl -s "https://github.com/${maintainer}/${repository}" | grep "<title>" | sed "s/<title>GitHub - ${maintainer}\/${repository}://g;s/<\/title>//g" | xargs)"
            export languages="$(curl -s "https://github.com/${maintainer}/${repository}" | grep '<span class="color-fg-default text-bold mr-1">' | sed 's/<span class="color-fg-default text-bold mr-1">//g;s/<\/span>//g' | xargs)"
            export license="$(curl -s https://github.com/${maintainer}/${repository}/blob/${branch}/LICENSE | grep '<h3 class="mt-0 mb-2 h4">' | sed "s/<h3 class=\"mt-0 mb-2 h4\">//g;s/<\/h3>//g" | xargs)"
            export opengraph="$(curl -s https://github.com/${maintainer}/${repository} | grep '<meta property="og:image" content="https://opengraph.githubassets.com/' | sed 's/<meta property="og:image" content="//g' | awk '{print $1}' | tr -d '"')"
            export avatar="https://avatars.githubusercontent.com/${maintainer}"
        } 2> /dev/null
    else
        echo "GitHub: '${1}' doesn't exist."
        return 1
    fi
}

# Check dependencies.
for i in "discord.sh" "curl" "xargs" "sed" "grep" "awk" "git" ; do
    if ! command -v "${i}" &> /dev/null ; then
        echo "'${i}' not found..[-]"
        export status="false"
    fi
done

if [[ "${status}" = "false" ]] ; then
    echo "requirements could not be resolved, this is a fatal error."
    exit 1
fi

# Parse arguments.
while [[ "${#}" -gt 0 ]] ; do
    case "${1}" in
        --token|-t)
            shift
            export token="${1}"
            shift
        ;;
        --repo|-r)
            shift
            export repo="${1}"
            export platform="${repo#*//}"
            export platform="${platform%%/*}"
            shift
        ;;
        *)
            shift
        ;;
    esac
done

# Check arguments.
if ! [[ -n "${repo}" ]] ; then
    echo "pelase type repository adress."
    exit 1
fi

# Execution&Result.
case "${platform}" in
    github.com)
        github:parse:project "${repo}" || exit "$?"
        if [[ -n "${token}" ]] ; then
            discord.sh --webhook-url="${token}" --username "GitHub" --color "0x000000" --title "${repository}" --url "https://github.com/${maintainer}/${repository}" --author "${maintainer}" --author-url "https://github.com/${maintainer}" --author-icon "${avatar}" --avatar "https://github.githubassets.com/images/modules/logos_page/GitHub-Mark.png" --description "${about}" --field "Language(s);${languages}" --field "License;${license}" --thumbnail "https://cdn.dribbble.com/users/420183/screenshots/2875637/octocat_github.gif" --image "${opengraph}" --footer "${servername}" --footer-icon "${servericon}" --timestamp
        else
            echo -e "maintainer: ${maintainer}\nrepository: ${repository}\nversion: ${version}\nabout: ${about}\nlanguage(s): ${languages}\nlicense: ${license}\naddress: ${repo}"
        fi
    ;;
esac

# Son derece kolay bir kullanımı vardır
# submitproject.sh --repo <depo linki> --token <discord webhook tokeni>
# bu sürümde sadece github'a destek verilmektedir ileriki sürümlerde diğer
# version yönetim sistemleri de eklenebilir.