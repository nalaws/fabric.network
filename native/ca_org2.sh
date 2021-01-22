# /bin/bash

export PATH=${PWD}/bin:$PATH

export  FABRIC_CA_HOME=organizations/fabric-ca/org2
export  FABRIC_CA_SERVER_CA_NAME=ca-org2
export  FABRIC_CA_SERVER_TLS_ENABLED=true
export  FABRIC_CA_SERVER_PORT=8054
      
fabric-ca-server start -b admin:adminpw -d
