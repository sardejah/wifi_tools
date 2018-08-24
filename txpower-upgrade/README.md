this folder is patched to work on kali linux , raspberry pi

install these packages :
apt-get install libnl-3-dev libgcrypt11-dev libnl-genl-3-dev

How to use:

backup /lib/crda/regulatory.bin
remove /lib/crda/regulatory.bin
open wireless-regdb
remove regulatory.bin
remove *.pem
edit db.txt and change txpower presets
then in wireless-regdb do: make
this creates several pem files and a regulatory.bin

Now remove regulatory in the crda-3.18 folder
go to that folder
copy fresh regulatory.bin into that folder and into /lib/crda/
remove pubkeys in ./pubkeys/

copy the fresh created .pem files from wireless-regdb into ./pubkeys/ and into /lib/crda/
from all of these pubkeys, remove the ones with x509 in the name
copy the pem from /lib/crda/pubkeys/ named like benh@debian... into ./pubkeys/
you are still in crda-3.18
remove libreg.so
now do:
make clean
make
make install

reboot and finished.
