FROM steamcmd/steamcmd:latest

RUN apt -y update
RUN apt -y install wget vim libcurl4
RUN mkdir /scripts

USER root

ADD functions.sh scripts/functions.sh
ADD run-kf2-server scripts/run-kf2-server

RUN chmod +x scripts/functions.sh
RUN chmod +x scripts/run-kf2-server

ENTRYPOINT ["scripts/run-kf2-server"]
