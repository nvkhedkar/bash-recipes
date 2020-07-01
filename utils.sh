#!/bin/bash

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
    CMDRES=$(sudo useradd $usr -m -s /bin/bash -g $usr -c "Generative user")
    log "$CMDRES"
    echo -e "$usrpass\n$usrpass" | (sudo passwd $usr)
    if [[ -d "/home/$usr" ]]; then
      log "found user home directory"
    else
      log "ERROR: could not find user home directory"
    fi

  elif [[ $typ = "system" ]]; then
    run_cmd "sudo groupadd $usr"
    CMDRES=$(sudo useradd -r $usr -g $usr -s /bin/bash -c "Generative user")
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
