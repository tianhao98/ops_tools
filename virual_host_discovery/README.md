# zabbix简单自动发现虚机脚本

介绍：

用于 zabbix 自动发现主机KVM虚机使用，监控项包含，cpu使用率，磁盘大小，cpu核数，内存使用率，内存大小，是否存活，虚机IP



## 使用说明

###【脚本用途】

virtual_discovery.py ：自动获取机器上面的所有虚机，然后返回json给zabbix

virtual_status.py：通过 virtual_discovery.py 返回的json ，获取所有虚机名称，然后进行监控项监控

###【配置步骤】

1、首先配置zabbix agent配置文件

```shell
$ vim /etc/zabbix/zabbix_agentd.conf.d/virual_discovery.conf 
UserParameter=virtual_discovery,python /usr/local/zabbix/script/virtual_discovery.py
UserParameter=virtual_status[*],sudo /usr/bin/python /usr/local/zabbix/script/virtual_status.py $1 $2 $3
```

2、上传脚本到响应目录，给与zabbix所有者所有组

```shell
[root@ecs2 script]# ll -tr /usr/local/zabbix/script/
total 20
-rwxr-xr-x 1 zabbix zabbix  338 Jun 12 18:23 virtual_discovery.py
-rwxr-xr-x 1 zabbix zabbix 4113 Jun 14 15:25 virtual_status.py
```

3、重启zabbix agent

4、安装python模块

```shell
$ pip install simplejson
```





### 【测试】

1、到zabbix server端进行测试自动发现，会返回一段json，判断是否为所有kvm虚机名称

```shell
[root@localhost ~]#  zabbix_get -s 192.168.65.22 -k virtual_discovery
{"data":[{"{#VIRTUAL}":"centos_base"},{"{#VIRTUAL}":"centos7-1-edas"},{"{#VIRTUAL}":"centos7-2-edas"},{"{#VIRTUAL}":"centos7-3-edas"},{"{#VIRTUAL}":"centos7-4-edas"},{"{#VIRTUAL}":"centos7-5-edas"},{"{#VIRTUAL}":"centos7-6-edas"},{"{#VIRTUAL}":"centos7-7-edas"},{"{#VIRTUAL}":"centos7-8-edas"},{"{#VIRTUAL}":"centos7-9-edas"},{"{#VIRTUAL}":"centos7-10-edas"},{"{#VIRTUAL}":"centos7-11-edas"},{"{#VIRTUAL}":"centos7-12-edas"},{"{#VIRTUAL}":"centos7-13-edas"},{"{#VIRTUAL}":"centos7-14-edas"},{"{#VIRTUAL}":"centos7-15-edas"},{"{#VIRTUAL}":"centos7-16-edas"},{"{#VIRTUAL}":"centos7-17-edas"},{"{#VIRTUAL}":"centos7-18-edas"},{"{#VIRTUAL}":"centos7-19-edas"},{"{#VIRTUAL}":"centos7-20-edas"},{"{#VIRTUAL}":"centos7-21-edas"},{"{#VIRTUAL}":"centos7-22-edas"},{"{#VIRTUAL}":"centos7-23-edas"},{"{#VIRTUAL}":"centos7-24-edas"},{"{#VIRTUAL}":"centos7-25-edas"},{"{#VIRTUAL}":"centos7-26-edas-agent"},{"{#VIRTUAL}":"centos7-27-edas-agent"},{"{#VIRTUAL}":"centos7-28-edas-agent"},{"{#VIRTUAL}":"centos7-29-edas-agent"},{"{#VIRTUAL}":"centos7-30-edas-agent"}]}
```

2、测试监控项

```shell
[root@localhost ~]# zabbix_get -s 192.168.65.22 -k virtual_status[centos7-2-edas,Get_IP]
192.168.65.132
```



###【页面配置zabbix】

配置步骤：配置--> 模板 --> 创建模板 

>  填写好“模板名称” 以及 需要添加到模板里面的组，和主机
>
> ![](https://imagechuang.oss-cn-beijing.aliyuncs.com/20190924122839.png)

然后点击刚刚创建模板的“自动发现” ，“创建发现规则”

> 填写好“名称”，键值:virtual_discovery,  过滤器页面填写：：{#VIRTUAL}
>
> ![](https://imagechuang.oss-cn-beijing.aliyuncs.com/20190924122816.png)

创建好“创建发现规则”规则后，点击 [监控项原型] ,创建	监控项

> ![](https://imagechuang.oss-cn-beijing.aliyuncs.com/20190924122744.png)



## 注意

获取KVM 虚机的IP的时需要调用virtual_status.py 脚本里面的Get_IP的函数，调用本方法获取IP的前提需要在本机ping 过本机所有虚机IP，然后脚本才可以正常获取IP