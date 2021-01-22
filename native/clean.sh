# /bin/bash

rm -rf channel-artifacts
rm -rf system-genesis-block
rm -rf peer
rm -rf organizations/ordererOrganizations
rm -rf organizations/peerOrganizations

rm -rf organizations/fabric-ca/ordererOrg/msp
rm -rf organizations/fabric-ca/ordererOrg/ca-cert.pem
rm -rf organizations/fabric-ca/ordererOrg/fabric-ca-server.db
rm -rf organizations/fabric-ca/ordererOrg/IssuerPublicKey
rm -rf organizations/fabric-ca/ordererOrg/IssuerRevocationPublicKey
rm -rf organizations/fabric-ca/ordererOrg/tls-cert.pem

rm -rf organizations/fabric-ca/org1/msp
rm -rf organizations/fabric-ca/org1/ca-cert.pem
rm -rf organizations/fabric-ca/org1/fabric-ca-server.db
rm -rf organizations/fabric-ca/org1/IssuerPublicKey
rm -rf organizations/fabric-ca/org1/IssuerRevocationPublicKey
rm -rf organizations/fabric-ca/org1/tls-cert.pem

rm -rf organizations/fabric-ca/org2/msp
rm -rf organizations/fabric-ca/org2/ca-cert.pem
rm -rf organizations/fabric-ca/org2/fabric-ca-server.db
rm -rf organizations/fabric-ca/org2/IssuerPublicKey
rm -rf organizations/fabric-ca/org2/IssuerRevocationPublicKey
rm -rf organizations/fabric-ca/org2/tls-cert.pem

rm -rf orderer.example.com/hyperledger/production
rm -rf orderer.example.com/msp
rm -rf orderer.example.com/tls
rm -rf orderer.example.com/orderer.genesis.block
mv orderer.example.com/msp_back orderer.example.com/msp


rm -rf peer0.org1.example.com/hyperledger/production
rm -rf peer0.org1.example.com/msp
rm -rf peer0.org1.example.com/tls
mv peer0.org1.example.com/msp_back peer0.org1.example.com/msp

rm -rf peer0.org2.example.com/hyperledger/production
rm -rf peer0.org2.example.com/msp
rm -rf peer0.org2.example.com/tls
mv peer0.org2.example.com/msp_back peer0.org2.example.com/msp

rm -rf log.txt
rm *.tar.gz
rm -rf channel-artifacts
rm -rf system-genesis-block/*
