#!/usr/bin/env bash

curl -LO https://www.reaper.fm/files/7.x/reaper703_linux_x86_64.tar.xz

tar -xvf reaper703_linux_x86_64.tar.xz

cd reaper_linux_x86_64/

# qjackctl will usually pull jackd and all the dependencies they need together
# list of libs: libgdk3.0-cil libgdk3.0-cil-dev qjackctl

# then install stuff like surge-xt, helm, dexed, etc
