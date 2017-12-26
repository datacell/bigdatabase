#!/usr/bin/env python

import os
os.system("vboxmanage list hdds > vboxhdds")
filepath = 'vboxhdds'
hdd2remove = []
with open(filepath) as fp:
    #uuid = []
    #state = []
    uuid = ""
    state = ""

    line = fp.readline()
    while line:
        if line.startswith( 'UUID' ):
            val=line.split(":")
            #uuid.append(val[1].strip())
            uuid = val[1].strip()
        if line.startswith( 'State' ):
            val=line.split(":")
            #state.append(val[1].strip())
            state = val[1].strip()
            if "inaccessible" in state:
                hdd2remove.append(uuid + ":" + state)
        line = fp.readline()

for invalhdd in hdd2remove:
    try:
        val=invalhdd.split(":")
        os.system("vboxmanage closemedium disk " + val[0].strip() + " --delete")
    except:
        pass
