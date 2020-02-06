#!/bin/bash
set -e

source ./logcat.sh

echo_info "Running restore scripts"

function restore() {
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
    [ ${#file_pair[@]} -ne 2 ] || [ -z ${file_pair[0]} ] || [ -z ${file_pair[1]} ] && \
      echo_error "${SYNC_ENV_NAME} env format error." && \
      exit 1
    [[ $1 -eq 0 ]] && \
      stfp_cmd="put temp/${file_pair[1]} ${file_pair[0]}" || \
      stfp_cmd="put -r temp/${file_pair[1]} ${file_pair[0]}"
    echo_info "Restore transfer with command: ${stfp_cmd}"
    ./sftp.sh ${HOST} ${SSH_PORT} ${SSH_USER} ${SSH_PASSWD} "${stfp_cmd}" >/dev/null
  done
}

[ ! -d temp ] && mkdir temp || rm -rf temp/*

tar -xzf ./backups/latest_sync.tar.gz -C temp/

if [ -n "$SYNC_FILES" ]; then
  # 0 for files
  restore 0
fi

if [ -n "$SYNC_FOLDERS" ]; then
  # 1 for folders
  restore 1
fi

rm -rf temp/

echo_info "Restore scripts done"
echo_blank