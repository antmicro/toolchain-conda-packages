#!/bin/bash

source vm_ids.sh

MEM="2048"
SSH="tcp:${VM_SSH_PORT}::22"
MISC="tcp:11237::1234"
HD="./debian_ppc64el.qcow2"
QOPT="-nographic -vga none -serial mon:stdio"  # -monitor stdio -serial pty

/usr/bin/qemu-system-ppc64 ${QOPT} -m ${MEM} -smp 4 -hda ${HD} -append "${OPT}"
