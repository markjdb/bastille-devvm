#!/bin/sh

usage()
{
    echo "usage: $(basename $0) [-c <kernconf>]" >&2
    exit 1
}

KERNCONF=GENERIC
while getopts c: o; do
    case $o in
    c)
        KERNCONF=$OPTARG
        ;;
    *)
        usage
        ;;
    esac
done

status=0
while [ $status -eq 0 ]; do
    bhyve -c 2 -m 4G -H -A \
        -s 0,hostbridge \
        -s 1,lpc \
        -s 2,virtio-blk,${_FREEBSD_VM_IMG} \
        -s 3,virtio-blk,${_FREEBSD_KERN_VM_IMG} \
        -G 1234 \
        -l com1,stdio \
        -l bootrom,/usr/local/share/uefi-firmware/BHYVE_UEFI.fd \
        devvm
    status=$?
    if [ $status -eq 0 ]; then
        sh build.sh -c $KERNCONF
        if [ $? != 0 ]; then
            break
        fi
    fi
done
