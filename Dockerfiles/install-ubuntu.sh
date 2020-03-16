#!/bin/bash
set -e

# parse command line arguments
cuda=false

for key in "$@"; do
    case $key in
        --cuda)
        cuda=true
        ;;
    esac
done

# install requirements
apt-get -y update
apt-get -y install \
  build-essential \
  curl \
  git \
  cmake \
  unzip \
  autoconf \
  autogen \
  libtool \
  mlocate \
  zlib1g-dev \
  g++-7 \
  python \
  python3-numpy \
  python3-dev \
  python3-pip \
  python3-wheel \
  sudo \
  wget

# install bazel
export BAZEL_VERSION=${BAZEL_VERSION:-`cat ./tensorflow_cc/Dockerfiles/BAZEL_VERSION`}
apt-get -y install pkg-config zip g++ zlib1g-dev unzip python
bazel_installer=bazel-${BAZEL_VERSION}-installer-linux-x86_64.sh
wget -P /tmp https://github.com/bazelbuild/bazel/releases/download/${BAZEL_VERSION}/${bazel_installer}
chmod +x /tmp/${bazel_installer}
/tmp/${bazel_installer}
rm /tmp/${bazel_installer}

if $cuda; then
    # install libcupti
    apt-get -y install cuda-command-line-tools-10-1
fi

apt-get -y clean

# when building TF with Intel MKL support, `locate` database needs to exist
updatedb

# build and install tensorflow_cc
./tensorflow_cc/Dockerfiles/install-common.sh "$@"
