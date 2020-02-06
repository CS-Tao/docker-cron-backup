#!/usr/bin/expect -f

if {$argc<5} {
  puts stderr "Usage: ./sftp.sh HOST PORT USER PASSWD COMMAND"
  exit 1
}

set timeout 600
set HOST [lindex $argv 0]  
set PORT [lindex $argv 1]
set USER [lindex $argv 2]
set PASSWD [lindex $argv 3]
set COMMAND [lindex $argv 4]
set prompt "sftp>"

spawn sftp -P $PORT $USER@$HOST

expect {
  "ssh:" { send_error "Exit with ssh error\r"; exit 1 }
  "yes/no"  { send "yes\r"; exp_continue }
  "password:"  { send "${PASSWD}\r"; exp_continue }
  "$prompt" { send "${COMMAND}\r"; }
  eof {
    send_error "Exit with eof error\r";
    exit 2
	}
}

expect {
  "KB/s" { send ""; exp_continue }
  "Permission denied" { send_error "Exit with Permission denied\r"; exit 3 }
  "$prompt" { send "exit\r";}
}

expect eof
