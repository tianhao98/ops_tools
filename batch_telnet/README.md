# 批量telnet 测试端口

## 描述

``` 
batch_telnet.py ： 执行程序 
ipport.txt ：需要填写telnet测试的ip和端口，需要一一对应
result_file.txt ： 执行产生输出的信息
```

### 执行测试

``` shell
$ python3 batch_telnet.py
31.104.126.171 80 is error ! [Errno 61] Connection refused
31.104.126.171 80 is error ! [Errno 61] Connection refused
31.104.126.171 22 is up
31.104.126.171 80 is error ! [Errno 61] Connection refused

```
