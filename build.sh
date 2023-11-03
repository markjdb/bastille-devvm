#!/bin/sh

set -e

usage()
{
    cat >&2 <<__EOF__
usage: $(basename $0) [-a] [-c <KERNCONF>] [-m <module list>]

Build a kernel and install it into the VM.

  -a:           Clean build.  By default the kernel is built with -DKERNFAST.
  -c:           Use the specified kernel config.  The default is GENERIC.
  -m:           Specify a (possibly empty) list of modules to build.  By
                default all modules are built.
__EOF__
    exit 1
}

KERNFAST=-DKERNFAST
KERNCONF=GENERIC

while getopts ac:d:j:m:t: o; do
    case "$o" in
    a)
        KERNFAST=
        ;;
    c)
        KERNCONF=$OPTARG
        ;;
    d)
        SRCDIR=$OPTARG
        ;;
    m)
        MODULES="MODULES_OVERRIDE=${OPTARG}"
        ;;
    t)
        TOOLCHAIN="CROSS_TOOLCHAIN=${OPTARG}"
        ;;
    *)
        usage
        ;;
    esac
    shift $((OPTIND - 1))
done

make -C ${_FREEBSD_SRC_PATH}/${SRCDIR} ${JFLAG} buildkernel -s $KERNFAST KERNCONF=$KERNCONF $MODULES $TOOLCHAIN
make -C ${_FREEBSD_SRC_PATH}/${SRCDIR} ${JFLAG} installkernel -s KERNCONF=$KERNCONF $MODULES DESTDIR=${_FREEBSD_KERN_BUILDROOT}

makefs -B little -S 512 -Z -o label=kernel -o version=2 /root/vm_kern.part \
    ${_FREEBSD_KERN_BUILDROOT}
mkimg -s gpt -f raw -S 512 -b ${_FREEBSD_BUILDROOT}/boot/pmbr \
    -p freebsd-ufs/kernel:=/root/vm_kern.part \
    -o ${_FREEBSD_KERN_VM_IMG}

# TODO: force bhyve to restart. Doesn't seem like there's a good way to do
# this at present, sending SIGTERM triggers poweroff and bhyvectl --force-reset
# is not graceful.
