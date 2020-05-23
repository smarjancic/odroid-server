FROM lsiobase/alpine:arm32v7-3.11

COPY qemu-arm-static /usr/bin

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="smarjancic version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="smarjancic"

# Install packages
RUN \
 apk add --no-cache --upgrade \
         jq \
         awake \
         python \
         curl 

# Add local files
COPY root/ /

COPY /scripts/cron_health_check /etc/cron.d/cron_health_check

RUN chmod +x /scripts/health_check.sh
RUN chmod +x /scripts/do_health_check.sh
RUN chmod +x /scripts/cron_health_check

# Apply cron job
RUN crontab /etc/cron.d/cron_health_check

# Port and volumes
VOLUME /config
EXPOSE 80

CMD ["cron", "-f"]