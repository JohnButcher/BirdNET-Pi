#!/bin/bash
#
# Stop the recordings while the analysis catches up
#
source /etc/birdnet/birdnet.conf
srv="birdnet_recording"
analyzing_now="."
counter=10
while [ 1 ];do
     sleep 61
     if [ $counter -le 0 ];then
        latest=$(cat ~/BirdNET-Pi/analyzing_now.txt)
        if [ "$latest" = "$analyzing_now" ];then
           echo "$(date) WARNING no change in analyzing_now for 10 iterations, restarting services"
           ~/BirdNET-Pi/scripts/restart_services.sh
        fi
        counter=10
        analyzing_now=$(cat ~/BirdNET-Pi/analyzing_now.txt)
     fi
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
     ((counter-=1))
done

# End
