#!/usr/bin/env sh

fatal () {
    echo "$1"
    exit 1
}

[ -z "$SOURCE_GIT_REPO" ] && fatal "Missing SOURCE_GIT_REPO value"

if [ ! -f /data/id_rsa -a ! -f /data/id_rsa.pub ]; then
    echo "> Generating new SSH deployment key..."
    mkdir /data
    echo -e "\n" | ssh-keygen -f /data/id_rsa -t rsa -N '' &> /dev/null
fi

printf "> Deploy key:\r\n\r\n"
cat /data/id_rsa.pub
printf "\r\n\r\n"

exec "$@"
