#!/bin/sh

# gpio 23 = DHCP Static key
#ver = 1
# gpio 27 = DHCP Static key
#dhcppin=27
#echo $dhcppin > /sys/class/gpio/export
#echo in > /sys/class/gpio/gpio$dhcppin/direction


if [ ! -f /config/network.conf ] ; then
    cp /etc/network.conf.factory /config/network.conf
fi

# red led
if [ ! -d /sys/class/gpio/gpio37 ];then
echo 37 > /sys/class/gpio/export
echo high > /sys/class/gpio/gpio37/direction
echo 0 > /sys/class/gpio/gpio37/value
fi
# green led
if [ ! -d /sys/class/gpio/gpio38 ];then
echo 38 > /sys/class/gpio/export
echo high > /sys/class/gpio/gpio38/direction
echo 0 > /sys/class/gpio/gpio38/value
fi
# beep
if [ ! -d /sys/class/gpio/gpio39 ];then
echo 39 > /sys/class/gpio/export
echo high > /sys/class/gpio/gpio39/direction
echo 0 > /sys/class/gpio/gpio39/value
fi

# Read network configuration
#dhcp_key="`cat /sys/class/gpio/gpio$dhcppin/value`"

dhcp_key=0
if [ "dhcp_key" = "1" ] ; then
	dhcp=true
	hostname=antMiner
elif [ -s /config/network.conf ] ; then
    . /config/network.conf
else
    dhcp=true
    hostname=antMiner
fi

#echo $dhcppin > /sys/class/gpio/unexport

if [ -n "$hostname" ] ; then
	hostname $hostname
	echo $hostname > /etc/hostname
fi

# Setup link 
ip link set lo up
ip link set eth0 up
ip link ls eth0
ip addr flush dev eth0


#id_h=`/sbin/devmem 0x43c000f0 | awk 'NR==1 {s=and($NF,0xfeff); printf("%04X",s)}'`
#mac0=${id_h:0:2}
#mac1=${id_h:2:2}

#id_l=`/sbin/devmem 0x43c000f4 | awk 'NR==1 {s=and($NF,0x7fffffff); printf("%08X",s)}'`

#mac2=${id_l:0:2}
#mac3=${id_l:2:2}
#mac4=${id_l:4:2}
#mac5=${id_l:6:2}

check_hex_is_sn_mac() {
  if [ "$1" == "30" ]; then
      echo "0"
  elif [ "$1" == "31" ]; then
      echo "1" 
  elif [ "$1" == "32" ]; then
      echo "2"	  
  elif [ "$1" == "33" ]; then
      echo "3"	  
  elif [ "$1" == "34" ]; then
      echo "4"
  elif [ "$1" == "35" ]; then
      echo "5" 
  elif [ "$1" == "36" ]; then
      echo "6"	  
  elif [ "$1" == "37" ]; then
      echo "7"	  
  elif [ "$1" == "38" ]; then
      echo "8"
  elif [ "$1" == "39" ]; then
      echo "9"
  elif [ "$1" == "3a" ]; then
      echo ":"	  
  elif [ "$1" == "41" ]; then
      echo "A"
  elif [ "$1" == "42" ]; then
      echo "B"
  elif [ "$1" == "43" ]; then
      echo "C"
  elif [ "$1" == "44" ]; then
      echo "D"	  
  elif [ "$1" == "45" ]; then
      echo "E"
  elif [ "$1" == "46" ]; then
      echo "F"	  
  elif [ "$1" == "61" ]; then
      echo "a"
  elif [ "$1" == "62" ]; then
      echo "b"
  elif [ "$1" == "63" ]; then
      echo "c"
  elif [ "$1" == "64" ]; then
      echo "d"
  elif [ "$1" == "65" ]; then
      echo "e"
  elif [ "$1" == "66" ]; then
      echo "f"	  
  else
      echo "x"
  fi
}

mac_dump1=`nanddump -p /dev/mtd0 -s 0x1080000 -l 0x20 | grep 0x01080000`
mac_dump2=`nanddump -p /dev/mtd0 -s 0x1080000 -l 0x20 | grep 0x01080010`
get_mac1=`echo $mac_dump1 | cut -c 13-14,16-17,19-20,22-23,25-26,28-29,31-32,34-35,37-38,40-41,43-44,46-47,49-50,52-53,55-56,58-59`
get_mac2=`echo $mac_dump2 | cut -c 13-14`

var=0
index=0
index1=1
check_mac1=0
check_mac2=0
while [ $var -lt 16 ];do
	index=$(($var+$var+1))
	index1=$(($index+1))
	mac_byte_hex=`echo $get_mac1 | cut -c $index,$index1`
	mac_byte_check=`check_hex_is_sn_mac $mac_byte_hex`
    if [ "$mac_byte_check" == "x" ]; then
        check_mac1=$(($check_mac1+1))
    fi
	var=$(($var+1))
done

mac_byte_hex=`echo $get_mac2 | cut -c 1,2`
mac_byte_check=`check_hex_is_sn_mac $mac_byte_hex`
if [ "$mac_byte_check" == "x" ]; then
	check_mac2=$(($check_mac2+1))
fi

