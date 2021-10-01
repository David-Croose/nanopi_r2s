#!/bin/bash

set -e

umount_all()
{
    set +e

    df | grep ${SDCARD}1 2>&1 1>/dev/null
    if [ $? == 0 ]; then
        umount ${SDCARD}1
    fi

    df | grep ${SDCARD}2 2>&1 1>/dev/null
    if [ $? == 0 ]; then
        umount ${SDCARD}2
    fi

    set -e
}

echo "=================================================================="
echo "Please enter your sdcard block device name:"
echo "e.g. /dev/sdb"
read SDCARD

echo "=================================================================="
echo "umounting sdcard..."
umount_all

echo "=================================================================="
echo "deleting all partitions..."
wipefs -a -f $SDCARD
dd if=/dev/zero     of=$SDCARD bs=4096 count=$((2*1024*1024/4096))

echo "=================================================================="
echo "creating partitions..."
fdisk $SDCARD < part.txt

echo "=================================================================="
echo "formating partitions..."
mkfs.fat ${SDCARD}1
mkfs.ext4 -F ${SDCARD}2

echo "=================================================================="
echo "mounting sdcard..."
rm -rf mnt1 mnt2
mkdir mnt1 mnt2
mount ${SDCARD}1 mnt1
mount ${SDCARD}2 mnt2

echo "=================================================================="
echo "copying kernel and dtb..."
cp Image mnt1
cp rk3328-nanopi-r2s.dtb mnt1

echo "=================================================================="
echo "copying rootfs..."
tar -xf rootfs.tar -C mnt2
mknod -m 666 mnt2/dev/null c 1 3
mknod -m 666 mnt2/dev/console c 5 1

echo "=================================================================="
echo "unmounting sdcard..."
umount_all
rm -rf mnt1 mnt2

echo "=================================================================="
echo "writing uboot into sdcard..."
dd if=idbloader.img of=$SDCARD seek=64
dd if=u-boot.itb    of=$SDCARD seek=16384

sync
