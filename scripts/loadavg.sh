#!/bin/bash
TITLE="LOAD Average"

while getopts ":w:c:e:" opt; do
  case $opt in
    w)
      WARN=$OPTARG
      ;;
    c)
      CRIT=$OPTARG
      ;;
    e)
      EMAIL=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      ;;
  esac
done

if [[ "$WARN" = "" ]]; then
  echo "ERROR (on warn value)! Syntax:"
  echo $0 "-w <warning> -c <critical> -e <email to be alerted>"
  exit 2
fi
if [[ "$CRIT" = "" ]]; then
  echo "ERROR (on crit value)! Syntax:"
  echo $0 "-w <warning> -c <critical> -e <email to be alerted>"
  exit 2
fi
if [[ "$EMAIL" = "" ]]; then
  echo "ERROR (on email value)! Syntax:"
  echo $0 "-w <warning> -c <critical> -e <email to be alerted>"
  exit 2
fi


LOAD=$(cat /proc/loadavg | awk -F. '{print $1}')

if [ $LOAD -ge $CRIT ]; then
  EMAILTITLE="CRITICAL - "$TITLE
  MSG="Critical: High Server Load on: `hostname -i` Load Average: $LOAD"
  echo $MSG
  echo $MSG | /bin/mail -s "$EMAILTITLE" "$EMAIL"
  exit 2
elif [ $LOAD -ge $WARN ]; then
  EMAILTITLE="Warning - "$TITLE
  MSG="Warning: High Server Load on: `hostname -i` Load Average: $LOAD"
  echo $MSG
  echo $MSG | /bin/mail -s "$EMAILTITLE" "$EMAIL"
  exit 1
fi

MSG="OK: `hostname -i` Load Average: $LOAD"
echo $MSG

exit 0 
