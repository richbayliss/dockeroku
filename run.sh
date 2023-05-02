#!/usr/bin/env bash

SOURCE="/data/source"
BRANCH="${SOURCE_GIT_BRANCH:-master}"
INTERVAL=${SOURCE_UPDATE_INT:-5}

checkout () {
    echo "> Checking out source..."
    touch /data/.commit
    if [ ! -d "$SOURCE/.git" ]; then
        echo "> Cloning source..."
        git clone --config core.sshCommand="ssh -o StrictHostKeyChecking=accept-new -i /data/id_rsa" "$SOURCE_GIT_REPO" "$SOURCE"
    fi
}

store_current_commit () {
    touch /data/.commit
    echo "$1" > /data/.commit
}

current_commit () {
    cat /data/.commit
}

get_branch () {
    echo "> Checking for updates..."

    cd "$SOURCE"
    git fetch &> /dev/null
    REF="$(git show-ref | grep "refs/remotes/origin/$BRANCH" | cut -d' ' -f 1)"

    if [ -z "$REF" ]; then
        echo "> Branch not found: $BRANCH"
        return 1
    fi

    echo "> Currently on commit ${REF}..."
    store_current_commit "$REF"
    git pull
}

wait_for_next_check () {
    NEXT_CHECK_AT=$(( SECONDS + $INTERVAL ))
    echo "> Sleeping until ${NEXT_CHECK_AT}..."
    while (( SECONDS < NEXT_CHECK_AT )); do
        sleep 1
    done
}

apply_compose () {
    cd "$SOURCE"
    docker-compose -f "$SOURCE_COMPOSE_FILE" build
    docker-compose -f "$SOURCE_COMPOSE_FILE" up -d
}

checkout

while true; do
    COMMIT="$(current_commit)"
    echo "> Current: $COMMIT"

    get_branch

    if [ "$COMMIT" != "$(current_commit)" ]; then
        echo "> Applying compose file: $SOURCE_COMPOSE_FILE"
        apply_compose
    fi

    wait_for_next_check
done