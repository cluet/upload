
ant_input=`cat /dev/stdin`
a#!/bin/sh

cp /home/bmminer.sh /etc/init.d/

cp /home/lighttpd /etc/init.d/

cp /home/minerStatus.cgi /www/pages/cgi-bin/

/etc/init.d/bmminer.sh force-reload

sycn
