#!/bin/sh

set -e

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/opt/anthill/bin
NAME=agent
DAEMON=/opt/anthill/bin/agent
CONFIG=/config/anthill.json
PIDFILE=/var/run/$NAME.pid
DESC="Anthill Agent"

test -f "$CONFIG" || exit 0
test -x "$DAEMON" || exit 0

case "$1" in
    start)
        echo -n "Starting $DESC: "
        start-stop-daemon -q -S -p $PIDFILE -m -b -x $DAEMON
        echo "$NAME."
        ;;
    stop)
        echo -n "Stopping $DESC: "
        start-stop-daemon -q -K -p $PIDFILE --oknodo
        rm -f $PIDFILE
        echo "$NAME."
        ;;
    restart)
        echo -n "Restarting $DESC: "
        start-stop-daemon -q -K -p $PIDFILE --oknodo
        rm -f $PIDFILE
        start-stop-daemon -q -S -p $PIDFILE -m -b -x $DAEMON
        echo "$NAME."
        ;;
    *)
        CMD=/etc/init.d/$NAME.sh
        echo "Usage: $CMD {start|stop|restart}" >&2
        exit 1
        ;;
esac

exit 0
