#!/bin/bash
# script:  camlog.sh
# author:  Sebastian R. Usami <sebastianusami@gmail.com>
# license: GPLv3
# description:
#   Parses logs from ExacqVision Server 6
#   Returns data from events such as camera
#   going online/offline/email alerts sent.
# usage:
#       usage: camlog [up | uplast | down | downlast]
#                     [email | -ip [xx]]'

declare LOGDIR="/home/user/Desktop/logs"
declare LOGFILE=$(ls -p $LOGDIR | grep -v "\/" | grep -Po '(\d{8}\.txt)' | tail -n1)
#echo $LOGDIR
#echo $LOGFILE

if [ "$1" = "down" ]; then
    grep -i "PI=160000.*close" $LOGDIR/$LOGFILE | cut -d';' -f4 | sort | uniq -c | grep -v socket

elif [ "$1" = "downlast" ]; then
    grep -i "PI=160000.*close"  $LOGDIR/$LOGFILE  | tail -1 | cut -d';' -f1,4

elif [ "$1" = "up" ]; then
    grep -i "PI=160000.*receiving"  $LOGDIR/$LOGFILE  | cut -d';' -f4 | sort | uniq -c | grep -v timeout

elif [ "$1" = "uplast" ]; then
    grep -i "PI=160000.*receiving"  $LOGDIR/$LOGFILE  | grep -v timeout | tail -n1 | cut -d';' -f1,4

elif [ "$1" = "email" ]; then
    grep -i "email"  $LOGDIR/$LOGFILE  | cut -d';' -f4 | cut -d':' -f5,6

elif [ "$1" = '-ip' ]; then
#    if [ -n "$2" ]; then
        echo 'searching IP:' $2
        grep -i '192.168.0.'$2  $LOGDIR/$LOGFILE  | cut -d';' -f3,4 | sort | uniq -c
#    else
#        echo 'usage: camlog [up | uplast | down | downlast]'
#        echo '              [email | -ip [64]]'
#    fi

else
    echo 'usage: camlog [up | uplast | down | downlast]'
    echo '              [email | -ip [64]]'
fi

