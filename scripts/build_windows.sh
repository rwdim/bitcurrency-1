#!/bin/bash

CORES=`cat /proc/cpuinfo | grep -i "model" | wc -l`

#if [[ -e '../bitcurrency' || -e "../../bitcurrency" ]]; then
#  echo "Move this script to a directory outside of and far away from the bitcurrency code base, then run it."
#  exit -1
#fi

function usage() {

  echo "Usage:   $0 mxe_path arch"
  echo "Where:   mxe_path is the path to the MXE installation."
  echo "  And:   arch is 32 or 64 for the number of bits."
  exit -1

}

MXE_PATH=`pwd`/mxe
CUR_DIR=`pwd`
ARCH="$2"
BC_DIR="$CUR_DIR/bitcurrency"

# Make output directories
if [ ! -d dist ]; then
  mkdir -p ./dist/{windows,linux,osx}
fi

if [ "$MXE_PATH" == "" ]; then
  usage
fi

if [ "$ARCH" != "32" ] && [ "$ARCH" != "64" ]; then
  usage
fi

ARCH_NAME='x86_64-linux-gnu'
HOST_ARCH='x86_64';
MXE_TARGET="x86_64-w64-mingw32.static"

if [ "$ARCH" == "32" ]; then
  ARCH_NAME='i686-linux-gnu'
  HOST_ARCH='i686'
  MXE_TARGET="i686-w64-mingw32.static"
fi

sudo apt-get install -y qt5-default qt5-qmake qtbase5-dev-tools qttools5-dev-tools \
    build-essential git libboost-dev libboost-system-dev \
    libboost-all-dev libssl-dev libdb++-dev libminiupnpc-dev libqrencode-dev \
    autoconf automake autopoint bison flex gperf intltool libtool-bin \
    ruby scons unzip p7zip-full libgdk-pixbuf2.0-dev g++-mingw-w64-i686 \
    g++-mingw-w64-x86-64 gcc-mingw-w64-i686 gcc-mingw-w64-x86-64

# Get BC from github if we don't already have it
if [ ! -d "$CUR_DIR/bitcurrency" ]; then
  echo "Getting bitcurrency code from github..."
  git clone https://github.com/bitcurrency/bitcurrency
fi

# Get MXE from github if we don't already have it
#if [ ! -d "${MXE_PATH}" ]; then
  #git clone https://github.com/mxe/mxe "${MXE_PATH}"

  # copy mxe dependent files from the bc git
  cp -R ${BC_DIR}/depends/mxe/* ${MXE_PATH}/

  pushd "${MXE_PATH}"

  nice make MXE_PLUGIN_DIRS="plugins/openssl1.0" \
    MXE_TARGETS="${MXE_TARGET}" \
    cc -j $CORES

  nice make MXE_PLUGIN_DIRS="plugins/openssl1.0" \
    MXE_TARGETS="${MXE_TARGET}" \
    boost openssl1.0 qt5 qttools libsodium -j $CORES

  popd

fi

echo "============================================================"
echo ">> Building $ARCH bit"
echo "   ** This process will take a few hours to complete **"
echo "   **   so go watch a movie, and come back later.    **"
echo "============================================================"

# remove dependency build dirs
rm -rf db-4.8.30*
rm -rf miniupnpc-1.9*
rm -rf openssl-1.0.1f*

# copy the dependency files
cp bitcurrency/depends/* ./

# unpack em
tar xfvz db-4.8.30.NC.tar.gz
tar xfvz miniupnpc-1.9.tar.gz
tar xfvz openssl-1.0.1f.tar.gz

  echo '==============================================================================='
  echo '>> Building ${arch}bit'
  echo '==============================================================================='

  # build boost
  #pushd boost_1_65_1
  #cp ../../bitcurrency/scripts/build_boost.sh ./build
  #chmod a+x ./build
  #./build "$MXE_PATH" "$ARCH"
  #popd

  # build db
  pushd db-4.8.30.NC
  cp ../bitcurrency/scripts/build_db.sh ./build
  chmod a+x ./build
  ./build "$MXE_PATH" "$ARCH"
  popd

  # build miniupnp
  pushd miniupnpc-1.9
  cp ../bitcurrency/scripts/build_pnp.sh ./build
  chmod a+x ./build
  ./build "$MXE_PATH" "$ARCH"
  popd

  # build openssl
#  pushd openssl-1.0.1f
#  cp ../bitcurrency/scripts/build_openssl.sh ./build
#  chmod a+x ./build
#  ./build "$MXE_PATH" "$ARCH"
#  popd

  # Build the client
  pushd bitcurrency
  cp scripts/build_bitcurrency.sh ./build_bc
  chmod a+x build_bc
  chmod a+x src/leveldb/build_detect_platform

  pushd src
  make -f makefile.linux-mingw clean && make -f makefile.linux-mingw -j $CORES
  popd

  ./build_bc "$MXE_PATH" "$ARCH"
  popd

#xdone

echo "-----------------------------------------------"
echo Done!
echo "-----------------------------------------------"
