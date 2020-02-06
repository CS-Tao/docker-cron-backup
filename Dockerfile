FROM alpine:latest

MAINTAINER CS-Tao <whucstao@gmail.com>

RUN apk update \
  && apk upgrade \
  && apk add --no-cache bash openssh-client expect \
  && rm -rf /var/cache/apk/*

COPY backup.sh /root/backup.sh
COPY restore.sh /root/restore.sh
COPY clean.sh /root/clean.sh
COPY entrypoint.sh /root/entrypoint.sh
COPY logcat.sh /root/logcat.sh
COPY sftp.sh /root/sftp.sh

RUN chmod +x /root/logcat.sh \
  && chmod +x /root/sftp.sh \
  && chmod +x /root/backup.sh \
  && chmod +x /root/restore.sh \
  && chmod +x /root/clean.sh \
  && chmod +x /root/entrypoint.sh

WORKDIR /root

VOLUME ["/root/backups/", "/root/sync/", "/var/log"]

ENTRYPOINT ["./entrypoint.sh"]

CMD ["tail", "-f", "/var/log/backup.log"]
