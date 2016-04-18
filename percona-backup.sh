#!/bin/sh
NOW=`date +%H`
TIME_NOW=`date +%H:%M:%S`
DATE=`date +%Y-%m-%d`
BK_DIR=/home/hot_backup
BASE_DIR=/home/hot_backup/$DATE/full
#XBSTREAM=/home/xbstream/$DATE
COMPRESS=/home/compress/$DATE
LOG=/var/log/percona-backup.log

USER=alive
PASS=happy

mkdir -p $BK_DIR
mkdir -p $COMPRESS

## Check Time = 00 ?
if [ "$NOW" -eq '00' ]; then
	## Check Base dir has exists?
        if [ -d $BASE_DIR ]; then
		echo "$DATE $TIME_NOW	Full backup folder has exists." >> $LOG
        else
	## If hasn't full backup , create full backup
		innobackupex --user=$USER --password=$PASS --use-memory=1G $BASE_DIR --no-timestamp &&  tar -zcPf $COMPRESS/$DATE-full.tar.gz $BASE_DIR
                echo "$DATE $TIME_NOW	Create Full Backup Completed." >> $LOG
        fi

## Check Time = 01 ?
elif [ "$NOW" -eq '01' ]; then
	## Check Base dir has exists?
	if [ -d $BASE_DIR ]; then
		INC_DIR=$BK_DIR/$DATE/inc$NOW
		## Check Inc dir has exists?
		if [ -d $INC_DIR ]; then
			echo "$DATE $TIME_NOW	Incremental Backup at $NOW has exists." >> $LOG
		
		else		
		## If hasn't incremental backup , create incremental backup
			innobackupex --user=$USER --password=$PASS --use-memory=1G --incremental $INC_DIR --incremental-basedir=$BASE_DIR --no-timestamp && tar -zcPf $COMPRESS/$DATE-inc"$NOW".tar.gz $INC_DIR
			echo "$DATE $TIME_NOW	Create Incremental Backup at Time : $TIME_NOW Completed." >> $LOG
		fi
	else
        	echo "$DATE $TIME_NOW	No Full Backup." >> $LOG
	fi

## Check Time > 01 ?
elif [ "$NOW" -gt '01' ]; then
	## Check Base dir has exists?
	if [ -d $BASE_DIR ]; then
		NOW=`date +%H`
		BEFORE=`expr $NOW - 1`
		INC_DIR=$BK_DIR/$DATE/inc$NOW
		
		if [ "$BEFORE" -lt '10' ]; then
			BASE_DIR_NEW=$BK_DIR/$DATE/inc0$BEFORE
		else
			BASE_DIR_NEW=$BK_DIR/$DATE/inc$BEFORE
		fi
		
		## Check previous Inremental backup has exists?
		if [ -d $BASE_DIR_NEW ]; then
			
			## Check Incremental backup current time has exists?
			if [ -d $INC_DIR ]; then
                        	echo "$DATE $TIME_NOW	Incremental Backup at $NOW has exists." >> $LOG
			else
				innobackupex --user=$USER --password=$PASS --use-memory=1G --incremental $INC_DIR --incremental-basedir=$BASE_DIR_NEW --no-timestamp && tar -zcPf $COMPRESS/$DATE-inc"$NOW".tar.gz $INC_DIR
	  			echo "$DATE $TIME_NOW	Create Incremental Backup at Time : $TIME_NOW Completed." >> $LOG
			fi		
		else
			echo "$DATE $TIME_NOW	No Incremental Backup at Time : $BEFORE" >> $LOG
		fi
	else
		echo "$DATE $TIME_NOW	No Full Backup." >> $LOG
	fi
fi

