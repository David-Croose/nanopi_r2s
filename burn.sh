#!/bin/bash

BLKDEV=sdb

dd if=/dev/zero     of=/dev/$BLKDEV bs=4096 count=$((2*1024*1024/4096))
dd if=idbloader.img of=/dev/$BLKDEV seek=64
dd if=u-boot.itb    of=/dev/$BLKDEV seek=16384
