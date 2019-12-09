
## 使用场景

双机房（A机房 B机房）情况下各个机房有DNS服务的情况下，B机房使用A机房mysql，A机房mysql出现不可用情况下的域名切换脚本

## 使用说明

``` shell
# 脚本需要在B机房执行
sh check_master_switch.sh -h 172.0.0.1 -uroot -ppassword -t

-h：A机房mysql地址
-u：A机房mysql用户
-p：A机房mysql密码
-t：用于在测试情况下，切换域名操作用echo形式打印出了，不做实际操作
```

## 脚本逻辑

> 简单说：A机房mysql正常总是db域名的解析地址，只有在A机房mysql不正常时候域名还会切换到B机房，A机房恢复后域名还会切换到A机房

1. B机房启动脚本后，不断检查A机房mysql是否健康
2. A机房mysql不健康时候，切换A，B机房的db域名解析地址到B机房mysql
3. A机房mysql恢复健康后，主动切换A，B机房的db域名解析地址到A机房mysql
