FROM steamcmd/steamcmd:ubuntu-22

USER root

RUN apt -y update
RUN apt -y install vim libcurl4
RUN rm -rf /var/lib/apt/lists/*
RUN mkdir -p /kf2-server/scripts
RUN mkdir -p /kf2-server/steam-server

WORKDIR /kf2-server

ADD functions.sh scripts/functions.sh
ADD run-kf2-server scripts/run-kf2-server

RUN chmod +x scripts/run-kf2-server

ENTRYPOINT ["scripts/run-kf2-server"]
