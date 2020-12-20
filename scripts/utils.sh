#!/bin/bash

LOG_FILE=~/bash_utils.log
echo "setup logs" > $LOG_FILE
log()
{
  MESSAGE=$1
  if [ $# -eq 1 ]; then
	  echo "$MESSAGE"
	fi
  echo "$MESSAGE" >> $LOG_FILE
#    echo "`date` :: $MESSAGE" >> $LOG_FILE
}

#==============================================================================
# Run command functions
#==============================================================================
run_cmd_simple()
{
  CMD=$1
  log " "
  log "---------------------------------"
  log "Running $CMD"
  CMDOUT=$($CMD)
  log "$CMDOUT"
}


run_cmd()
{
  CMD=$1
  log " "
  log "---------------------------------"
  log "Running $CMD"
  CMDOUT=$($CMD 2>&1)
  log "$CMDOUT"
}


run_realtime_cmd()
{
  CMD=$1
  log " "
  log "---------------------------------"
  log "Running $CMD"
  stdbuf -oL $CMD |
    while IFS= read -r line
    do
      log "$line"
    done
}


create_user(){
  typ="$1"
  usr="$2"
  usrpass=""
  show_title "Create User $usr"
  id "$usr" &> /dev/null
  if [ $? -eq 0 ]; then
    log "User $usr already exists"
    return
  fi
  if [[ $typ = "normal" ]]; then
    if [[ -z "$3" ]]; then
      usrpass="$usr"
    else
      usrpass="$3"
    fi
    run_cmd "sudo groupadd $usr"
    # -G rabbitmq,kibana # -c 'ptc $usr user'
    log "running sudo useradd"
    CMDRES=$(sudo useradd $usr -m -s /bin/bash -g $usr -c "New user")
    log "$CMDRES"
    echo -e "$usrpass\n$usrpass" | (sudo passwd $usr)
    if [[ -d "/home/$usr" ]]; then
      log "found user home directory"
    else
      log "ERROR: could not find user home directory"
    fi

  elif [[ $typ = "system" ]]; then
    run_cmd "sudo groupadd $usr"
    CMDRES=$(sudo useradd -r $usr -g $usr -s /bin/bash -c "New user")
    log "$CMDRES"
  fi

  id "$usr" &> /dev/null
  if [ $? -eq 0 ]; then
    log "User $usr created successfully"
  else
    log "ERROR: user $usr not created. Exiting..."
    exit 1
  fi
  run_cmd "groups $usr"
}


setup_rsyslog()
{
  local RSYSLOG_DIR=/var/log/myproject
  local MY_RSYS_CONF=~/myproject_conf
  local RSYSLOG_CONF_FILE=myproject_rsyslog.conf
  show_title "Setup rsyslog"
  run_cmd_simple "sudo mkdir -p $RSYSLOG_DIR"
  run_cmd_simple "sudo chown -R syslog:adm $RSYSLOG_DIR"
  run_cmd_simple "sudo rm /etc/rsyslog.d/$RSYSLOG_CONF_FILE"
  run_cmd_simple "sudo ln -s $MY_RSYS_CONF/$RSYSLOG_CONF_FILE /etc/rsyslog.d/$RSYSLOG_CONF_FILE"
  run_cmd_simple "sudo systemctl restart rsyslog"
}


setup_logrotate()
{
  local myproject_CONF=~/myproject_conf
  local MY_LOGROTATE=myproject-logrotate
  show_title "logrotate configuration"
  run_cmd_simple "sudo chown root:root $myproject_CONF_DIR/$MY_LOGROTATE"
  run_cmd_simple "sudo rm /etc/logrotate.d/$MY_LOGROTATE"
  run_cmd_simple "sudo ln -s $myproject_CONF_DIR/$MY_LOGROTATE /etc/logrotate.d/$MY_LOGROTATE"
  run_cmd_simple "sudo chmod 0644 /etc/logrotate.d/$MY_LOGROTATE"
}

