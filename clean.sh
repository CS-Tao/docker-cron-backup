#!/bin/bash
set -e

source ./logcat.sh

echo_info "Running clean scripts"

file_dir=./backups
file_num=$(ls -l  $file_dir/*.tar.gz | grep ^- | wc -l)

while(( file_num > MAX_BACKUPS + 1))
do
  del_file=$(ls -rt  $file_dir/*.tar.gz | head -1)
  echo_info "Delete zip file $del_file"
  rm -f $del_file
  let "file_num--"
done

echo_info "Clean scripts done"
