#!/bin/bash
#
# Copyright xzp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#

# This script brings up a Hyperledger Fabric network for smart contracts
# and applications. The network consists of two organizations with one
# peer each, and a single node Raft ordering service. Users can also use this
# script to create a channel deploy a chaincode on the channel
#
# prepending $PWD/../bin to PATH to ensure we are picking up the correct binaries
# this may be commented out to resolve installed version of tools if desired
export PATH=${PWD}/bin:$PATH
export VERBOSE=false

source scripts/scriptUtils.sh

# Obtain CONTAINER_IDS and remove them
# TODO Might want to make this optional - could clear other containers
# This function is called when you bring a network down
function clearContainers() {
  CONTAINER_IDS=$(docker ps -a | awk '($2 ~ /dev-peer.*/) {print $1}')
  if [ -z "$CONTAINER_IDS" -o "$CONTAINER_IDS" == " " ]; then
    infoln "No containers available for deletion"
  else
    docker rm -f $CONTAINER_IDS
  fi
}

# Delete any images that were generated as a part of this setup
# specifically the following images are often left behind:
# This function is called when you bring the network down
function removeUnwantedImages() {
  DOCKER_IMAGE_IDS=$(docker images | awk '($1 ~ /dev-peer.*/) {print $3}')
  if [ -z "$DOCKER_IMAGE_IDS" -o "$DOCKER_IMAGE_IDS" == " " ]; then
    infoln "No images available for deletion"
  else
    docker rmi -f $DOCKER_IMAGE_IDS
  fi
}

# Do some basic sanity checking to make sure that the appropriate versions of fabric
# binaries/images are available. In the future, additional checking for the presence
# of go or other items could be added.
function checkPrereqs() {
  ## Check if your have cloned the peer binaries and configuration files.
  peer version > /dev/null 2>&1

  if [[ $? -ne 0 || ! -d "config" ]]; then
    errorln "Peer binary and configuration files not found.."
    errorln
    errorln "Follow the instructions in the Fabric docs to install the Fabric Binaries:"
    errorln "https://hyperledger-fabric.readthedocs.io/en/latest/install.html"
    exit 1
  fi
  # use the fabric tools container to see if the samples and binaries match your
  # docker images
  LOCAL_VERSION=$(peer version | sed -ne 's/ Version: //p')
  DOCKER_IMAGE_VERSION=$(docker run --rm hyperledger/fabric-peer:$IMAGETAG peer version | sed -ne 's/ Version: //p' | head -1)

  infoln "LOCAL_VERSION=$LOCAL_VERSION"
  infoln "DOCKER_IMAGE_VERSION=$DOCKER_IMAGE_VERSION"

  if [ "$LOCAL_VERSION" != "$DOCKER_IMAGE_VERSION" ]; then
    warnln "Local fabric binaries and docker images are out of  sync. This may cause problems."
  fi
  
  if [ ! -f "organizations/fabric-ca/org1/tls-cert.pem" ]; then
    mkdir -p organizations/fabric-ca/org1
    warnln "copy 'organizations/fabric-ca/org1/tls-cert.pem' file from fabric ca server 'organizations/fabric-ca/org1/tls-cert.pem'."
    exit 1
  fi
}

# Before you can bring up a network, each organization needs to generate the crypto
# material that will define that organization on the network. Because Hyperledger
# Fabric is a permissioned blockchain, each node and user on the network needs to
# use certificates and keys to sign and verify its actions. In addition, each user
# needs to belong to an organization that is recognized as a member of the network.
# You can use the Cryptogen tool or Fabric CAs to generate the organization crypto
# material.

# By default, the sample network uses cryptogen. Cryptogen is a tool that is
# meant for development and testing that can quickly create the certificates and keys
# that can be consumed by a Fabric network. The cryptogen tool consumes a series
# of configuration files for each organization in the "organizations/cryptogen"
# directory. Cryptogen uses the files to generate the crypto  material for each
# org in the "organizations" directory.

# You can also Fabric CAs to generate the crypto material. CAs sign the certificates
# and keys that they generate to create a valid root of trust for each organization.
# The script uses Docker Compose to bring up three CAs, one for each peer organization
# and the ordering organization. The configuration file for creating the Fabric CA
# servers are in the "organizations/fabric-ca" directory. Within the same directory,
# the "registerEnroll.sh" script uses the Fabric CA client to create the identities,
# certificates, and MSP folders that are needed to create the network in the
# "organizations/ordererOrganizations" directory.

# Create Organization crypto material using cryptogen or CAs
function createOrgs() {

  if [ -d "organizations/peerOrganizations/org1.example.com" ]; then
    rm -Rf organizations/peerOrganizations/org1.example.com
  fi
  
  . scripts/peer0org1RegisterEnroll.sh

  infoln "Create Org Identities"
  createOrg
    
  infoln "Generate CCP files for Org"
  ./organizations/ccp-generate.sh
}

# After we create the org crypto material and the system channel genesis block,
# we can now bring up the peers and ordering service. By default, the base
# file for creating the network is "docker-compose-produce-net.yaml" in the ``docker``
# folder. This file defines the environment variables and file mounts that
# point the crypto material and genesis block that were created in earlier.

