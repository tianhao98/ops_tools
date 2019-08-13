# 部署k8s初始化基础环境所用

## 功能介绍

主要包含以下功能，其中1～5用shell 实现，6～11通过ansible实现

```
1. 建立互信
2. 检查分区是否为xfs
3. 检查所有主机os系统
4. 检查时间是否同步
5. 安装ansible以下所有部署操作依赖ansible
6. 检查并且关闭selinux(修改完需要重启os)
7. 安装ntp
8. ops机器安装docker
9. 部署镜像中心harbor
10. 批量安装jp包
11. 部署helm（依赖k8s环境）
```

## 目录介绍

Basic_env_init/
├── ansible
│   ├── ansible_rpm  # 安装ansible所有的rpm包
│   ├── hosts.ini    # ansible执行使用的hosts
│   ├── hosts-temp.ini  # 生成hosts.ini所用的模版
│   ├── roles   # ansible所有roles方法
│   └── site.yaml   # 使用roles方法的site文件
├── bin
│   ├── CheckEnv.sh  # 前期1～5用shell实现的功能
│   ├── InstallEnv.sh   # 调用ansible方法脚本
│   ├── intAnsibleConf.sh # 初始化hosts.ini文件，主要用sed替换实现
│   └── setup.sh  # 统一执行脚本文件
├── conf
│   └── basic.ini # 配置文件
└── README.md

## 配置文件介绍

![配置文件](https://imagechuang.oss-cn-beijing.aliyuncs.com/20190813223052.png)

## 操作步骤

1. 执行脚本操作

``` shell
$ cd Basic_env_init/bin/

# 备注：可以这样sh setup.sh -d执行，会出现脚本执行信息
$ sh setup.sh 
``` 
![脚本页面](https://imagechuang.oss-cn-beijing.aliyuncs.com/20190813222326.png)


## 注意事项

1. 在安装Barbor的时候一般需要较长时间，可以登录到安装Barbor的主机docker ps 观察启动的容器
2. 安装helm需要在k8s 节点上
3. 执行脚本之前建议配置好yum源需要安装ntp，expect


