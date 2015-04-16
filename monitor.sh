#!/bin/bash
WORKFOLDER="/home/sysadm/monitor"
SCRIPTSFOLDER="$WORKFOLDER/scripts"
EMAIL="alonsofonseca.angel@gmail.com"

run_all(){

# LOAD AVERAGE
echo "---- LOAD AVERAGE"
$SCRIPTSFOLDER/loadavg.sh -w 10 -c 20 -e $EMAIL 

}

run_all
