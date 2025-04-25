#!/usr/bin/env bash

mkdir -p build

if [ -z "$URL" ]
then
	export URL="https://github.com/torvalds/linux.git"
fi

if [ -z "$COMMIT" ]
then
	export COMMIT="master"
fi

if [ -z "$CROSS_COMPILE" ]
then
	export CROSS_COMPILE="aarch64-linux-gnu-"
fi

if [ -z "$CONFIG" ]
then
	export CONFIG="longanpi_3h_defconfig"
fi

set -eux

if [ ! -e build/linux ] 
then
	mkdir build/linux
	cd build/linux
	git init .
	git remote add origin "${URL}"
	git fetch origin "${COMMIT}" --depth=1
	git checkout "${COMMIT}"
	find ../../linux/ -name *.patch | sort | while read line
	do
		git am < $line
	done
	cd ../../
fi

if [ ! -e build/linux/bsp ]
then
	cp -raf bsp build/linux
fi

cd build/linux
export ARCH=arm64
rm -rf ../linux-*.deb
make mrproper
make $CONFIG
make -j$(nproc)
make deb-pkg
