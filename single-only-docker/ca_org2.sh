#!/bin/bash
#
# Copyright xzp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#

# This script brings up a Hyperledger Fabric network for ca servers.
# The servers consists of two peer organizations services and an orderer 
# organization service. 
#
# prepending $PWD/bin to PATH to ensure we are picking up the correct binaries
# this may be commented out to resolve installed version of tools if desired
export PATH=${PWD}/bin:$PATH

source scripts/scriptUtils.sh

# Do some basic sanity checking to make sure that the appropriate versions of fabric
# binaries/images are available. In the future, additional checking for the presence
# of go or other items could be added.
function checkPrereqs() {
  ## Check for fabric-ca
  fabric-ca-client version > /dev/null 2>&1
  if [[ $? -ne 0 ]]; then
    errorln "fabric-ca-client binary not found.."
    errorln
    errorln "Follow the instructions in the Fabric docs to install the Fabric Binaries:"
    errorln "https://hyperledger-fabric.readthedocs.io/en/latest/install.html"
    exit 1
  fi
  CA_LOCAL_VERSION=$(fabric-ca-client version | sed -ne 's/ Version: //p')
  CA_DOCKER_IMAGE_VERSION=$(docker run --rm hyperledger/fabric-ca:$CA_IMAGETAG fabric-ca-client version | sed -ne 's/ Version: //p' | head -1)
  infoln "CA_LOCAL_VERSION=$CA_LOCAL_VERSION"
  infoln "CA_DOCKER_IMAGE_VERSION=$CA_DOCKER_IMAGE_VERSION"

  if [ "$CA_LOCAL_VERSION" != "$CA_DOCKER_IMAGE_VERSION" ]; then
    warnln "Local fabric-ca binaries and docker images are out of sync. This may cause problems."
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

# Create Organization crypto material using CAs
function createCAs() {
  # Create crypto material using Fabric CAs
  infoln "Generate certificates using Fabric CA's"
  #IMAGE_TAG=${CA_IMAGETAG} docker-compose -f $COMPOSE_FILE_CA up
  docker run --env FABRIC_CA_HOME=/etc/hyperledger/fabric-ca-server --env FABRIC_CA_SERVER_CA_NAME=ca-org2 --env FABRIC_CA_SERVER_TLS_ENABLED=true --env FABRIC_CA_SERVER_PORT=8054 --network docker_produce -p 8054:8054 -v $(pwd)/organizations/fabric-ca/org2/:/etc/hyperledger/fabric-ca-server --name=ca_org2 hyperledger/fabric-ca:latest sh -c 'fabric-ca-server start -b admin:adminpw -d'

  #docker ps 
  #if [ $? -ne 0 ]; then
  #  fatalln "Unable to start network"
  #  exit 1
  #fi

  infoln "Fabric CA servers started."
}

# After we create the org crypto material and the system channel genesis block,
# we can now bring up the peers and ordering service. By default, the base
# file for creating the network is "docker-compose-test-net.yaml" in the ``docker``
# folder. This file defines the environment variables and file mounts that
# point the crypto material and genesis block that were created in earlier.

# Bring up the peer and orderer nodes using docker compose.
function networkUp() {

  checkPrereqs
  # generate artifacts if they don't exist
  createCAs
}

# Tear down running network
function networkDown() {
  # stop cas containers
  infoln "Fabric CA servers stop."
  #docker-compose -f $COMPOSE_FILE_CA stop
}

# Tear down running network
function networkClean() {
infoln "Fabric CA servers clean begin."
  # stop cas containers
  docker-compose -f $COMPOSE_FILE_CA down --volumes --remove-orphans
  # Bring down the network, deleting the volumes
  ## remove fabric ca artifacts
  docker run --rm -v $(pwd):/data hyperledger/fabric-ca sh -c 'cd /data && rm -rf organizations/fabric-ca/org1/msp organizations/fabric-ca/org1/tls-cert.pem organizations/fabric-ca/org1/ca-cert.pem organizations/fabric-ca/org1/IssuerPublicKey organizations/fabric-ca/org1/IssuerRevocationPublicKey organizations/fabric-ca/org1/fabric-ca-server.db'
  docker run --rm -v $(pwd):/data hyperledger/fabric-ca sh -c 'cd /data && rm -rf organizations/fabric-ca/org2/msp organizations/fabric-ca/org2/tls-cert.pem organizations/fabric-ca/org2/ca-cert.pem organizations/fabric-ca/org2/IssuerPublicKey organizations/fabric-ca/org2/IssuerRevocationPublicKey organizations/fabric-ca/org2/fabric-ca-server.db'
  docker run --rm -v $(pwd):/data hyperledger/fabric-ca sh -c 'cd /data && rm -rf organizations/fabric-ca/ordererOrg/msp organizations/fabric-ca/ordererOrg/tls-cert.pem organizations/fabric-ca/ordererOrg/ca-cert.pem organizations/fabric-ca/ordererOrg/IssuerPublicKey organizations/fabric-ca/ordererOrg/IssuerRevocationPublicKey organizations/fabric-ca/ordererOrg/fabric-ca-server.db'
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
# certificate authorities compose file
COMPOSE_FILE_CA=docker/docker-compose-ca.yaml
#
# default ca image tag
CA_IMAGETAG="latest"
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

