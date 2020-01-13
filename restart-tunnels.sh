#!/bin/bash
CONFIGPATH="/root/.ssh"
CONFIG_JSON="/config/config.json"
SOURCEPATH="/config"

echo ""
echo "AutoSSH tunnel container restarting tunnels on $(date "+%Y-%m-%d %H:%M:%S")"

echo ""
echo "--- Killing all instances of AutoSSH if running ---"
killall autossh
echo "    ... done."

echo ""
echo "--- Deleting old ssh config file and certs ---"
rm -rf $CONFIGPATH

mkdir $CONFIGPATH
mkdir $CONFIGPATH/certs

echo "    ... done."

TUNNELCOUNT=$(($(jq '. | length' $CONFIG_JSON) - 1))

ACTIVEPROFILES='[]'

echo ""
echo "--- Generating new ssh config file - found $((TUNNELCOUNT+1)) profiles ---"
for i in $(seq 0 $TUNNELCOUNT)
	do
	TUNNELNAME=$(jq -r ".[$i].tunnelName" $CONFIG_JSON)
	TUNNELNAME=${TUNNELNAME//' '/'-'} #replace spaces with dashes
	SSH_HOSTNAME=$(jq -r ".[$i].sshHostName" $CONFIG_JSON)
	SSH_PORT=$(jq -r ".[$i].sshPort" $CONFIG_JSON)
	SSH_USERNAME=$(jq -r ".[$i].sshUsername" $CONFIG_JSON)
	SSH_KEYFILE=$(jq -r ".[$i].sshPrivateKeyFile" $CONFIG_JSON)
	#TUNNEL_DESTINATION=$(jq -r ".[$i].tunnelDestination" $CONFIG_JSON)
	#TUNNEL_LOCAL_PORT=$(jq -r ".[$i].tunnelLocalPort" $CONFIG_JSON)
	TCP_FORWARD_COUNT=$(( $(jq -r ".[$i].tunnels | length" $CONFIG_JSON) - 1))

	echo ""
	echo "    - Generating profile '$TUNNELNAME'"
	cp $SOURCEPATH/$SSH_KEYFILE $CONFIGPATH/certs/
	if [ $? -eq 0 ]
		then
		echo "Host $TUNNELNAME" >>$CONFIGPATH/config
		echo "    HostName      $SSH_HOSTNAME" >>$CONFIGPATH/config
		echo "    User          $SSH_USERNAME" >>$CONFIGPATH/config
		echo "    Port          $SSH_PORT" >>$CONFIGPATH/config
		echo "    IdentityFile  $CONFIGPATH/certs/$SSH_KEYFILE" >>$CONFIGPATH/config
		for j in $(seq 0 $TCP_FORWARD_COUNT)
			do
			TUNNEL_LOCAL_PORT=$(jq -r ".[$i].tunnels[$j].localPort" $CONFIG_JSON)
			TUNNEL_DESTINATION=$(jq -r ".[$i].tunnels[$j].destination" $CONFIG_JSON)
			echo "    LocalForward  0.0.0.0:$TUNNEL_LOCAL_PORT $TUNNEL_DESTINATION" >>$CONFIGPATH/config
		done
		echo "    StrictHostKeyChecking no" >>$CONFIGPATH/config
		echo "" >>$CONFIGPATH/config

		TEMPJSON=$(echo $ACTIVEPROFILES | jq ". + [ \"$TUNNELNAME\" ]")
		ACTIVEPROFILES=$TEMPJSON

		echo "     ... success."
	else
		echo "     ERROR! Private key '$SSH_KEYFILE' not found, skipping profile '$TUNNELNAME'"
	fi
done


echo ""
echo "--- Updating file permissions ---"
chmod 700 $CONFIGPATH
chmod 700 $CONFIGPATH/certs
chmod 600 $CONFIGPATH/certs/*
echo "    ... done."


PROFILECOUNT=$(echo $ACTIVEPROFILES | jq '. | length')
echo ""
echo "--- Starting SSH tunnels ($PROFILECOUNT active profiles) ---"
PROFILECOUNT=$(($PROFILECOUNT - 1))
for i in $(seq 0 $PROFILECOUNT) 
	do
	THISPROFILE=$(echo $ACTIVEPROFILES | jq -r ".[$i]")
	autossh -M 0 -f -T -N $THISPROFILE
	echo "    - [$(($i+1))] Started AutoSSH for profile '$THISPROFILE'"
done

echo ""
sleep 5 && echo "All Finished on $(date "+%Y-%m-%d %H:%M:%S")"

echo ""
echo "Available local ports:"
echo "----------------------"
netstat -tlnp
echo ""
