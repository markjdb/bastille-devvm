#!/bin/sh

status=0
while [ $status -eq 0 ]; do
    bhyve -c 2 -m 4G -H -A \
        -s 0,hostbridge \
        -s 1,lpc \
        -s 2,virtio-blk,${_FREEBSD_VM_IMG} \
        -s 3,virtio-blk,${_FREEBSD_KERN_VM_IMG} \
        -l com1,stdio \
        -l bootrom,/usr/local/share/uefi-firmware/BHYVE_UEFI.fd \
        devvm
    status=$?
done
