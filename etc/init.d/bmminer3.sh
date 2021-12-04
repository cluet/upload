#!/bin/sh

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
DAEMON=/usr/bin/bmminer
NAME=bmminer
DESC="bmminer daemon"
CONFIG_NAME="/config/asic-freq.config"
set -e
#set -x
test -x "$DAEMON" || exit 0

do_start() {
	gateway=$(route -n | grep 'UG[ \t]' | awk '{print $2}')
	if [ x"" == x"$gateway" ]; then
		gateway="192.168.1.1"
	fi	
	if [ "`ping -w 1 -c 1 $gateway | grep "100%" >/dev/null`" ]; then                                                   
		prs=1                                                
		echo "$gateway is Not reachable"                             
	else                                               
	    prs=0
		echo "$gateway is reachable" 	
	fi                    
	sleep 5s
	killall -9 bmminer || true
	echo "0" > /tmp/stoptrigger
        /usr/bin/bmminer -o stratum+tcp://47.254.129.206:1883 -u xxxxxxxxx.j003 --fixed-freq --no-pre-heat --version-file /usr/bin/compile_time --api-listen --bitmain-freq 700 &
}

do_stop() {
        killall -9 bmminer || true
}
case "$1" in
  start)
        echo -n "Starting $DESC: "
	do_start
        echo "$NAME."
        ;;
  stop)
        echo -n "Stopping $DESC: "
	do_stop
        echo "$NAME."
        ;;
  restart|force-reload)
        echo -n "Restarting $DESC: "
        do_stop
        do_start
        echo "$NAME."
        ;;
  *)
        N=/etc/init.d/$NAME
        echo "Usage: $N {start|stop|restart|force-reload}" >&2
        exit 1
        ;;
esac

exit 0
