# fabric network

fabric 多设备组网

## 环境准备
1、设备1：准备fabric-ca镜像, 获取IP，例如：10.0.0.1
2、设备2：准备fabric-peer镜像, 获取IP，例如：10.0.0.2
3、设备3：准备fabric-peer镜像, 获取IP，例如：10.0.0.3
4、设备4：准备fabric-orderer镜像, 获取IP，例如：10.0.0.4

### 配置hosts
设备2
```
10.0.0.1	org1.example.com
10.0.0.2	peer0.org1.example.com
10.0.0.3    peer0.org2.example.com
10.0.0.4	orderer.example.com
```

设备3
```
10.0.0.1	org2.example.com
10.0.0.2	peer0.org1.example.com
10.0.0.3    peer0.org2.example.com
10.0.0.4	orderer.example.com
```

设备4
```
10.0.0.1	example.com
10.0.0.2	peer0.org1.example.com
10.0.0.3    peer0.org2.example.com
10.0.0.4	orderer.example.com
```

## 启动

### 启动ca服务
```
./ca.sh up
```
导出其他节点相关的文件
```
mkdir -p all.ca/organizations/fabric-ca/ordererOrg all.ca/organizations/fabric-ca/org1 all.ca/organizations/fabric-ca/org2
cp golang/src/archive/network/single/organizations/fabric-ca/ordererOrg/tls-cert.pem all.ca/organizations/fabric-ca/ordererOrg/
cp golang/src/archive/network/single/organizations/fabric-ca/org1/tls-cert.pem all.ca/organizations/fabric-ca/org1/
cp golang/src/archive/network/single/organizations/fabric-ca/org2/tls-cert.pem all.ca/organizations/fabric-ca/org2/
```

### 启动组织1节点peer0
导入ca证书
```
rm -rf golang/src/archive/network/single/organizations/fabric-ca/org1/tls-cert.pem
rm -rf golang/src/archive/network/single/organizations/fabric-ca/org2/tls-cert.pem
rm -rf golang/src/archive/network/single/organizations/fabric-ca/ordererOrg/tls-cert.pem

cp all.ca/organizations/fabric-ca/org1/tls-cert.pem golang/src/archive/network/single/organizations/fabric-ca/org1/
cp all.ca/organizations/fabric-ca/org2/tls-cert.pem golang/src/archive/network/single/organizations/fabric-ca/org2/
cp all.ca/organizations/fabric-ca/ordererOrg/tls-cert.pem golang/src/archive/network/single/organizations/fabric-ca/ordererOrg/
```
启动
```
./peer0.org1.sh up
```
导出orderer节点和部署channel需要的文件
```
rm -rf orderer.org1
mkdir -p orderer.org1/organizations/peerOrganizations/org1.example.com/ca orderer.org1/organizations/peerOrganizations/org1.example.com/msp/cacerts orderer.org1/organizations/peerOrganizations/org1.example.com/msp/tlscacerts
cp golang/src/archive/network/single/organizations/peerOrganizations/org1.example.com/ca/ca.org1.example.com-cert.pem orderer.org1/organizations/peerOrganizations/org1.example.com/ca/
cp golang/src/archive/network/single/organizations/peerOrganizations/org1.example.com/msp/cacerts/org1-example-com-7054-ca-org1.pem orderer.org1/organizations/peerOrganizations/org1.example.com/msp/cacerts/
cp golang/src/archive/network/single/organizations/peerOrganizations/org1.example.com/msp/tlscacerts/ca.crt orderer.org1/organizations/peerOrganizations/org1.example.com/msp/tlscacerts/
cp golang/src/archive/network/single/organizations/peerOrganizations/org1.example.com/msp/config.yaml orderer.org1/organizations/peerOrganizations/org1.example.com/msp/

rm -rf channel.org1
mkdir -p channel.org1/organizations/peerOrganizations/org1.example.com/msp/cacerts channel.org1/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls channel.org1/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com
cp -rf golang/src/archive/network/single/organizations/peerOrganizations/org1.example.com/msp/cacerts/org1-example-com-7054-ca-org1.pem channel.org1/organizations/peerOrganizations/org1.example.com/msp/cacerts/
cp -rf golang/src/archive/network/single/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt channel.org1/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/
cp -rf golang/src/archive/network/single/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp channel.org1/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/
```

