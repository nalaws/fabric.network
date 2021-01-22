# fabric network

fabric native 部署

## 启动

### 启动ca服务
```
./ca_org1.sh
./ca_org2.sh
./ca_orderer.sh
```

### 启动peer服务
```
./peer0.org1.sh
./peer0.org2.sh
```

### 启动orderer服务
```
./orderer.sh
```

### 创建通道
```
./channel.sh up -c hxyz
```

### 部署合约
```
./chaincode.sh deploy -c hxyz -ccn archive -ccp ../chaincode-go/ -cccg ../chaincode-go/collections_config.json
```

### 清除
```
./clean.sh
```

