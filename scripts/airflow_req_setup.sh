#!/bin/bash

CURR_USER=$(whoami)
TMP_DIR=/tmp
VAGRANT_HOME=/home/vagrant
PACK_DIR=$VAGRANT_HOME/pack

LOG_FILE=$PACK_DIR/full_setup_server.log

log()
{
    MESSAGE=$1
	echo "$MESSAGE"
    echo "$MESSAGE" >> $LOG_FILE
}


run_cmd()
{
  CMD=$1
  CMDOUT=$($CMD 2>&1)
  log "---------------------------------"
  log "Running $CMD"
  log "$CMDOUT"
}

echo "$PACK_DIR"
CDIR=$PACK_DIR/erlang
if [ -d "$CDIR" ]; then
	log "found path $i"
run_cmd "sudo dpkg -i $CDIR/libwxbase3.0-0v5_3.0.4+dfsg-3_amd64.deb"
run_cmd "sudo dpkg -i $CDIR/libwxgtk3.0-0v5_3.0.4+dfsg-3_amd64.deb"
run_cmd "sudo dpkg -i $CDIR/libsctp1_1.0.17+dfsg-2_amd64.deb"
#run_cmd "sudo dpkg -i $CDIR/esl-erlang_21.3.1-1~ubuntu~bionic_amd64.deb"
run_cmd "sudo dpkg -i $CDIR/esl-erlang_21.3.1-1_ubuntu_bionic_amd64.deb"
else
echo "Not found $CDIR"
exit 1
fi


CDIR=$PACK_DIR/rabbitmq
run_cmd "sudo dpkg -i $CDIR/socat_1.7.3.2-2ubuntu2_amd64.deb"
run_cmd "sudo dpkg -i $CDIR/rabbitmq-server_3.7.13-1_all.deb"


CDIR=$PACK_DIR/redis
run_cmd "sudo dpkg -i $CDIR/libjemalloc1_3.6.0-11_amd64.deb"
# run_cmd "sudo dpkg -i $CDIR/redis-tools_5%253a4.0.9-1ubuntu0.2_amd64.deb"
# run_cmd "sudo dpkg -i $CDIR/redis-server_5%253a4.0.9-1ubuntu0.2_amd64.deb"
run_cmd "sudo dpkg -i $CDIR/redis-tools_5-4.0.9-1ubuntu0.2_amd64.deb"
run_cmd "sudo dpkg -i $CDIR/redis-server_5-4.0.9-1ubuntu0.2_amd64.deb"


CDIR=$PACK_DIR/net-tools
run_cmd "sudo dpkg -i $CDIR/net-tools_1.60+git20161116.90da8a0-1ubuntu1_amd64.deb"


CDIR=$PACK_DIR/postgres
run_cmd "sudo dpkg -i $CDIR/libpq5_10.10-0ubuntu0.18.04.1_amd64.deb"
run_cmd "sudo dpkg -i $CDIR/postgresql-client-common_190_all.deb"
run_cmd "sudo dpkg -i $CDIR/postgresql-client-10_10.10-0ubuntu0.18.04.1_amd64.deb"
run_cmd "sudo dpkg -i $CDIR/postgresql-common_190_all.deb"
run_cmd "sudo dpkg -i $CDIR/postgresql-10_10.10-0ubuntu0.18.04.1_amd64.deb"
run_cmd "sudo dpkg -i $CDIR/postgresql_10+190_all.deb"
run_cmd "sudo dpkg -i $CDIR/postgresql-contrib_10+190_all.deb"
run_cmd "sudo dpkg -i $CDIR/sysstat_11.6.1-1_amd64.deb"


