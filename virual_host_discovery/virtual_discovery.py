#!/usr/bin/env python
import os
import simplejson as json

t = os.popen("sudo virsh list | sed '1,2d' | awk '{print $2}'")
vir_name = []

for vir in  t.readlines():
    r = os.path.basename(vir.strip(os.linesep))
    vir_name += [{'{#VIRTUAL}': r}]

print(json.dumps({'data': vir_name}, sort_keys=True, indent=4, separators=(',', ':')))
