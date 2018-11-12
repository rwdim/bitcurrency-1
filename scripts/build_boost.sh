#!/bin/bash

CORES=`cat /proc/cpuinfo | grep -i "model" | wc -l`

ORIG_PATH="$PATH"
MXE_PATH="$1"
ARCH="$2"

if [ "$ARCH" == "64" ]; then
  XCC="x86_64-w64-mingw32.static-gcc"
  XCXX="x86_64-w64-mingw32.static-g++"
  PLAT="x86_64"
  PREFIX="$MXE_PATH/usr/x86_64-w64-mingw32.static"
else
  XCC="i686-w64-mingw32.static-gcc"
  XCXX="i686-w64-mingw32.static-g++"
  PLAT="i686"
  PREFIX="$MXE_PATH/boost"
fi

mkdir -p "$PREFIX"
export PATH="$MXE_PATH/usr/bin/:${ORIG_PATH}";CC="$XCC" CXX="$XCXX" ./bootstrap.sh --prefix="$PREFIX" --with-icu
echo "================================================================"
echo "Building $ARCH bit using $CORES cores."
echo "================================================================"
./b2 install -j $CORES
