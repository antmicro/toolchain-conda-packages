#!/bin/bash

# arm1176 - Raspberry Pi Zero (armv6l) - needs qemu_network.sh to be run
# cortex-a53 - Raspberry Pi 3 (aarch64)
# TODO: download pre-configured images with SWAP and more disk space
if [[ $2 == "arm1176" ]]; then
    export BOOT_DIR=rpi0_boot
    export BOOT_DIR_PATH=`realpath ${BOOT_DIR}`
    export DTB=${BOOT_DIR_PATH}/versatile-pb.dtb
    export DTB_REPO_URL="https://github.com/dhruvvyas90/qemu-rpi-kernel/raw/master/versatile-pb.dtb?raw=true"
    export RPI_KERNEL=${BOOT_DIR_PATH}/kernel-qemu-4.19.50-buster
    export KERNEL_REPO_URL="https://github.com/dhruvvyas90/qemu-rpi-kernel/blob/master/kernel-qemu-4.19.50-buster?raw=true"
    export MAC="00:16:3e:00:00:01"

    export RPI_FS=${BOOT_DIR_PATH}/2019-09-26-raspbian-buster-lite.img
    export IMAGE_FILE=2019-09-26-raspbian-buster-lite.zip
    export IMAGE=http://downloads.raspberrypi.org/raspbian_lite/images/raspbian_lite-2019-09-30/${IMAGE_FILE}

    mkdir -p $BOOT_DIR
    cd $BOOT_DIR_PATH
    if [[ $1 == "download" ]]; then
        wget ${KERNEL_REPO_URL} \
                -O ${RPI_KERNEL}
        wget ${DTB_REPO_URL} \
                -O ${DTB}

        wget $IMAGE
        unzip $IMAGE_FILE
    elif [[ $1 == "nodownload" ]]; then
        echo "Skippping download... Asuming files are in ${BOOT_DIR_PATH}"
    else
        echo "Provide download/nodownload argument!"
        echo "Usage: ./qemu-raspberry-pi.sh <download/nodownload> <arm1176/cortex-a53>"
        exit 1
    fi
    qemu-system-arm \
        -cpu $2 \
        -m 256 -M versatilepb \
        -kernel ${RPI_KERNEL} \
        -dtb ${DTB} \
        -no-reboot -nographic \
        -serial mon:stdio \
        -append "root=/dev/sda2 panic=1 rootfstype=ext4 rw" \
        -drive "file=${RPI_FS},index=0,media=disk,format=raw" \
        -device e1000,netdev=net0 \
        -net nic,macaddr=${MAC} \
        -net tap,ifname=tap0,script=no,downscript=no \
        -netdev user,id=net0,hostfwd=tcp::5022-:22
elif [[ $2 == "cortex-a53" ]]; then
    export BOOT_DIR=rpi3_boot
    export BOOT_DIR_PATH=`realpath ${BOOT_DIR}`
    export RPI_KERNEL=${BOOT_DIR_PATH}/vmlinuz-4.14.0-3-arm64
    export RPI_INITRD=${BOOT_DIR_PATH}/initrd.img-4.14.0-3-arm64
    export RPI_FS=${BOOT_DIR_PATH}/2018-01-08-raspberry-pi-3-buster-PREVIEW.img
    export IMAGE_FILE=2018-01-08-raspberry-pi-3-buster-PREVIEW.img.xz
    export IMAGE=https://people.debian.org/~stapelberg/raspberrypi3/2018-01-08/${IMAGE_FILE}

    mkdir -p $BOOT_DIR
    cd $BOOT_DIR_PATH
    if [[ $1 == "download" ]]; then
        wget ${IMAGE}
        unxz < ${IMAGE_FILE} > ${RPI_FS}
        sudo mkdir debian
        sudo mount -v -o offset=314572800 -t ext4 ./2018-01-08-raspberry-pi-3-buster-PREVIEW.img debian
        sudo echo "
# The root file system has fs_passno=1 as per fstab(5) for automatic fsck.
#/dev/mmcblk0p2 / ext4 rw 0 1
/dev/vda2 / ext4 rw 0 1
# All other file systems have fs_passno=2 as per fstab(5) for automatic fsck.
# /dev/mmcblk0p1 /boot/firmware vfat rw 0 2
proc /proc proc defaults 0 0" > debian/etc/fstab
        sudo umount debian
        sudo mount -v -o offset=1048576 -t vfat ./2018-01-08-raspberry-pi-3-buster-PREVIEW.img debian
        cp debian/vmlinuz-4.14.0-3-arm64 .
        cp debian/initrd.img-4.14.0-3-arm64 .
        cp debian/bcm2837-rpi-3-b.dtb .
        cp debian/cmdline.txt .
        sudo umount debian
    elif [[ $1 == "nodownload" ]]; then
        echo "Skippping download... Asuming files are in ${BOOT_DIR_PATH}"
    else
        echo "Provide download/nodownload argument!"
        echo "Usage: ./qemu-raspberry-pi.sh <download/nodownload> <arm1176/cortex-a53>"
        exit 1
    fi
    qemu-system-aarch64 \
        -cpu cortex-a53 \
        -m 2048 -M virt -smp 4 \
        -kernel ${RPI_KERNEL} \
        -initrd ${RPI_INITRD} \
        -no-reboot -nographic \
        -serial mon:stdio \
        -append "rw root=/dev/vda2 console=ttyAMA0 loglevel=8 rootwait fsck.repair=yes memtest=1" \
        -drive file=${RPI_FS},format=raw,if=sd,id=hd-root \
        -device virtio-blk-device,drive=hd-root \
        -netdev user,id=net1,hostfwd=tcp::6022-:22 \
        -device virtio-net-device,netdev=net1
else
    echo "Unsupported architecture for Raspberry Pi target!"
    echo "Usage: ./qemu-raspberry-pi.sh <download/nodownload> <arm1176/cortex-a53>"
    exit 1
fi

exit 0
