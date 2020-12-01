# network

fabric网络管理

## 单机器分布式docker部署

### 启动
```
./network.sh up createChannel -c mychannel -ca
mychannel: 通道名称
```
正常运行后会, 提示如下:
```
Anchor peers updated for org 'Org2MSP' on channel 'mychannel'
Channel successfully joined
```

### 部署合约
```
./network.sh deployCC -c mychannel -ccn archive -ccp ../../chaincode-go/ -cccg ../../chaincode-go/collections_config.json
ccp: 指定合约路径
cccg: 指定私有数据配置文件
```
正常部署后会, 提示如下:
```
Query chaincode definition successful on peer0.org2 on channel 'mychannel'
Chaincode initialization is not required
```

### 操作指令

准备环境. 打开新终端，运行以下指令
```
export PATH=${PWD}/bin:${PWD}:$PATH
export FABRIC_CFG_PATH=$PWD/config/
export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/org1.example.com/
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/minter@org1.example.com/msp
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_ADDRESS=localhost:7051
export TARGET_TLS_OPTIONS="-o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --peerAddresses localhost:7051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt"

```

获取clientID
```
peer chaincode query -C mychannel -n archive -c '{"function":"ClientID","Args":[]}'
```

添加用户
```
peer chaincode invoke $TARGET_TLS_OPTIONS -C mychannel -n archive -c '{"function":"AddUser","Args":["eDUwOTo6Q049bWludGVyLE9VPWNsaWVudCxPPUh5cGVybGVkZ2VyLFNUPU5vcnRoIENhcm9saW5hLEM9VVM6OkNOPWNhLm9yZzEuZXhhbXBsZS5jb20sTz1vcmcxLmV4YW1wbGUuY29tLEw9RHVyaGFtLFNUPU5vcnRoIENhcm9saW5hLEM9VVM=", "3"]}'
```

查询用户
```
peer chaincode query -C mychannel -n archive -c '{"function":"GetUser","Args":[]}'
```

检查是否是监管员
```
peer chaincode query -C mychannel -n archive -c '{"function":"CheckEnroll","Args":[]}'
```

### 停止
```
./network.sh down
```
停止只会停止docker容器，服务和文件不会删除


### 清除
```
./network.sh clean
```