CDIR=$PACK_DIR/python3-dev-3.6.7
run_cmd "sudo dpkg -i $CDIR/libexpat1_2.2.5-3ubuntu0.1_amd64.deb"
run_cmd "sudo dpkg -i $CDIR/libpython3.6_3.6.7-1_18.04_amd64.deb"
yes | sudo dpkg -i $CDIR/libssl1.1_1.1.1-1ubuntu2.1~18.04.4_amd64.deb
run_cmd "sudo dpkg -i $CDIR/python3.6_3.6.7-1_18.04_amd64.deb"
run_cmd "sudo dpkg -i $CDIR/python3.6-minimal_3.6.7-1_18.04_amd64.deb"
run_cmd "sudo dpkg -i $CDIR/libpython3.6-stdlib_3.6.7-1_18.04_amd64.deb"
run_cmd "sudo dpkg -i $CDIR/libpython3.6-minimal_3.6.7-1_18.04_amd64.deb"
run_cmd "sudo dpkg -i $CDIR/python3-lib2to3_3.6.7-1_18.04_all.deb"
run_cmd "sudo dpkg -i $CDIR/python3-distutils_3.6.7-1_18.04_all.deb"
run_cmd "sudo dpkg -i $CDIR/dh-python_3.20180325ubuntu2_all.deb"
run_cmd "sudo dpkg -i $CDIR/libc-dev-bin_2.27-3ubuntu1_amd64.deb"
run_cmd "sudo dpkg -i $CDIR/linux-libc-dev_4.15.0-55.60_amd64.deb"
run_cmd "sudo dpkg -i $CDIR/libc6-dev_2.27-3ubuntu1_amd64.deb"
run_cmd "sudo dpkg -i $CDIR/libexpat1-dev_2.2.5-3ubuntu0.1_amd64.deb"
run_cmd "sudo dpkg -i $CDIR/libpython3.6-dev_3.6.7-1_18.04_amd64.deb"
run_cmd "sudo dpkg -i $CDIR/libpython3-dev_3.6.7-1~18.04_amd64.deb"
run_cmd "sudo dpkg -i $CDIR/manpages-dev_4.15-1_all.deb"
run_cmd "sudo dpkg -i $CDIR/python3.6-dev_3.6.7-1_18.04_amd64.deb"
run_cmd "sudo dpkg -i $CDIR/python3-dev_3.6.7-1~18.04_amd64.deb"


CDIR=$PACK_DIR/python3-tk-3.6.7
run_cmd "sudo dpkg -i $CDIR/libtcl8.6_8.6.8+dfsg-3_amd64.deb"
run_cmd "sudo dpkg -i $CDIR/libtk8.6_8.6.8-4_amd64.deb"
run_cmd "sudo dpkg -i $CDIR/tk8.6-blt2.5_2.5.3+dfsg-4_amd64.deb"
run_cmd "sudo dpkg -i $CDIR/blt_2.5.3+dfsg-4_amd64.deb"
run_cmd "sudo dpkg -i $CDIR/python3-tk_3.6.7-1_18.04_amd64.deb"


echo "START rabbitmq Config"
sudo systemctl is-enabled rabbitmq-server
sudo rabbitmq-plugins enable rabbitmq_management
sudo rabbitmqctl add_user admin administrator
sudo rabbitmqctl set_user_tags admin administrator
sudo rabbitmqctl add_user genuser genuser
sudo rabbitmqctl set_user_tags genuser administrator
sudo rabbitmqctl add_vhost myproj2
sudo rabbitmqctl set_permissions -p myproj2 genuser ".*" ".*" ".*"
sudo systemctl restart rabbitmq-server


echo "START PostgreSql Config"
sudo -u postgres bash -c "psql -c \"CREATE USER airflow WITH PASSWORD 'airflow';\""
sudo -u postgres bash -c "psql -c \"ALTER USER airflow WITH CREATEDB;\""
sudo -u postgres bash -c "psql -c \"CREATE DATABASE airflow;\""
sudo -u postgres bash -c "psql -c \"GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO airflow;\""

sudo -u postgres bash -c "psql -c \"DROP DATABASE airflow;\""
sudo -u postgres bash -c "psql -c \"\du\""
echo "sudo vi /etc/postgresql/10/main/pg_hba.conf"
echo "# IPv4 local connections:"
echo "host all all 0.0.0.0/0 trust"
echo "sudo vi /etc/postgresql/10/main/postgresql.conf"
echo "listen_addresses = '*'"
echo "sudo service postgresql restart"
