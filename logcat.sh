#!/bin/bash

function echo_error() {
  echo "$(date +"%Y-%m-%d %H:%M:%S") [ERROR] : \"$1\""
}

function echo_warning() {
  echo "$(date +"%Y-%m-%d %H:%M:%S") [WARNING] : \"$1\""
}

function echo_info() {
  echo "$(date +"%Y-%m-%d %H:%M:%S") [INFO] : \"$1\""
}

function echo_blank() {
  echo
}
