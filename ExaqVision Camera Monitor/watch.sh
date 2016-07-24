#!/bin/bash
# script:  watchemail.sh
# author:  Sebastian R. Usami <sebastianusami@gmail.com>
# license: GPLv3
# description:
#   watches the given path for changes
#   and executes a given command when changes occur
#   In this case, executes camera log parser.
#   then proceeds to email based on results.
# usage:
#   watch <path> <cmd...>
#

declare CLIENT_NAME="CunninghamSecurity"
declare CLIENT_EMAIL="helpdesk@cunninghamsecurity.com"
declare CLIENT_SUPPORT="helpdesk@bekinc.net"
declare CLIENT_SERVER="localhost:25"

declare LOGDIR="/home/user/Desktop/logs"
declare LOGFILE=$(ls -p $LOGDIR | grep -v "\/" | grep -v update | tail -n1)

sha=0
camup=0
camdown=0
previous_sha=0
previous_camup=0
previous_camdown=0
message_body=0
message_sub=0


send_notification(){
    #message_sub="Camera Alert"
    #message_body="Camera status change"
    emailstatus=$(./sendEmail.pl -f $CLIENT_EMAIL -t sebastian.usami@bekinc.net -u "$message_sub" -m "$message_body" -s $CLIENT_SERVER)
    echo $emailstatus
}

update_sha()
{
    sha=`ls -lR $LOGDIR | sha1sum`
}

showstatus(){
    ## Build/make commands here
    clear
    echo "--> Monitor: Monitoring filesystem... (Press enter to force a build/update)"
    echo '-------------- status -------------------------'
    echo ; ./camlog.sh up
    echo ; ./camlog.sh down
    echo ;
    echo '-----------------------------------------------'
}

logchanged(){
    echo "--> Monitor: Files changed, Calculating Changes..."
    
    showstatus

    camup=$(./camlog.sh uplast)
    camdown=$(./camlog.sh downlast)

    echo '------Change status ----------'
    echo "Pre_camup  : "  $previous_camup;
    echo "Camup      : "  $camup

    echo "Pre_camdown: "  $previous_camdown;
    echo "Camdown    : "  $camdown;

    if [[ $camup != $previous_camup ]] ; then 
        echo "camera went up"
	message_body=$camup
	message_sub="Camera ALERT: UP - $CLIENT_NAME"
	send_notification
   fi

    if [[ $camdown != $previous_camdown ]] ; then 
        echo "camera went down"
	message_body=$camdown
	message_sub="Camera ALERT: DOWN - $CLIENT_NAME"
        send_notification
    fi

    previous_sha=$sha
    previous_camup=$camup
    previous_camdown=$camdown

}

compare() {
    update_sha
    if [[ $sha != $previous_sha ]] ; then logchanged; fi
}

run() {
    while true; do

        compare

        read -s -t 1 && (
            echo "--> Monitor: Forced Update..."
            showstatus
        )

    done
}

clear
echo "--> Monitor: Init..."
echo "--> Monitor: Monitoring filesystem... (Press enter to force a build/update)"
run
