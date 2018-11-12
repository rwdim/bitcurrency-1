#!/bin/bash

CORES=`cat /proc/cpuinfo | grep -i "model" | wc -l`

ORIG_PATH="$PATH"
MXE_PATH="$1"
export PATH="$MXE_PATH/usr/bin/:${ORIG_PATH}"

if [ "$2" == "64" ]; then
  PLAT=x86_64
else
  PLAT=i686
fi

CC="$PLAT-w64-mingw32-gcc" AR="$PLAT-w64-mingw32-ar" \
  CFLAGS="-DSTATICLIB -I$MXE_PATH/usr/$PLAT-w64-mingw32.static/include" \
  LDFLAGS="-L$MXE_PATH/usr/$PLAT-w64-mingw32/lib" \
  make clean libminiupnpc.a -j $CORES

mkdir -p "$MXE_PATH/usr/$PLAT-w64-mingw32.static/include/miniupnpc"
cp *.h "$MXE_PATH/usr/$PLAT-w64-mingw32.static/include/miniupnpc/"
cp libminiupnpc.a "$MXE_PATH/usr/$PLAT-w64-mingw32.static/lib/"
