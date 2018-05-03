#!/usr/bin/env bash
set -e

function deploy_challenge {
    local DOMAIN="${1}" TOKEN_FILENAME="${2}" TOKEN_VALUE="${3}"
}

function clean_challenge {
    local DOMAIN="${1}" TOKEN_FILENAME="${2}" TOKEN_VALUE="${3}"
}

function deploy_cert {
    local DOMAIN="${1}" KEYFILE="${2}" CERTFILE="${3}" FULLCHAINFILE="${4}" CHAINFILE="${5}"

    echo $DOMAIN $KEYFILE $CERTFILE $FULLCHAINFILE $CHAINFILE
    security import $KEYFILE -k /Library/Keychains/System.keychain -A || true
    security import $FULLCHAINFILE -k /Library/Keychains/System.keychain || true
    
    siteId=$(serveradmin settings web:customSites | grep "serverName = \"$DOMAIN\"" | awk -F '=' '{print $1}' | grep -E -o '[0-9]+')
    fingerprint=$(openssl x509 -in $CERTFILE -sha1 -noout -fingerprint | awk -F '=' '{print $2}')
    fingerprint=${fingerprint//:/}
    
    oldcert=$(serveradmin settings web:customSites | grep "web:customSites:_array_index:$siteId:sslCertificateIdentifier" | awk -F '=' '{print $2}' | awk -F '"' '{print $2}')
    newcert="$DOMAIN.$fingerprint"
    identifier=$(serveradmin settings web:customSites | grep "web:customSites:_array_index:$siteId:identifier" | awk -F '=' '{print $2}' | awk -F '"' '{print $2}')
    siteIdentifier=$(serveradmin settings web:customSites | grep "web:customSites:_array_index:$siteId:fileName" | awk -F '=' '{print $2}' | awk -F '"' '{print $2}')
    siteIdentifier=$(basename $identifier)
    siteIdentifier=${identifier/.conf/}
    siteIdentifier=${identifier/0000_/}
    siteIdentifier=${identifier/127.0.0.1_/127.0.0.1\\:}
    
    serveradmin settings web:customSites | grep -i certificate
    
    sleep 15 # it takes a while for Server Admin to pick up the new certificate
    
    certupdate replace -c /etc/certificates/$oldcert.cert.pem -C /etc/certificates/$newcert.cert.pem
    
    serveradmin settings web:customSites | grep -i certificate
}

function unchanged_cert {
    local DOMAIN="${1}" KEYFILE="${2}" CERTFILE="${3}" FULLCHAINFILE="${4}" CHAINFILE="${5}"
}

HANDLER=$1
shift

case $HANDLER in
    deploy_challenge|clean_challenge|deploy_cert)
        $HANDLER $@
    ;;
esac
