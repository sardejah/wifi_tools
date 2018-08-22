#!/bin/sh
if=$1
echo "usage: ap_scan.sh <interface_name>"
iwlist $if scan | egrep 'Cell |ESSID|Encryption|Quality|Last beacon|uth'
