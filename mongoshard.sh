#!/bin/bash
### BEGIN INIT INFO
# Provides:          mongoshard
# Required-Start:    $local_fs $network $named $time $syslog
# Required-Stop:     $local_fs $network $named $time $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Description:       Start script for a mongo sharded cluster
### END INIT INFO

SETUPDIR=`pwd -P`
export DATA_DIR=$SETUPDIR/data

SCRIPTSTART="docker-compose -f $SETUPDIR/docker-compose.yml up"
SCRIPTSTOP="docker-compose -f $SETUPDIR/docker-compose.yml down"
SCRIPTSTATUS="docker-compose -f $SETUPDIR/docker-compose.yml ps"
#RUNAS=<USERNAME>

PIDFILE=/var/run/mongoshard.pid
LOGFILE=/var/log/mongoshard.log


start() {
  if [ -f /var/run/$PIDNAME ] && kill -0 $(cat /var/run/$PIDNAME); then
    echo 'Service already running' >&2
    return 1
  fi
  echo 'Starting service…' >&2
  local CMD="$SCRIPTSTART &> \"$LOGFILE\" & echo \$!"
  su -c "$CMD" > "$PIDFILE"
  wait_up mongos1 27017
  echo 'Service started' >&2
}

start_init()  {
  if [ -f /var/run/$PIDNAME ] && kill -0 $(cat /var/run/$PIDNAME); then
    echo 'Service already running' >&2
    return 1
  fi
  echo 'Starting service…' >&2
  local CMD="$SCRIPTSTART &> \"$LOGFILE\" & echo \$!"
  su -c "$CMD" > "$PIDFILE"
}

stop() {
  if [ ! -f "$PIDFILE" ] || ! kill -0 $(cat "$PIDFILE"); then
    echo 'Service not running' >&2
    return 1
  fi
  echo 'Stopping service…' >&2
  local CMD="$SCRIPTSTOP &> \"$LOGFILE\" & echo \$!"
  su -c "$CMD" 
  while kill -0 $(cat "$PIDFILE") >/dev/null 2>&1
  do
	printf '.'
	sleep 1
  done
  rm -f "$PIDFILE"
  echo 'Service stopped' >&2
}

wait_up(){
	until docker exec -it $1 bash -c "mongo --host $1:$2 --eval 'quit(db.runCommand({ ping: 1 }).ok ? 0 : 2)'"&>/dev/null; do
	  printf '.'
	  sleep 1
	done
}

reset(){
	dirs=( mongocfg1  mongocfg2  mongocfg3  mongors1n1  mongors1n2  mongors1n3  mongors2n1  mongors2n2  mongors2n3  mongocli )
	for d in ${dirs[@]}; do
	  echo "Resetting data/$d"
	  sudo rm -rf data/$d
	  mkdir data/$d
	  #touch data/$d/.gitkeep
	done
}

mkdir_init(){
	echo "Creating data folders"
	dirs=( mongocfg1  mongocfg2  mongocfg3  mongors1n1  mongors1n2  mongors1n3  mongors2n1  mongors2n2  mongors2n3  mongocli )
	for d in ${dirs[@]}; do
	  echo "Creating data/$d"
	  sudo rm -rf data/$d
	  mkdir data/$d -p
	  #touch data/$d/.gitkeep
	done
}

status(){
  if [ ! -f "$PIDFILE" ] || ! kill -0 $(cat "$PIDFILE"); then
    echo 'Service not running' >&2
    return 1
  fi
  echo 'Service status…' >&2
  local CMD="$SCRIPTSTATUS"
  su -c "$CMD" 
}

init(){
	mkdir_init
	start_init
	#sleep 15
	echo "Waiting for config containers"
	wait_up mongocfg1 27019
	echo "Started.."

	echo "Intializing replicas config set"
	replicate="rs.initiate(); sleep(1000); cfg = rs.conf(); cfg.members[0].host = \"mongocfg1:27019\"; rs.reconfig(cfg); rs.add(\"mongocfg2:27019\"); rs.add(\"mongocfg3:27019\"); rs.status();"
	docker exec -it mongocfg1 bash -c "echo '${replicate}' | mongo --port 27019"

	echo "Waiting for shard containers"
	wait_up mongors1n1 27018
	echo "Started.."
	for (( rs = 1; rs < 3; rs++ )); do
	  echo "Intializing replica ${rs} set"
	  replicate="rs.initiate(); sleep(1000); cfg = rs.conf(); cfg.members[0].host = \"mongors${rs}n1:27018\"; rs.reconfig(cfg); rs.add(\"mongors${rs}n2:27018\"); rs.add(\"mongors${rs}n3:27018\"); rs.status();"
	  docker exec -it mongors${rs}n1 bash -c "echo '${replicate}' | mongo --port 27018"
	done

	echo "Waiting for router containers"
	#sleep 2
	wait_up mongos1 27017

	docker exec -it mongos1 bash -c "echo \"sh.addShard('mongors1/mongors1n1:27018'); sh.addShard('mongors2/mongors2n1:27018');\" | mongo "
}

case "$1" in
  start)
    start
    ;;
  reset)
    reset
    ;;
  stop)
    stop
    ;;
  init)
    init
    ;;
  status)
    status
    ;;
  retart)
    stop
    start
    ;;
  *)
    echo "Usage: $0 {start|stop|restart|reset|init|status}"
esac