if [ ! -f /config/mac ];then
    if [ "$check_mac1" != "0" ] || [ "$check_mac2" != "0" ]; then
        id_h=`devmem 0x43c000f0`
        id_l=`devmem 0x43c000f4`
        echo $id_h$id_l > /tmp/chip_id
        mac_string=`openssl rand -rand /tmp/chip_id -hex 6`
        mac0=`echo ${mac_string:0:2} | awk 'NR==1 {s=and($NF,0xfe); printf("%02x",s)}'`
        mac1=${mac_string:2:2}
        mac2=${mac_string:4:2}
        mac3=${mac_string:6:2}
        mac4=${mac_string:8:2}
        mac5=${mac_string:10:2}
        mac="$mac0:$mac1:$mac2:$mac3:$mac4:$mac5"
        echo $mac > /config/mac

        flash_erase /dev/mtd0 0x1080000 0x1
        nandwrite -p -s 0x1080000 /dev/mtd0 /config/mac
    else
        nanddump -s 0x1080000 /dev/mtd0 -l 0x1 -f /config/mac_flash
        flash_mac=`cat /config/mac_flash`
        echo ${flash_mac:0:17} > /config/mac
        rm /config/mac_flash
    fi
else
    if [ "$check_mac1" != "0" ] || [ "$check_mac2" != "0" ]; then
        flash_erase /dev/mtd0 0x1080000 0x1
        nandwrite -p -s 0x1080000 /dev/mtd0 /config/mac
	else
        nanddump -s 0x1080000 /dev/mtd0 -l 0x1 -f /config/mac_flash
        flash_mac=`cat /config/mac_flash`
        file_mac=`cat /config/mac`
        if [ ${flash_mac:0:17} != ${file_mac:0:17} ]; then
            echo ${flash_mac:0:17} > /config/mac
        fi
        rm /config/mac_flash
	fi
	mac=`cat /config/mac`
fi

sn_dump1=`nanddump -p /dev/mtd0 -s 0x1060000 -l 0x20 | grep 0x01060000`
sn_dump2=`nanddump -p /dev/mtd0 -s 0x1060000 -l 0x20 | grep 0x01060010`
get_sn1=`echo $sn_dump1 | cut -c 13-14,16-17,19-20,22-23,25-26,28-29,31-32,34-35,37-38,40-41,43-44,46-47,49-50,52-53,55-56,58-59`
get_sn2=`echo $sn_dump2 | cut -c 13-14,16-17,19-20,22-23,25-26,28-29,31-32,34-35,37-38,40-41,43-44,46-47,49-50,52-53,55-56,58-59`

var=0
index=0
index1=1
check_sn1=0
check_sn2=0
while [ $var -lt 16 ];do
	index=$(($var+$var+1))
	index1=$(($index+1))
	sn_byte_hex=`echo $get_sn1 | cut -c $index,$index1`
	sn_byte_check=`check_hex_is_sn_mac $sn_byte_hex`
    if [ "$sn_byte_check" == "x" ]; then
        check_sn1=$(($check_sn1+1))
    fi
	var=$(($var+1))
done

var=0
index=0
index1=1
while [ $var -lt 16 ];do
	index=$(($var+$var+1))
	index1=$(($index+1))
	sn_byte_hex=`echo $get_sn2 | cut -c $index,$index1`
	sn_byte_check=`check_hex_is_sn_mac $sn_byte_hex`
    if [ "$sn_byte_check" == "x" ]; then
        check_sn2=$(($check_sn2+1))
    fi
	var=$(($var+1))
done

if [ ! -f /config/sn ]; then
    if [ "$check_sn1" != "0" ] || [ "$check_sn2" != "0" ]; then
        uuid_string=`/usr/bin/uuid`
        echo $uuid_string > /config/sn
        flash_erase /dev/mtd0 0x1060000 0x1
        nandwrite -p -s 0x1060000 /dev/mtd0 /config/sn
    else
        nanddump -s 0x1060000 /dev/mtd0 -l 0x1 -f /config/sn_flash
        flash_sn=`cat /config/sn_flash`
        echo ${flash_sn:0:32} > /config/sn
        rm /config/sn_flash
    fi
else
    if [ "$check_sn1" != "0" ] || [ "$check_sn2" != "0" ]; then
        flash_erase /dev/mtd0 0x1060000 0x1
        nandwrite -p -s 0x1060000 /dev/mtd0 /config/sn
	else
        nanddump -s 0x1060000 /dev/mtd0 -l 0x1 -f /config/sn_flash
        flash_sn=`cat /config/sn_flash`
        file_sn=`cat /config/sn`
        if [ ${flash_sn:0:32} != ${file_sn:0:32} ]; then
            echo ${flash_sn:0:32} > /config/sn
        fi
        rm /config/sn_flash
	fi
fi

echo $mac
ifconfig eth0 down > /dev/null 2>&1 
ifconfig eth0 hw ether $mac > /dev/null 2>&1
ifconfig eth0 up  > /dev/null 2>&1

killall -9 udhcpc > /dev/null 2>&1

if [ "$dhcp" = "true" ] ; then
    if [ "$QUIET" = "true" ] ; then
        udhcpc -b -t 10 -A 10 -x hostname:$hostname -i eth0 > /dev/null
    else
        udhcpc -b -t 10 -A 10 -x hostname:$hostname -i eth0
    fi
else
    # Manual setup
    ip addr add $ipaddress/$netmask dev eth0
    
    ip ro add default via $gateway

    > /etc/resolv.conf
    for ip in $dnsservers ; do
	echo nameserver $ip >> /etc/resolv.conf
    done
fi

sync
