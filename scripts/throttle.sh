#!/bin/bash
#
# Stop the recordings while the analysis catches up
#
source /etc/birdnet/birdnet.conf
srv="birdnet_recording"
while [ 1 ];do
     sleep 61
     if [ -z "${RTSP_STREAM}" ];then
        ingest_dir=${RECS_DIR}/$(date +"%B-%Y/%d-%A")
        mkdir -p $ingest_dir
     else
        ingest_dir=$RECS_DIR/StreamData
     fi
     wavs=$(ls ${ingest_dir}/*.wav | wc -l)
     if [ $(systemctl --state=active | grep $srv | wc -l) -eq 0 ];then
        state="inactive"
     else
        state="active"
     fi
     echo "$(date)    INFO ${wavs} wav files waiting in ${ingest_dir}, $srv state is $state"
     if [ $wavs -gt 100 -a $state = "active" ];then
        sudo systemctl stop $srv
        echo "$(date) WARNING stopped $srv service"
     elif [ $wavs -le 100 -a $state = "inactive" ];then
        sudo systemctl start $srv
        echo "$(date)    INFO started $srv service"
     fi
done

# End
