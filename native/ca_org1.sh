# /bin/bash

export PATH=${PWD}/bin:$PATH
export  FABRIC_CA_HOME=organizations/fabric-ca/org1
export  FABRIC_CA_SERVER_CA_NAME=ca-org1
export  FABRIC_CA_SERVER_TLS_ENABLED=true
export  FABRIC_CA_SERVER_PORT=7054
      
fabric-ca-server start -b admin:adminpw -d
