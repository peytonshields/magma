#!/bin/bash
set -e

#apt-get update 
##&& \
##    apt-get install -y make build-essential clang-9 git wget
#
#LLVM_DEP_PACKAGES="build-essential make cmake ninja-build git subversion python2.7 binutils-gold binutils-dev curl wget"
#apt-get install -y $LLVM_DEP_PACKAGES
#apt-get update
#apt install -y python-dev python3 python3-dev python3-pip autoconf automake libtool-bin python-bs4 libclang-4.0-dev splitpatch
#python3 -m pip install --upgrade pip
#python3 -m pip install networkx pydot pydotplus

apt-get update

LLVM_DEP_PACKAGES="build-essential make cmake ninja-build git binutils-gold binutils-dev curl wget"
apt-get install -y $LLVM_DEP_PACKAGES

UBUNTU_VERSION=`cat /etc/os-release | grep VERSION_ID | cut -d= -f 2`
UBUNTU_YEAR=`echo $UBUNTU_VERSION | cut -d. -f 1`
UBUNTU_MONTH=`echo $UBUNTU_VERSION | cut -d. -f 2`

apt-get update
apt install -y python3 python3-dev python3-pip python3-distutils autoconf automake libtool-bin python3-bs4 libboost-all-dev # libclang-11.0-dev

pip3 install --upgrade pip
pip3 install networkx
pip3 install pydot
pip3 install pydotplus
