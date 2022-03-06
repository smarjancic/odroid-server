FROM lsiobase/alpine:arm64v8-edge

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="smarjancic version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="smarjancic"

# Install packages
RUN \
 apk add --no-cache --upgrade \
         jq \
         curl

# Add local files
COPY root/ /

COPY root/scripts/cron_execute /etc/cron.d/cron_execute

# Apply cron job
RUN crontab /etc/cron.d/cron_execute

# Port and volumes
VOLUME /config
EXPOSE 80