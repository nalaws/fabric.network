# network

fabric网络管理

## PEER 节点启动

### 环境准备
1 启动CA服务
2 拷贝该组织ca服务的tls-cert.pem文件到相应的目录下。如: organizations/fabric-ca/org2/tls-cert.pem 

### 启动
```
./peer.sh up
```
正常启动后会开启peer服务，提示如下：
```
Creating peer0.org2.example.com ... done
```

### 停止
```
./peer.sh down
```
停止只会停止docker容器，服务和文件不会删除


### 清除
```
./peer.sh clean
```
会清理掉同docker-compose网络服务容器,并删除该服务的外挂文件

### 输出
peer服务启动后，拷贝所有peer的msp文件夹到orderer节点相应目录下。如peer节点organizations/peerOrganizations/org2.example.com/msp到orderer节点organizations/peerOrganizations/org2.example.com/