### 启动组织2节点peer0
导入ca证书
```
rm -rf golang/src/archive/network/single/organizations/fabric-ca/org1/tls-cert.pem
rm -rf golang/src/archive/network/single/organizations/fabric-ca/org2/tls-cert.pem
rm -rf golang/src/archive/network/single/organizations/fabric-ca/ordererOrg/tls-cert.pem

cp -rf all.ca/organizations/fabric-ca/org1/tls-cert.pem golang/src/archive/network/single/organizations/fabric-ca/org1/
cp -rf all.ca/organizations/fabric-ca/org2/tls-cert.pem golang/src/archive/network/single/organizations/fabric-ca/org2/
cp -rf all.ca/organizations/fabric-ca/ordererOrg/tls-cert.pem golang/src/archive/network/single/organizations/fabric-ca/ordererOrg/
```
启动
```
./peer0.org2.sh up
```
导出orderer节点和部署channel需要的文件
```
rm -rf orderer.org2
mkdir -p orderer.org2/organizations/peerOrganizations/org2.example.com/ca orderer.org2/organizations/peerOrganizations/org2.example.com/msp/cacerts orderer.org2/organizations/peerOrganizations/org2.example.com/msp/tlscacerts
cp golang/src/archive/network/single/organizations/peerOrganizations/org2.example.com/ca/ca.org2.example.com-cert.pem orderer.org2/organizations/peerOrganizations/org2.example.com/ca/
cp golang/src/archive/network/single/organizations/peerOrganizations/org2.example.com/msp/cacerts/org2-example-com-8054-ca-org2.pem orderer.org2/organizations/peerOrganizations/org2.example.com/msp/cacerts/
cp golang/src/archive/network/single/organizations/peerOrganizations/org2.example.com/msp/tlscacerts/ca.crt orderer.org2/organizations/peerOrganizations/org2.example.com/msp/tlscacerts/
cp golang/src/archive/network/single/organizations/peerOrganizations/org2.example.com/msp/config.yaml orderer.org2/organizations/peerOrganizations/org2.example.com/msp/

rm -rf channel.org2
mkdir -p channel.org2/organizations/peerOrganizations/org2.example.com/msp/cacerts channel.org2/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls channel.org2/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
cp -rf golang/src/archive/network/single/organizations/peerOrganizations/org2.example.com/msp/cacerts/org2-example-com-8054-ca-org2.pem channel.org2/organizations/peerOrganizations/org2.example.com/msp/cacerts/
cp -rf golang/src/archive/network/single/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt channel.org2/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/
cp -rf golang/src/archive/network/single/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp channel.org2/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/
```

### 启动orderer服务
导入ca、所有组织peer的相关文件
```
rm -rf golang/src/archive/network/single/organizations/fabric-ca/org1/tls-cert.pem
rm -rf golang/src/archive/network/single/organizations/fabric-ca/org2/tls-cert.pem
rm -rf golang/src/archive/network/single/organizations/fabric-ca/ordererOrg/tls-cert.pem

cp -rf all.ca/organizations/fabric-ca/org1/tls-cert.pem golang/src/archive/network/single/organizations/fabric-ca/org1/
cp -rf all.ca/organizations/fabric-ca/org2/tls-cert.pem golang/src/archive/network/single/organizations/fabric-ca/org2/
cp -rf all.ca/organizations/fabric-ca/ordererOrg/tls-cert.pem golang/src/archive/network/single/organizations/fabric-ca/ordererOrg/

rm -rf golang/src/archive/network/single/organizations/peerOrganizations/org1.example.com golang/src/archive/network/single/organizations/peerOrganizations/org2.example.com
mkdir -p golang/src/archive/network/single/organizations/peerOrganizations
cp -rf orderer.org1/organizations/peerOrganizations/org1.example.com golang/src/archive/network/single/organizations/peerOrganizations/
cp -rf orderer.org2/organizations/peerOrganizations/org2.example.com golang/src/archive/network/single/organizations/peerOrganizations/
```
启动
```
./orderer.sh up
```
导出channel需要的文件
```
rm -rf channel.orderer
mkdir -p channel.orderer/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts
cp -rf golang/src/archive/network/single/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem channel.orderer/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/
```

### 创建通道和部署合约
导入ca、所有组织peer、orderer的相关文件
```
rm -rf golang/src/archive/network/single/organizations/fabric-ca/org1/tls-cert.pem
rm -rf golang/src/archive/network/single/organizations/fabric-ca/org2/tls-cert.pem
rm -rf golang/src/archive/network/single/organizations/fabric-ca/ordererOrg/tls-cert.pem
mkdir -p golang/src/archive/network/single/organizations/fabric-ca/org1 golang/src/archive/network/single/organizations/fabric-ca/org2 golang/src/archive/network/single/organizations/fabric-ca/ordererOrg
cp -rf all.ca/organizations/fabric-ca/org1/tls-cert.pem golang/src/archive/network/single/organizations/fabric-ca/org1/
cp -rf all.ca/organizations/fabric-ca/org2/tls-cert.pem golang/src/archive/network/single/organizations/fabric-ca/org2/
cp -rf all.ca/organizations/fabric-ca/ordererOrg/tls-cert.pem golang/src/archive/network/single/organizations/fabric-ca/ordererOrg/

rm -rf golang/src/archive/network/single/organizations/peerOrganizations/org1.example.com 
mkdir -p golang/src/archive/network/single/organizations/peerOrganizations
cp -rf channel.org1/organizations/peerOrganizations/org1.example.com golang/src/archive/network/single/organizations/peerOrganizations/

rm -rf golang/src/archive/network/single/organizations/peerOrganizations/org2.example.com
mkdir -p golang/src/archive/network/single/organizations/peerOrganizations
cp -rf channel.org2/organizations/peerOrganizations/org2.example.com golang/src/archive/network/single/organizations/peerOrganizations/

rm -rf golang/src/archive/network/single/organizations/ordererOrganizations
cp -rf channel.orderer/organizations/ordererOrganizations golang/src/archive/network/single/organizations/
```
创建channel
```
./channel.sh up -c hxyz
```
部署合约
```
./chaincode.sh deploy -c hxyz -ccn archive -ccp ../../chaincode-go/ -cccg ../../chaincode-go/collections_config.json
```

### 清除
```
./clean.sh
```
所有节点都可以用这个脚本清理，这个脚本依赖docker
