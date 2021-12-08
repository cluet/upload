#!/bin/sh
#
# Supervises cgminer process
#

NAME="agent-monitor"
DAEMON=/opt/anthill/bin/$NAME
PIDFILE=/var/run/$NAME.pid

test -x "$DAEMON" || exit 0

start() {
	echo -n "Starting $NAME: "
	start-stop-daemon -S -q -b -m -p "$PIDFILE" -x $DAEMON
	[ $? = 0 ] && echo "OK" || echo "FAIL"
}

stop() {
	echo -n "Stopping $NAME: "
	start-stop-daemon -K -q -p "$PIDFILE"
	[ $? = 0 ] && echo "OK" || echo "FAIL"
}

restart() {
	stop
	start
}

case "$1" in
	start|stop|restart)
		"$1";;
	*)
		echo "Usage: $0 {start|stop|restart}"
		exit 1
esac

