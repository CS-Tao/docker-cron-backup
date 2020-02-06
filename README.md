# docker-cron-backup

> 定时使用 sftp 将远程服务器的文件或文件夹备份到本地

[![Deploy To GitHub Registry](https://github.com/CS-Tao/docker-cron-backup/workflows/Deploy%20To%20GitHub%20Registry/badge.svg)](https://github.com/CS-Tao/docker-cron-backup/packages/101776?version=master)
[![Deploy To Docker Hub](https://github.com/CS-Tao/docker-cron-backup/workflows/Deploy%20To%20Docker%20Hub/badge.svg)](https://hub.docker.com/r/cstao/docker-cron-backup)

## 用法

### 使用命令行

```bash
sudo docker run -d --rm \
  --name cron-backup \
  -e HOST=host_ip \
  -e SSH_PORT=22 \
  -e SSH_USER=user \
  -e SSH_PASSWD=secret_passwd \
  -e SYNC_FILES=file1:file1_bak,file2:file2_bak \
  -e SYNC_FOLDERS=folder1:folder1_bak,folder2:folder2_bak,folder3:folder3_bak \
  -e MAX_BACKUPS=7 \
  -e INIT_BACKUP=1 \
  -e INIT_BACKUP_TIMEOUT=5 \
  -e CRON_TIME='0 4 * * *' \
  -v ./backups/:/root/backups/ \
  -v ./sync/:/root/sync/ \
  -v ./log/:/var/log/ \
  cstao/cron-backup:v1.0.0
```

### 使用 docker-compose

docker-compose.yml
```yml
version: '3.5'

services:
  cron-backup:
    image: cstao/cron-backup:v1.0.0
    container_name: cron-backup
    restart: unless-stopped
    volumes:
      - ./backups/:/root/backups/
      - ./sync/:/root/sync/
      - ./log/:/var/log/
    environment:
      HOST: host_ip
      SSH_PORT: 22
      SSH_USER: user
      SSH_PASSWD: secret_passwd
      SYNC_FILES: file1:file1_bak,file2:file2_bak
      SYNC_FOLDERS: folder1:folder1_bak,folder2:folder2_bak,folder3:folder3_bak
      MAX_BACKUPS: 7
      INIT_BACKUP: 1
      INIT_BACKUP_TIMEOUT: 5
      CRON_TIME: '0 4 * * *'
```

## 环境变量

- `HOST`：主机 IP, 默认为`localhost`
- `SSH_PORT`：ssh 端口, 默认为`22`
- `SSH_USER`：ssh 用户, 默认为`root`
- `SSH_PASSWD`：ssh 密码，`不可为空`
- `SYNC_FILES`：需要备份的文件，以英文冒号隔开远程路径和本地路径，以英文逗号隔开不同文件，不能有空格，如 file1:file1_bak,file2:file2_bak。冒号前的文件为服务器上的文件绝对路径，冒号后的文件为在`./sync/`文件夹中的名字
- `SYNC_FOLDERS`：需要备份的文件夹，以英文冒号隔开远程路径和本地路径，以英文逗号隔开不同文件夹，不能有空格，如 folder1:folder1_bak,folder2:folder2_bak。冒号前的文件夹为服务器上的文件绝对路径，冒号后的文件夹路径为文件夹在`./sync/`文件夹中的路径
- `MAX_BACKUPS`：最大备份数量，即 backup 文件夹中压缩包的数量，默认为`10`
- `INIT_BACKUP`：每次启动容器是否需要备份一次，数字大于 0 表示需要，默认为空，即每次启动容器时`不执行`备份
- `INIT_BACKUP_TIMEOUT`：第一次备份等待时间(s)，仅在`INIT_BACKUP`大于 0 时有效，默认为`0`
- `CRON_TIME`：定时表达式，默认为`0 4 * * `，即每天 4 点执行备份

*`SSH_PASSWD`不可为空，`SYNC_FILES`和`SYNC_FOLDERS`不可同时为空*

## 持久卷

- `/root/backups/`：备份文件夹，保存每次`/root/sync/`文件夹的压缩包
- `/root/sync/`：同步文件夹，每次同步会清空之前的内容并下载最新内容
- `/var/log/`：日志文件夹

## 容器操作

- 备份文件和文件夹的命令
  ```bash
  docker exec cron-backup /root/backup.sh
  ```

- 恢复文件和文件夹的命令
  ```bash
  docker exec cron-backup /root/restore.sh
  ```
