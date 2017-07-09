#!/bin/bash

site_ids=$(serveradmin settings web:customSites | grep ':serverName = ' | awk -F '=' '{print $1}' | grep -E -o '[0-9]+')
for site_id in $site_ids; do
	certificate=$(serveradmin settings web:customSites | grep "web:customSites:_array_index:$site_id:sslCertificateIdentifier" | awk -F '=' '{print $2}' | awk -F '"' '{print $2}')
	if [ "$certificate" = "" ]; then
		continue
	fi
	
	serverName=$(serveradmin settings web:customSites | grep "web:customSites:_array_index:$site_id:serverName" | awk -F '=' '{print $2}' | awk -F '"' '{print $2}')
	serverAliases=$(serveradmin settings web:customSites | grep "web:customSites:_array_index:$site_id:serverAlias" | awk -F '=' '{print $2}' | awk -F '"' '{print $2}')
	documentRoot=$(serveradmin settings web:customSites | grep "web:customSites:_array_index:$site_id:documentRoot" | awk -F '=' '{print $2}' | awk -F '"' '{print $2}')
	
	echo $serverName $serverAliases $certificate $documentRoot
	
	BASEDIR=$(dirname $0)/dehydrated
	if [ "${BASEDIR:0:1}" = "." ]; then
		BASEDIR=$(pwd)/$BASEDIR
	fi
	
	WELLKNOWN="$documentRoot/.well-known/acme-challenge"
	mkdir -p $WELLKNOWN
	
	echo "WELLKNOWN=$WELLKNOWN; BASEDIR=$BASEDIR" > config
	
	CMD=$(dirname $0)/dehydrated/dehydrated
	PARAMS="--cron --hook $(dirname $0)/hooks.sh --domain $serverName"
	for dom in $serverAliases; do
		PARAMS="$PARAMS --domain $dom"
	done
	
	$CMD $* $PARAMS
done
