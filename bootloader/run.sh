#!/bin/bash

cd boot
./boot.sh
cd ..

cd loader
sudo ./loader.sh
cd ..

bochs -qf boot.txt