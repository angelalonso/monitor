#!/bin/bash
TITLE="DISK and INODE Free Space"

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
WORKFOLDER="/home/sysadm/monitor/scripts"
TMP="$WORKFOLDER/diskspace.tmp"
rm $TMP 2>/dev/null

MAXERROR=0

WORST="OK"
RESULTDISK=$(df -lPh 2>/dev/null | grep -v "Mounted on" | sed ':a;N;$!ba;s/\n/||||/g')
OLD_IFS=IFS
IFS="||||"
MODE="Disk"
for line in $RESULTDISK; do
  if [[ "$line" != "" ]]; then
    ELEMENT=$(echo $line | awk '{print $1}')
    PERCENT=$(echo $line | awk '{print $5}' | sed 's/%//g')
    FREE=$(echo $line | awk '{print $4}')
    if [[ "$PERCENT" != "-" ]]; then
      if [[ "$PERCENT" -ge 0 ]]; then
        if [[ "$PERCENT" -ge "$CRIT" ]]; then
          CRIT_LIST=$(echo $CRIT_LIST " " $ELEMENT" - "$PERCENT"% ")
          echo "CRITICAL - "$MODE" - "$ELEMENT" -   "$PERCENT"%,    "$FREE" Free " >> $TMP
          WORST="CRIT"
        elif [[ "$PERCENT" -ge "$WARN" ]]; then
          WARN_LIST=$(echo $WARN_LIST " " $ELEMENT" - "$PERCENT"%")
          echo "WARNING  - "$MODE" - "$ELEMENT" -   "$PERCENT"%,    "$FREE" Free " >> $TMP
          if [[ "$WORST" != "CRIT" ]]; then
            WORST="WARN"
          fi
        else
          OK_LIST=$(echo $OK_LIST " " $ELEMENT" - "$PERCENT"%")
          echo "OK       - "$MODE" - "$ELEMENT" -   "$PERCENT"%,    "$FREE" Free " >> $TMP
        fi
      else
        echo "SOMETHING WEIRD HAPPENED! Please check the percentages manually"
        exit 3
      fi
    fi
  fi
done
IFS=$OLD_IFS

RESULTINODE=$(df -lPih 2>/dev/null | grep -v "Mounted on" | sed ':a;N;$!ba;s/\n/||||/g')
OLD_IFS=IFS
IFS="||||"
MODE="Inode"
for line in $RESULTINODE; do
  if [[ "$line" != "" ]]; then
    ELEMENT=$(echo $line | awk '{print $1}')
    PERCENT=$(echo $line | awk '{print $5}' | sed 's/%//g')
    FREE=$(echo $line | awk '{print $4}')
    if [[ "$PERCENT" != "-" ]]; then
      if [[ "$PERCENT" -ge 0 ]]; then
        if [[ "$PERCENT" -ge "$CRIT" ]]; then
          CRIT_LIST=$(echo $CRIT_LIST " " $ELEMENT" - "$PERCENT"% ")
          echo "CRITICAL - "$MODE" - "$ELEMENT" -   "$PERCENT"%,    "$FREE" Free " >> $TMP
          WORST="CRIT"
        elif [[ "$PERCENT" -ge "$WARN" ]]; then
          WARN_LIST=$(echo $WARN_LIST " " $ELEMENT" - "$PERCENT"%")
          echo "WARNING  - "$MODE" - "$ELEMENT" -   "$PERCENT"%,    "$FREE" Free " >> $TMP
          if [[ "$WORST" != "CRIT" ]]; then
            WORST="WARN"
          fi
        else
          OK_LIST=$(echo $OK_LIST " " $ELEMENT" - "$PERCENT"%")
          echo "OK       - "$MODE" - "$ELEMENT" -   "$PERCENT"%,    "$FREE" Free " >> $TMP
        fi
      else
        echo "SOMETHING WEIRD HAPPENED! Please check the percentages manually"
        exit 3
      fi
    fi
  fi
done
IFS=$OLD_IFS

if [[ "$CRIT_LIST" != "" ]]; then
  EMAILTITLE="CRITICAL - "$TITLE
  echo "CRITICAL! "$CRIT_LIST" || "$WARN_LIST
  cat $TMP
  cat $TMP | /bin/mail -s "$EMAILTITLE" "$EMAIL"
  rm $TMP 2>/dev/null
  exit 2
elif [[ "$WARN_LIST" != "" ]]; then
  EMAILTITLE="Warning - "$TITLE
  echo "Warning! "$WARN_LIST
  cat $TMP
  cat $TMP | /bin/mail -s "$EMAILTITLE" "$EMAIL"
  rm $TMP 2>/dev/null
  exit 1
elif [[ "$OK_LIST" != "" ]]; then
  echo "Everything seems OK"
  cat $TMP
  rm $TMP 2>/dev/null
  exit 0
fi
echo "SOMETHING WEIRD HAPPENED! Please check manually"
rm $TMP 2>/dev/null
exit 3

