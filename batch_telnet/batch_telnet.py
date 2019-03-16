import telnetlib
import threading

class BatchTelnet(object):

    # 传入输出结果的问题，用于保存结果
    def __init__(self,result_file):
        self.result_file = result_file

    def __result_save(self,result):
        with open(self.result_file, 'a') as result_file:
            result_file.write(result)

    # 传入一个list 包含ip port，后面进行telnet测试
    def port_check(self,ip_port):
        ip, port = ip_port
        try:
            tn = telnetlib.Telnet(host=ip, port=port, timeout=5)
            if isinstance(tn, telnetlib.Telnet):
                self.__result_save("{0} {1} is up\n".format(ip, port, ))
        except Exception as e:
            self.__result_save("{0} {1} is error ! {2}\n".format(ip, port, e))

def main():
    # 清空result内容
    with open('result_file.txt', 'w') as f:
        f.write('')

    # 使用多线程调用BatchTelnet
    tn = BatchTelnet('result_file.txt')
    thlist = list()
    with open('ipport.txt') as f:
        for ipport in f.readlines():
            thread = threading.Thread(target=tn.port_check, args=(ipport.split(), ))
            thlist.append(thread)
            thread.start()

    # 等待全部线程执行成功
    for t in thlist:
        t.join()

    # 把结果输出到屏幕
    with open('result_file.txt') as f:
        print(f.read())

if __name__ == '__main__':
    main()







