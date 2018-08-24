#!/bin/bash

apt-get update
apt-get install libnl-3-dev libgcrypt11-dev libnl-genl-3-dev
move /lib/crda/regulatory.bin /lib/crda/regulatory.bin.bak
rm ./wireless-regdb/*.pem
rm ./wireless-regdb/regulatory.bin
cd wireless-regdb
make
cd ..
cd crda-3.18
rm regulatory.bin
rm ./pubkeys/*.pem
cp ../wireless-regdb/*.pem ./pubkeys/
cp ../wireless-regdb/regulatory.bin ./
rm ./pubkeys/*.x5*
cp /liv/crda/pubkeys/benh@debian.org.key.pub.pem ./pubkeys/
rm libreg.so 
make clean
make
make install
