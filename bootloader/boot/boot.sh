nasm boot.asm -o boot.bin
#写入512字节
dd if=boot.bin of=/home/reus134/os_64/ht_real_os/bootloader/boot.img bs=512 count=1 conv=notrunc