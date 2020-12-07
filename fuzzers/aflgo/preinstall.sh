#!/bin/bash
set -e

apt-get update 
#&& \
#    apt-get install -y make build-essential clang-9 git wget

LLVM_DEP_PACKAGES="build-essential make cmake ninja-build git subversion python2.7 binutils-gold binutils-dev curl wget"
apt-get install -y $LLVM_DEP_PACKAGES
apt-get update
apt install -y python-dev python3 python3-dev python3-pip autoconf automake libtool-bin python-bs4 libclang-4.0-dev
python3 -m pip install --upgrade pip
python3 -m pip install networkx pydot pydotplus
