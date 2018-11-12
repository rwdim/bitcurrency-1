#!/bin/bash

CORES=`cat /proc/cpuinfo | grep -i "model" | wc -l`

MXE_PATH="$1"
ARCH="$2"
ORIG_PATH="$PATH"

export PATH="$MXE_PATH/usr/bin/:$MXE_PATH/usr/bin/x86_64-w64-mingw32.static/bin:$ORIG_PATH"

if [ "$ARCH" == "64" ]; then
  RANLIB="$MXE_PATH/usr/bin/x86_64-w64-mingw32.static-ranlib"
  XCC="x86_64-w64-mingw32.static-gcc"
  XCXX="x86_64-w64-mingw32.static-g++"

  RANLIB=$RANLIB \
  CC="$XCC" CXX="$XCXX" AR="x86_64-w64-mingw32-ar" \
  ./config --prefix="$MXE_PATH/usr/x86_64-w64-mingw32.static/" -DWIN64 no-dso no-shared -DSTATICLIB \
    -DCROSS_COMPILE=NATIVE_WINDOWS  \
    -DTARGET_OS=NATIVE_WINDOW \
    -DLDFLAGS="-L$MXE_PATH/usr/x86_64-w64-mingw32.static/lib" \
    -DCXXFLAGS="-masm=intel -ggdb -O3 -fPIC -march=native -mno-avx" \
    -DWIN64 -I${MXE_PATH}/usr/x86_64-w64-mingw32.static/include -DSYSTEM=MINGW32
  make clean

  #Usage: Configure [no-<cipher> ...] [enable-<cipher> ...] [experimental-<cipher> ...] [-Dxxx] [-lxxx] [-Lxxx]
  #[-fxxx] [-Kxxx] [no-hw-xxx|no-hw] [[no-]threads] [[no-]shared] [[no-]zlib|zlib-dynamic] [no-asm] [no-dso] [no-krb5]
  #[sctp] [386] [--prefix=DIR] [--openssldir=OPENSSLDIR] [--with-xxx[=vvv]] [--test-sanity] os/compiler[:flags]

  # build it!
  CROSS_COMPILE=NATIVE_WINDOWS \
  CC="$XCC" CXX="$XCXX" \
    RANLIB="$RANLIB" \
    TARGET_OS=NATIVE_WINDOWS  \
    LDFLAGS="-L$MXE_PATH/usr/x86_64-w64-mingw32.static/lib" \
    CXXFLAGS="-DWIN64 -Wfatal-errors -ggdb -O3 -fPIC -march=native -mno-avx -I${MXE_PATH}/usr/x86_64-w64-mingw32.static/include -DSTATICLIB " \
    make -j $CORES

else
  RANLIB="$MXE_PATH/usr/bin/i686-w64-mingw32.static-ranlib"
  XCC="i686-w64-mingw32.static-gcc"
  XCXX="i686-w64-mingw32.static-g++"

  RANLIB=$RANLIB \
  CC="$XCC" CXX="$XCXX" AR="i686-w64-mingw32-ar" \
  ./config --prefix="$MXE_PATH/usr/i686-w64-mingw32.static/" -DWIN32 no-dso no-shared -DSTATICLIB \
    -DCROSS_COMPILE=NATIVE_WINDOWS  \
    -DTARGET_OS=NATIVE_WINDOW \
    -DLDFLAGS="-L$MXE_PATH/usr/i686-w64-mingw32.static/lib" \
    -DCXXFLAGS="-masm=intel -ggdb -O3 -fPIC -march=native -mno-avx" \
    -I${MXE_PATH}/usr/i686-w64-mingw32.static/include -DSYSTEM=MINGW32 \
  make clean

  # build it!
  CROSS_COMPILE=NATIVE_WINDOWS \
  CC="$XCC" CXX="$XCXX" \
    RANLIB="$RANLIB" \
    TARGET_OS=NATIVE_WINDOWS  \
    LDFLAGS="-L$MXE_PATH/usr/i686-w64-mingw32.static/lib" \
    CXXFLAGS="-DWIN32 -Wfatal-errors -ggdb -O3 -fPIC -march=native -mno-avx -I${MXE_PATH}/usr/i686-w64-mingw32.static/include -DSTATICLIB " \
    make -j $CORES
fi
