# /bin/bash

export PATH=${PWD}/bin:$PATH
export FABRIC_CFG_PATH=$PWD/peer0.org1.example.com

if [ -d "./organizations/peerOrganizations/org1.example.com" ]; then
    rm -Rf ./organizations/peerOrganizations/org1.example.com
fi

. ./scripts/peer0org1RegisterEnroll.sh

infoln "Create Org Identities"
createOrg

infoln "Generate CCP files for Org"
./organizations/peer0org1-ccp-generate.sh

#Generic peer variables
#CORE_VM_ENDPOINT=unix:///host/var/run/docker.sock
# the following setting starts chaincode containers on the same
# bridge network as the peers
# https://docs.docker.com/compose/networking/
#export CORE_VM_DOCKER_HOSTCONFIG_NETWORKMODE=net_produce
export FABRIC_LOGGING_SPEC=INFO
#- FABRIC_LOGGING_SPEC=DEBUG
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_PROFILE_ENABLED=true
export CORE_PEER_TLS_CERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.crt
export CORE_PEER_TLS_KEY_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.key
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt

# Peer specific variabes
export CORE_PEER_ID=peer0.org1.example.com
export CORE_PEER_ADDRESS=peer0.org1.example.com:7051
export CORE_PEER_LISTENADDRESS=0.0.0.0:7051
export CORE_PEER_CHAINCODEADDRESS=peer0.org1.example.com:7052
export CORE_PEER_CHAINCODELISTENADDRESS=0.0.0.0:7052
export CORE_PEER_GOSSIP_BOOTSTRAP=peer0.org1.example.com:7051
export CORE_PEER_GOSSIP_EXTERNALENDPOINT=peer0.org1.example.com:7051
export CORE_PEER_LOCALMSPID=Org1MSP

export CORE_PEER_PROFILE_LISTENADDRESS=0.0.0.0:6060

export CORE_OPERATIONS_LISTENADDRESS=127.0.0.1:9443

export CORE_PEER_FILESYSTEMPATH=${PWD}/peer0.org1.example.com/hyperledger/production

export CORE_LEDGER_SNAPSHOTS_ROOTDIR=${PWD}/peer0.org1.example.com/hyperledger/production/snapshots

infoln "env set end"

mv ${FABRIC_CFG_PATH}/msp ${FABRIC_CFG_PATH}/msp_back
cp -rf organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/msp ${FABRIC_CFG_PATH}
cp -rf organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls ${FABRIC_CFG_PATH}

peer node start
