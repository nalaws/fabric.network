# fabric network

fabric 无docker-compose组网

## 环境准备
1、准备fabric-ca镜像
2、准备fabric-peer镜像
3、准备fabric-orderer镜像

## 启动

### 建立网关
```
./netbuild.sh
```

### 启动ca服务
```
./ca_org1.sh up
./ca_org2.sh up
./ca_orderer.sh
```

### 启动peer服务
```
./peer0.org1.sh up
./peer0.org2.sh up
```

### 启动orderer服务
```
./orderer.sh up
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
./netclean.sh
```
清理所有hyperledger的docker,网关,生成的文件夹

