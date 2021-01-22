# /bin/bash

export PATH=${PWD}/bin:$PATH
export FABRIC_CFG_PATH=$PWD/orderer.example.com

function createOrgs() {
    if [ -d "organizations/ordererOrganizations" ]; then
        rm -Rf organizations/ordererOrganizations
    fi
  
    . scripts/ordererRegisterEnroll.sh

    infoln "Create Orderer Org Identities"
    createOrderer
}

# Generate orderer system channel genesis block.
function createConsortium() {
    which configtxgen
    if [ "$?" -ne 0 ]; then
        fatalln "configtxgen tool not found."
    fi
    
    infoln "Generating Orderer Genesis block"

    # Note: For some unknown reason (at least for now) the block file can't be
    # named orderer.genesis.block or the orderer will fail to launch!
    set -x
    configtxgen -profile TwoOrgsOrdererGenesis -channelID system-channel -outputBlock ./system-genesis-block/genesis.block
    res=$?
    { set +x; } 2>/dev/null
    if [ $res -ne 0 ]; then
        fatalln "Failed to generate orderer genesis block..."
    fi
}

if [ ! -d "organizations/ordererOrganizations" ]; then
    createOrgs
    createConsortium
fi

export FABRIC_LOGGING_SPEC=INFO
export ORDERER_GENERAL_LISTENADDRESS=0.0.0.0
export ORDERER_GENERAL_LISTENPORT=7050
export ORDERER_GENERAL_GENESISMETHOD=file
export ORDERER_GENERAL_GENESISFILE=${PWD}/system-genesis-block/genesis.block
export ORDERER_GENERAL_LOCALMSPID=OrdererMSP
export ORDERER_GENERAL_LOCALMSPDIR=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp

# enabled TLS
export ORDERER_GENERAL_TLS_ENABLED=true
export ORDERER_GENERAL_TLS_PRIVATEKEY=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.key
export ORDERER_GENERAL_TLS_CERTIFICATE=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.crt
export ORDERER_GENERAL_TLS_ROOTCAS=[${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt]
export ORDERER_KAFKA_TOPIC_REPLICATIONFACTOR=1
export ORDERER_KAFKA_VERBOSE=true
export ORDERER_GENERAL_CLUSTER_CLIENTCERTIFICATE=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.crt
export ORDERER_GENERAL_CLUSTER_CLIENTPRIVATEKEY=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.key
export ORDERER_GENERAL_CLUSTER_ROOTCAS=[${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt]

export ORDERER_FILELEDGER_LOCATION=${PWD}/orderer.example.com/hyperledger/production
export ORDERER_CONSENSUS_WALDIR=${PWD}/orderer.example.com/hyperledger/production/orderer/etcdraft/wal
export ORDERER_CONSENSUS_SNAPDIR=${PWD}/orderer.example.com/hyperledger/production/orderer/etcdraft/snapshot

export ORDERER_ADMIN_LISTENADDRESS=127.0.0.1:9343

infoln "env set end"

mv ${FABRIC_CFG_PATH}/msp ${FABRIC_CFG_PATH}/msp_back
cp -rf system-genesis-block/genesis.block ${FABRIC_CFG_PATH}/orderer.genesis.block
cp -rf organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp ${FABRIC_CFG_PATH}/
cp -rf organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls ${FABRIC_CFG_PATH}/

orderer
