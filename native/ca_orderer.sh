# /bin/bash

export PATH=${PWD}/bin:$PATH

export  FABRIC_CA_HOME=organizations/fabric-ca/ordererOrg
export  FABRIC_CA_SERVER_CA_NAME=ca-orderer
export  FABRIC_CA_SERVER_TLS_ENABLED=true
export  FABRIC_CA_SERVER_PORT=9054
      
fabric-ca-server start -b admin:adminpw -d
