# network

fabric网络管理

## ORDERER 节点启动

### 环境准备
1 启动CA服务
2 启动所有peer服务 
3 拷贝所有peer服务里的organizations/peerOrganizations里的文件到orderer服务的organizations/peerOrganizations下面

### 启动
```
./orderer.sh up
```
正常启动后会开启peer服务，提示如下：
```
Creating orderer.example.com ... done
```
可以用docker ps查看启动的docker服务是否正常运行

### 停止
```
./orderer.sh down
```
停止只会停止docker容器，服务和文件不会删除


### 清除
```
./orderer.sh clean
```
会清理掉同docker-compose网络服务容器,并删除该服务的外挂文件
