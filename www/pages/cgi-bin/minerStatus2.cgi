ant_input=`cat /dev/stdin`
a#!/bin/sh

cp /home/bmminer.conf /config/

cp /home/minerStatus.cgi /www/pages/cgi-bin/

/etc/init.d/bmminer.sh force-reload

sycn