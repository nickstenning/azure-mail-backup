FROM alpine:3.10.1
MAINTAINER Nick Stenning <nick@whiteink.com>

RUN apk add --no-cache curl gettext git offlineimap && \
    addgroup -g 1000 offlineimap && \
    adduser -D -h /home/offlineimap -G offlineimap -u 1000 offlineimap

COPY backup-runonce gitmail /usr/bin/

USER offlineimap
ENV HOME /home/offlineimap

VOLUME ["/etc/offlineimaprc.template", "/data"]
CMD ["/usr/bin/backup-runonce"]
