#!/bin/bash
set -e

source ./logcat.sh

echo_info "Running backup scripts"

function backup() {
  if [ $1 -eq 0 ]; then
    SYNC_ENV_NAME=SYNC_FILES
    file_pairs=(${SYNC_FILES//,/ })
  elif [ $1 -eq 1 ]; then
    SYNC_ENV_NAME=SYNC_FOLDERS
    file_pairs=(${SYNC_FOLDERS//,/ })
  else
    echo_error "Function args error."
    exit 1
  fi

  [ ${#file_pairs[@]} -lt 1 ] && \
    echo_error "${SYNC_ENV_NAME} env format error." && \
    exit 1
  
  for file_pair_item in ${file_pairs[@]}
  do
    file_pair=(${file_pair_item//:/ })
    [[ ${#file_pair[@]} -ne 2 || -z ${file_pair[0]} || -z ${file_pair[1]} ]] && \
      echo_error "${SYNC_ENV_NAME} env format error." && \
      exit 1
    # Create local dir if not exist
    [[ $1 -eq 1 && ! -d sync/${file_pair[1]} ]] && mkdir -p sync/${file_pair[1]}
    
    [[ $1 -eq 0 ]] && \
      stfp_cmd="get ${file_pair[0]} sync/${file_pair[1]}" || \
      stfp_cmd="get -r ${file_pair[0]} sync/${file_pair[1]}"
    echo_info "Backup transfer with command: ${stfp_cmd}"
    ./sftp.sh ${HOST} ${SSH_PORT} ${SSH_USER} ${SSH_PASSWD} "${stfp_cmd}" >/dev/null
  done
}

echo_info "Delete files in sync/"

rm -rf sync/*

# 0 for files
[ -n "$SYNC_FILES" ] && backup 0

# 1 for folders
[ -n "$SYNC_FOLDERS" ] && backup 1

ZIP_FILE_NAME_PREFIX="$(date +%Y%m%d%H%M%S)"
echo_info "Zip sync/* to  ./backups/${ZIP_FILE_NAME_PREFIX}_sync.tar.gz"
tar -czf ./backups/${ZIP_FILE_NAME_PREFIX}_sync.tar.gz -C sync .
cp -f ./backups/${ZIP_FILE_NAME_PREFIX}_sync.tar.gz ./backups/latest_sync.tar.gz
echo_info "Backup scripts done"
./clean.sh
echo_blank