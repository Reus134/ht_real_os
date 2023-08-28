#!/bin/bash
if [ ! -e tmp ];then
             mkdir tmp
fi

mount -t vfat -o loop ../boot.img tmp/

cp loader.bin tmp/
sync
umount tmp/

rmdir tmp