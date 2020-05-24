FROM lsiobase/alpine:arm32v7-3.11

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="smarjancic version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="smarjancic"

# Install packages
RUN \
 apk add --no-cache --upgrade \
         jq \
         python3 \
         curl \
         wget \
         nano \
         openssh-client \
         sshpass

# Add local files
COPY root/ /

COPY root/scripts/cron_execute /etc/cron.d/cron_execute

# Apply cron job
RUN crontab /etc/cron.d/cron_execute

# Port and volumes
VOLUME /config
EXPOSE 80

CMD ["python3", "/scripts/server.py"]