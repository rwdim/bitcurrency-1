#!/bin/bash

CORES=`cat /proc/cpuinfo | grep -i "model" | wc -l`

ORIG_PATH="$PATH"
MXE_PATH="$1"
ARCH="$2"

sed -i "s/WinIoCtl.h/winioctl.h/g" src/dbinc/win_db.h
mkdir build_mxe
cd build_mxe

if [ "$ARCH" == "64" ]; then
  PLAT="x86_64"
else
  PLAT="i686"
fi

CC=$MXE_PATH/usr/bin/$PLAT-w64-mingw32.static-gcc \
CXX=$MXE_PATH/usr/bin/$PLAT-w64-mingw32.static-g++ \
../dist/configure \
        --disable-replication \
        --enable-mingw \
        --enable-cxx \
        --host x86 \
        --prefix=$MXE_PATH/usr/$PLAT-w64-mingw32.static

make clean && make -j $CORES
make install
