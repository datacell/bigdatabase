#!/usr/bin/env python

import os
os.system("vboxmanage list hdds > vboxhdds")
filepath = 'vboxhdds'
hdd2remove = []
with open(filepath) as fp:
    line = fp.readline()
    while line:
        print "Parsing line: " + line
        if line.startswith( 'UUID' ):
            val=line.split(":")
            uuid = val[1].strip()
        if line.startswith( 'Location' ):
            val=line.split(":")
            location = val[1].strip()
        if line.startswith( 'Capacity' ):
            val=line.split(":")
            capacity = val[1].strip()
        if line.startswith( 'State' ):
            val=line.split(":")
            state = val[1].strip()
        if len(line.strip()) == 0:
            print "UUID: " + uuid + " State: " + state + " Capacity: " + capacity + " Location: " + location
            if "inaccessible" in state:
                hdd2remove.append(uuid + ":" + state + ":" + location + ":" + capacity)
            uuid = ""
            state = ""
            location = ""
            capacity = ""
        line = fp.readline()

for invalhdd in hdd2remove:
    try:
        val=invalhdd.split(":")
        print "Deleting medium " + invalhdd
        os.system("vboxmanage closemedium disk " + val[0].strip() + " --delete")
    except:
        pass
