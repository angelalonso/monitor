#!/bin/bash
WORKFOLDER="/home/sysadm/monitor"
SCRIPTSFOLDER="$WORKFOLDER/scripts"
CFG="/home/sysadm/private/monitor.cfg"

read_config(){

EMAIL=$(grep "EMAIL" $CFG | sed 's#EMAIL=##' | sed 's#"##g') 

}


run_all(){

# LOAD AVERAGE
echo "---- LOAD AVERAGE"
$SCRIPTSFOLDER/loadavg.sh -w 10 -c 20 -e $EMAIL 

}
read_config
run_all
