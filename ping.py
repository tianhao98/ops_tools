import subprocess
import threading
import re
from queue import Queue
from queue import Empty
from IPy import IP
import re



success_ip = []
fail_ip = []

def call_ping(ip):
    if subprocess.call(["ping", "-c", "1", ip]):
        print("{0} is unreadcheable".format(ip))
        fail_ip.append(ip)
    else:
        print("{0} is alive".format(ip))
        success_ip.append(ip)

def is_reacheable(q):
    try:
        while True:
            ip = q.get_nowait()
            call_ping(ip)
    except Empty:
        pass

def main():
    q = Queue()
    re_obj = re.compile('[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.0\/[1-3]{1}[0-9]{1}$')
    input_network = input("input is network segment>>:")
    if re_obj.findall(input_network):
        network_segment = input_network
    else:
        print("input right network segment")
        exit()
    ips = IP(network_segment)
    for ip in ips:
        print(type(ip))
        q.put(str(ip))

    threads = []
    for i in range(10):
        thr = threading.Thread(target=is_reacheable, args=(q, ))
        thr.start()
        threads.append(thr)

    for thr in threads:
        thr.join()

    print(
        '''
        success_ip:{0}
        fail_ip:{1}
        '''.format(success_ip, fail_ip)
    )

if __name__ == "__main__":
    main()
