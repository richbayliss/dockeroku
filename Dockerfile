FROM docker

RUN apk add bash git

ADD initialise.sh /init
ADD run.sh /usr/bin/run

ENV SOURCE_GIT_REPO=
ENV SOURCE_GIT_BRANCH=master
ENV SOURCE_GIT_KEY=
ENV SOURCE_COMPOSE_FILE=docker-compose.yaml
ENV SOURCE_UPDATE_INT=60

ENTRYPOINT [ "/init" ]
CMD [ "/usr/bin/run" ]
