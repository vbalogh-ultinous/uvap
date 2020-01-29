#!/bin/sh
DEMOMODE=${1-"base"}
echo $DEMOMODE
docker rm -f uvap_mgr uvap_kafka_tracker uvap_demo_applications uvap_web_player
echo ""
#echo ==[kafka, zookeeper]====================
docker network create uvap
#docker run --net=uvap -d --name=zookeeper -e ZOOKEEPER_CLIENT_PORT=2181 confluentinc/cp-zookeeper:4.1.0
 
#docker run --net=uvap -d -p 9092:9092 --name=kafka \
#   -e KAFKA_ZOOKEEPER_CONNECT=zookeeper:2181 \
#   -e KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://kafka:9092 \
#   -e KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR=1 \
#   -e KAFKA_MESSAGE_MAX_BYTES=10485760 \
#   -e ZOOKEEPER_CLIENT_PORT=2181 confluentinc/cp-kafka:4.1.0

#echo -----------------------------------------
#echo docker container inspect: zookeeper # kafka
#docker container inspect --format '{{.State.Status}}' zookeeper # kafka
  
echo ""
echo ==[config.sh]============================
#  --stream-uri rtsp://admin:Csirkepissok1@10.25.38.117:554/live1.sdp \
#  --stream-uri rtsp://admin:Csirkepissok1@10.25.38.118:554/live1.sdp \
#  --stream-uri rtsp://10.25.34.111:5010/regstream.avi \  
#  --stream-uri /home/uvap/szeged2_split_left.avi
"${UVAP_HOME}"/scripts/config.sh --stream-uri rtsp://freddie:5109/162_original.avi --demo-mode $DEMOMODE

echo ""
echo ==[run_mgr.sh]===========================
#/home/vbalogh/git/uvap/scripts/run_mgr.sh --license-data-file /home/vbalogh/git/uvap/mgr.txt --license-key-file /home/vbalogh/git/uvap/mgr.key -- --net=uvap --mount type=bind,readonly,src=/home/vbalogh/Documents/data/tracking/SzegedVideo/szeged2_split_left.avi,dst=/home/uvap/szeged2_split_left.avi
"${UVAP_HOME}"/scripts/run_mgr.sh --license-data-file license/mgr.txt --license-key-file license/mgr.key -- --net=uvap

echo -----------------------------------------
docker container inspect --format '{{.State.Status}}' uvap_mgr

echo ""
echo ==[run_kafka_tracker.sh]===========================
"${UVAP_HOME}"/scripts/run_kafka_tracker.sh -- --net=uvap
echo ----------------------------------------- 
docker container inspect --format '{{.State.Status}}' uvap_kafka_tracker



echo -----------------------------------------
echo created topics:
kafka-topics --list --zookeeper localhost


echo ""
echo =[run_demo.sh]===========================
"${UVAP_HOME}"/scripts/run_demo.sh --demo-name tracker \
  --demo-mode $DEMOMODE -- --net uvap
#/home/vbalogh/git/uvap/scripts/run_demo.sh  --demo-name tracker \
#  --demo-mode base \
#  --demo-applications-dir "$HOME/UVAP/dlservice/python" \
#  -- --net uvap 
# pass detector:
# "${UVAP_HOME}"/scripts/run_demo.sh  --demo-name pass_detection --demo-mode base --config-file-name ${UVAP_HOME}/config/uvap_kafka_passdet/uvap_kafka_passdet.properties  --demo-applications-dir $HOME/UVAP/dlservice/python -- --net uvap

  
echo ----------------------------------------- 
  
echo ""
echo =[run_web_player.sh]=====================  
"${UVAP_HOME}"/scripts/run_uvap_web_player.sh -- --net uvap
echo -----------------------------------------
docker container inspect --format '{{.State.Status}}' uvap_web_player
echo -----------------------------------------
echo created topics:
kafka-topics --list --zookeeper localhost

echo ""
echo ==[Setting retention time]===========================
"${UVAP_HOME}"/scripts/set_retention.sh --retention-unit minute \
  --retention-number 15
 
echo =========================================
echo ""
echo ""
echo ""
echo http://localhost:9999$DEMOMODE.cam.0.tracker.Image.jpg
echo ""
echo ""
echo ""
echo created topics:
docker container inspect --format '{{.State.Status}}' uvap_mgr uvap_kafka_tracker uvap_demo_applications uvap_web_player