# Bring up the peer and orderer nodes using docker compose.
function networkUp() {

  checkPrereqs
  # generate artifacts if they don't exist
  if [ ! -d "organizations/peerOrganizations/org1.example.com" ]; then
    createOrgs
  fi

  #COMPOSE_FILES="-f ${COMPOSE_FILE_BASE}"

  #if [ "${DATABASE}" == "couchdb" ]; then
  #  COMPOSE_FILES="${COMPOSE_FILES} -f ${COMPOSE_FILE_COUCH}"
  #fi

  #IMAGE_TAG=$IMAGETAG docker-compose ${COMPOSE_FILES} up
  docker run --env CORE_VM_ENDPOINT=unix:///host/var/run/docker.sock --env CORE_VM_DOCKER_HOSTCONFIG_NETWORKMODE=docker_produce --env FABRIC_LOGGING_SPEC=INFO --env CORE_PEER_TLS_ENABLED=true --env CORE_PEER_PROFILE_ENABLED=true --env CORE_PEER_TLS_CERT_FILE=/etc/hyperledger/fabric/tls/server.crt --env CORE_PEER_TLS_KEY_FILE=/etc/hyperledger/fabric/tls/server.key --env CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/tls/ca.crt --env CORE_PEER_ID=peer0.org1.example.com --env CORE_PEER_ADDRESS=peer0.org1.example.com:7051 --env CORE_PEER_LISTENADDRESS=0.0.0.0:7051 --env CORE_PEER_CHAINCODEADDRESS=peer0.org1.example.com:7052 --env CORE_PEER_CHAINCODELISTENADDRESS=0.0.0.0:7052 --env CORE_PEER_GOSSIP_BOOTSTRAP=peer0.org1.example.com:7051 --env CORE_PEER_GOSSIP_EXTERNALENDPOINT=peer0.org1.example.com:7051 --env CORE_PEER_LOCALMSPID=Org1MSP --network docker_produce -p 7051:7051 -v /var/run/:/host/var/run/ -v $(pwd)/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/msp:/etc/hyperledger/fabric/msp -v $(pwd)/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls:/etc/hyperledger/fabric/tls -v $(pwd)/peer0.org1.example.com:/var/hyperledger/production -w /opt/gopath/src/github.com/hyperledger/fabric/peer --name=peer0.org1.example.com hyperledger/fabric-peer:latest peer node start

  #docker ps
  #if [ $? -ne 0 ]; then
  #  fatalln "Unable to start network"
  #fi
}

# Tear down running network
function networkDown() {
  # stop cas containers
  infoln "Fabric CA servers stop."
  #docker-compose -f $COMPOSE_FILE_BASE stop
  #Cleanup the chaincode containers
  clearContainers
  #Cleanup images
  removeUnwantedImages
}

# Tear clean running network
function networkClean() {
  # stop org3 containers also in addition to org
  # docker-compose -f $COMPOSE_FILE_BASE -f $COMPOSE_FILE_COUCH down --volumes --remove-orphans
  docker-compose -f $COMPOSE_FILE_BASE down --volumes --remove-orphans
  # Bring down the network, deleting the volumes
  #Cleanup the chaincode containers
  clearContainers
  #Cleanup images
  removeUnwantedImages
  # remove orderer block and other channel configuration transactions and certs
  docker run --rm -v $(pwd):/data hyperledger/fabric-peer sh -c 'cd /data && rm -rf organizations/peerOrganizations organizations/fabric-ca/org1/tls-cert.pem'
}

# Obtain the OS and Architecture string that will be used to select the correct
# native binaries for your platform, e.g., darwin-amd64 or linux-amd64
OS_ARCH=$(echo "$(uname -s | tr '[:upper:]' '[:lower:]' | sed 's/mingw64_nt.*/windows/')-$(uname -m | sed 's/x86_64/amd64/g')" | awk '{print tolower($0)}')
# Using crpto vs CA. default is cryptogen
CRYPTO="Certificate Authorities"
# timeout duration - the duration the CLI should wait for a response from
# another container before giving up
MAX_RETRY=5
# default for delay between commands
CLI_DELAY=3
# use this as the default docker-compose yaml definition
COMPOSE_FILE_BASE=docker/docker-compose-org1-produce-net.yaml
# docker-compose.yaml file if you are using couchdb
COMPOSE_FILE_COUCH=docker/docker-compose-couch.yaml
#
# default image tag
IMAGETAG="latest"
# default database
DATABASE="leveldb"

# Parse commandline args

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
  -s )
    DATABASE="$2"
    shift
    ;;
  -i )
    IMAGETAG="$2"
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

# Are we generating crypto material with this command?
if [ ! -d "organizations/peerOrganizations" ]; then
  CRYPTO_MODE="with crypto from '${CRYPTO}'"
else
  CRYPTO_MODE=""
fi

# Determine mode of operation and printing out what we asked for
if [ "$MODE" == "up" ]; then
  infoln "Starting nodes with CLI timeout of '${MAX_RETRY}' tries and CLI delay of '${CLI_DELAY}' seconds and using database '${DATABASE}' '${CRYPTO_MODE}'"
elif [ "$MODE" == "down" ]; then
  infoln "Stopping network"
elif [ "$MODE" == "clean" ]; then
  infoln "Clean network"
else
  exit 1
fi

if [ "${MODE}" == "up" ]; then
  networkUp
elif [ "${MODE}" == "down" ]; then
  networkDown
elif [ "${MODE}" == "clean" ]; then
  networkClean
else
  exit 1
fi
