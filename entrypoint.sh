#!/bin/bash
set -e

if [[ -z "$SYNC_FOLDERS" && -z "$SYNC_FILES" ]]; then
  echo "NO environment variable SYNC_FOLDERS or SYNC_FILES found. " && exit 1
fi

if [ -z "$SSH_PASSWD" ]; then
  echo "NO environment variable SSH_PASSWD found. " && exit 1
fi

if [ -z "$HOST" ]; then
  export HOST=localhost
  echo "Use default host: localhost"
fi

if [ -z "$SSH_PORT" ]; then
  export PORT=22
  echo "Use default ssh port: 22"
fi

if [ -z "$SSH_USER" ]; then
  export SSH_USER=root
  echo "Use default ssh user: root"
fi

if [ -z "$CRON_TIME" ]; then
  export CRON_TIME=0 3 * * *
  echo "Use default cron time: 0 4 * * *"
fi

if [ -z "$MAX_BACKUPS" ]; then
  export MAX_BACKUPS=10
  echo "Use default max backup: 10"
fi

if [ ! -f /var/log/backup.log ]; then
  touch /var/log/backup.log
fi

if [[ -n "${INIT_BACKUP}" && "${INIT_BACKUP}" -gt "0" ]]; then
  if [ -z $INIT_BACKUP_TIMEOUT ]; then
    export INIT_BACKUP_TIMEOUT=0
  fi
  echo "Create a backup after ${INIT_BACKUP_TIMEOUT}s"
  sleep ${INIT_BACKUP_TIMEOUT}
  ./backup.sh >> /var/log/backup.log 2>&1
fi

echo "${CRON_TIME} /root/backup.sh >> /var/log/backup.log 2>&1 && tail -n 10000 /var/log/backup.log > /var/log/backup.log.bak && mv -f /var/log/backup.log.bak /var/log/backup.log" > ./crontab.conf
crontab ./crontab.conf
echo "Running cron task manager"
exec crond -f

exec "$@"
