#!/usr/bin/env python
# -*- encoding:"utf-8"-*-
import libvirt
import os
import sys
import logging
import time
from xml.etree import ElementTree

def Virt_conn():
    conn = libvirt.open('qemu:///system')
    if conn == None:
        # logging.error('virtual host connection is fail')
        sys.exit(1)
    else:
        return (conn)


class Virt_status(object):

    def __init__(self, virtual_name, virt_conn=Virt_conn()):
        self.virtual_name = virtual_name
        # self.collect_item = collect_item
        self.virt_conn = Virt_conn()
        self.dom = self.virt_conn.lookupByName(self.virtual_name)
        self.dom_info = self.dom.info()

    def base_cpu_number(self):
        return str(self.dom_info[3])

    def base_memory(self):
        return str(int(self.dom_info[2]) / 1024 / 1024)

    def base_id(self):
        return self.dom.ID()

    def base_state(self):
        return self.dom_info[0]

    def base_disk(self):
        disk_info = self.dom.blockInfo('vda')
        return str(disk_info[0] / 1073741824 )
    
    def Get_IP(self):
        tree = ElementTree.fromstring(self.dom.XMLDesc())
        devices = tree.findall('devices/interface/mac')
        ip_list = []
        for mac in devices:
            command = "arp -a | grep {0} | cut -d ' ' -f 2 | tr -d '()'".format(mac.get('address'))
            ip_list.append(os.popen(command).read().strip(os.linesep))

        return ",".join(ip_list)

    def cpu_usage(self):
        t1 = time.time()
        c1 = int(self.dom.info()[4])
        time.sleep(1)
        t2 = time.time()
        c2 = int(self.dom.info()[4])
        c_nums = int(self.dom.info()[3])
        usage = (c2 - c1) * 100 / ((t2 - t1) * c_nums * 1e9)
        return(usage)

    def dick_Stats(self,status):
        dick_status = {'read_bytes':0, 'write_bytes':2}
        # domain = self.virt_conn.lookupByName(self.virtual_name)
        # tree = ElementTree.fromstring(domain.XMLDesc())
        # devices = tree.findall('devices/disk/target')
        # for d in devices:
        #     device = d.get('dev')
        #     try:
        #         devstats = domain.blockStats(device)
        #         return(int(devstats[0]) / 1024000000)
        #     except libvirt.libvirtError:
        #         logging.error('err libvirtError')
        #         os._exit(1)
        devstats = self.dom.blockStats('vda')
        d1 = float(devstats[dick_status.get(status)]) / 1024
        time.sleep(1)
        d2 = float(devstats[dick_status.get(status)]) / 1024
        return(d2 - d1) 


    def interfaceStats(self,status):
        int_status = {'input_bytes':0, 'output_bytes':4}
        # domain = conn.lookupByName(self.virtual_name)
        tree = ElementTree.fromstring(self.dom.XMLDesc())
        ifaces = tree.findall('devices/interface/target')
        for i in ifaces:
            iface = i.get('dev')
            ifaceinfo = self.dom.interfaceStats(iface)
            if1 = ifaceinfo[int_status.get(status) / 1024000]
            time.sleep(1)
            if2 = ifaceinfo[int_status.get(status) / 1024000]
            return(if2 - if1)

    def memory_usage(self):
        self.dom.setMemoryStatsPeriod(10)
        meminfo = self.dom.memoryStats()
        free_mem = float(meminfo['unused'])
        total_mem = float(meminfo['available'])
        util_mem = ((total_mem - free_mem) / total_mem) * 100 
        return(float(util_mem))

    def __delete__(self, instance):
        self.virt_conn.close()

def main():
    if len(sys.argv[1:]) > 3 or len(sys.argv[0]) < 2:
        sys.exit(1)

    virtual_name = sys.argv[1]
    collect_item = sys.argv[2]

    virtual = Virt_status(virtual_name)

    virtual_host_func = dir(virtual)

    if collect_item in virtual_host_func:
        func = getattr(virtual, collect_item)
        if collect_item in ['interfaceStats', 'dick_Stats']:
            status = sys.argv[3]
            print(func(status))
        else:
            print(func())

if __name__ == '__main__':
    main()
