#!/bin/bash

CORES=`cat /proc/cpuinfo | grep -i "model" | wc -l`

MXE_PATH="$1"
ORIG_PATH="$PATH"
ARCH="$2"

chmod a+x src/leveldb/build_detect_platform

if [ "$2" == "64" ]; then
  PLAT=x86_64
  WSUFF="_win64-mt"
else
  PLAT=i686
  WSUFF="_win32-mt"
fi

PATH="$MXE_PATH/usr/bin:$ORIG_PATH"
MXE_INCLUDE_PATH="$MXE_PATH/usr/$PLAT-w64-mingw32.static/include"
MXE_LIB_PATH="$MXE_PATH/usr/$PLAT-w64-mingw32.static/lib"
QT5="$MXE_PATH/usr/bin/$PLAT-w64-mingw32.static-qmake-qt5"

echo "$MXE_INCLUDE_PATH \
$MXE_LIB_PATH \
$QT5"
exit 1

$QT5 \
        BOOST_LIB_SUFFIX=-mt \
        BOOST_THREAD_LIB_SUFFIX="$WSUFF" \
        BOOST_INCLUDE_PATH="$MXE_INCLUDE_PATH/boost" \
        BOOST_LIB_PATH="$MXE_LIB_PATH" \
        OPENSSL_INCLUDE_PATH="$MXE_INCLUDE_PATH/openssl" \
        OPENSSL_LIB_PATH="$MXE_LIB_PATH" \
        BDB_INCLUDE_PATH="$MXE_INCLUDE_PATH" \
        BDB_LIB_PATH="$MXE_LIB_PATH" \
        MINIUPNPC_INCLUDE_PATH="$MXE_INCLUDE_PATH" \
        MINIUPNPC_LIB_PATH="$MXE_LIB_PATH" \
        QMAKE_LRELEASE="$MXE_PATH/usr/$PLAT-w64-mingw32.static/qt5/bin/lrelease" bitcurrency-qt.pro

pushd src/leveldb
make clean
popd
make -j $CORES
