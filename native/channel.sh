#!/bin/bash


#export PATH=/home/ubuntu/Desktop/golang/src/github.com/hyperledger/fabric/cmd/peer:$PATH
PWD=`pwd`
export PATH=${PWD}/bin:$PATH

source scripts/scriptUtils.sh

# import utils
. scripts/envVar.sh

if [ ! -d "channel-artifacts" ]; then
    mkdir channel-artifacts
fi

createChannelTx() {
    set -x
    configtxgen -profile TwoOrgsChannel -outputCreateChannelTx ./channel-artifacts/${CHANNEL_NAME}.tx -channelID $CHANNEL_NAME
    res=$?
    { set +x; } 2>/dev/null
    if [ $res -ne 0 ]; then
        fatalln "Failed to generate channel configuration transaction..."
    fi
}

createAncorPeerTx() {
    for orgmsp in Org1MSP Org2MSP; do

    infoln "Generating anchor peer update transaction for ${orgmsp}"
    set -x
    configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/${orgmsp}anchors.tx -channelID $CHANNEL_NAME -asOrg ${orgmsp}
    res=$?
    { set +x; } 2>/dev/null
    if [ $res -ne 0 ]; then
        fatalln "Failed to generate anchor peer update transaction for ${orgmsp}..."
    fi
    done
}

createChannel() {
    setGlobals 1
    # Poll in case the raft leader is not set yet
    local rc=1
    local COUNTER=1
    while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ] ; do
        sleep $DELAY
        set -x
        peer channel create -o localhost:7050 -c $CHANNEL_NAME --ordererTLSHostnameOverride orderer.example.com -f ./channel-artifacts/${CHANNEL_NAME}.tx --outputBlock ./channel-artifacts/${CHANNEL_NAME}.block --tls --cafile $ORDERER_CA >&log.txt
        res=$?
        { set +x; } 2>/dev/null
        let rc=$res
        COUNTER=$(expr $COUNTER + 1)
    done
    cat log.txt
    verifyResult $res "Channel creation failed"
    successln "Channel '$CHANNEL_NAME' created"
}

# queryCommitted ORG
joinChannel() {
  ORG=$1
  setGlobals $ORG
	local rc=1
	local COUNTER=1
	## Sometimes Join takes time, hence retry
	while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ] ; do
    sleep $DELAY
    set -x
    peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block >&log.txt
    res=$?
    { set +x; } 2>/dev/null
		let rc=$res
		COUNTER=$(expr $COUNTER + 1)
	done
	cat log.txt
	verifyResult $res "After $MAX_RETRY attempts, peer0.org${ORG} has failed to join channel '$CHANNEL_NAME' "
}

updateAnchorPeers() {
  ORG=$1
  setGlobals $ORG
	local rc=1
	local COUNTER=1
	## Sometimes Join takes time, hence retry
	while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ] ; do
    sleep $DELAY
    set -x
		peer channel update -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com -c $CHANNEL_NAME -f ./channel-artifacts/${CORE_PEER_LOCALMSPID}anchors.tx --tls --cafile $ORDERER_CA >&log.txt
    res=$?
    { set +x; } 2>/dev/null
		let rc=$res
		COUNTER=$(expr $COUNTER + 1)
	done
	cat log.txt
  verifyResult $res "Anchor peer update failed"
  successln "Anchor peers updated for org '$CORE_PEER_LOCALMSPID' on channel '$CHANNEL_NAME'"
  sleep $DELAY
}

verifyResult() {
    if [ $1 -ne 0 ]; then
        fatalln "$2"
    fi
}

VERBOSE="false"
# another container before giving up
MAX_RETRY=5
# default for delay between commands
DELAY=3
# channel name defaults to "hxyz"
CHANNEL_NAME="hxyz"

export FABRIC_CFG_PATH=${PWD}/config

## Parse mode
if [[ $# -lt 1 ]] ; then
  exit 0
else
  MODE=$1
  shift
fi

# parse flags
while [[ $# -ge 1 ]] ; do
  key="$1"
  case $key in
  -c )
    CHANNEL_NAME="$2"
    shift
    ;;
  -r )
    MAX_RETRY="$2"
    shift
    ;;
  -d )
    DELAY="$2"
    shift
    ;;
  -verbose )
    VERBOSE=true
    shift
    ;;
  * )
    errorln "Unknown flag: $key"
    exit 1
    ;;
  esac
  shift
done

if [ "${MODE}" == "up" ]; then
    infoln "Creating channel '${CHANNEL_NAME}'."
elif [ "${MODE}" == "clean" ]; then
    rm -rf ${PWD}/channel-artifacts ${PWD}/log.txt
    rm -rf ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/*
    rm -rf ${PWD}/organizations/peerOrganizations/org1.example.com/msp/cacerts/* ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt ${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    rm -rf ${PWD}/organizations/peerOrganizations/org2.example.com/msp/cacerts/* ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt ${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
    exit 0
else
    warnln "channel.sh up OR channel.clean"
    exit 1 
fi

## Create channeltx
infoln "Generating channel create transaction '${CHANNEL_NAME}.tx'"
createChannelTx

## Create anchorpeertx
infoln "Generating anchor peer update transactions"
createAncorPeerTx

## Create channel
infoln "Creating channel ${CHANNEL_NAME}"
createChannel

## Join all the peers to the channel
infoln "Join Org1 peers to the channel..."
joinChannel 1
infoln "Join Org2 peers to the channel..."
joinChannel 2

## Set the anchor peers for each org in the channel
infoln "Updating anchor peers for org1..."
updateAnchorPeers 1
infoln "Updating anchor peers for org2..."
updateAnchorPeers 2

successln "Channel successfully joined"

exit 0

