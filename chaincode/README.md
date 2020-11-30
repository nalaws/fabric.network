# network

fabric网络管理

## 创建通道

### 环境准备
1 启动fabric网络
2 拷贝各个组织的tls证书到相应目录下。如: organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem等
3 拷贝所有组织锚节点msp到相应目录。如：organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp

### 启动
```
# 默认通道名称mychannel,部署链码
./chaincode.sh deploy -ccn archive -ccp ../../chaincode-go/ -cccg ../../chaincode-go/collections_config.json
ccn:  链码名称
ccp:  链码路径
cccg: 私有数据json配置文件
```
部署成功,提示如下：
```
Query chaincode definition successful on peer0.org1 on channel 'mychannel'
...
Query chaincode definition successful on peer0.org2 on channel 'mychannel'
```
这个脚本类似一个client的角色，部署链码成功后就可以调用清除指令清除中间文件了,也可以保留

### 清除
```
./chaincode.sh clean
```

