#!/usr/bin/env bash

NEWLINE=$'\n'

set -e
set -o pipefail

read -n 1 -s -r -p  "Ensure you are in conda virtual-env, and command 'conda' is avaliable, then press ENTER:${NEWLINE}"


read -n 1 -s -r -p  "This installation will at current dir, make sure you are in correct dir, then press ENTER:${NEWLINE}"


echo "Install common depedencies"

conda install -y numpy ninja pyyaml mkl mkl-include setuptools cmake cffi typing_extensions future six requests dataclasses

echo "Install Magma CUDA 11.0"

conda install -y -c pytorch magma-cuda110


echo "Copy pytorch.zip"

cp /mnt/hdd1/pytorch.zip ./

unzip -o pytorch.zip

cd pytorch

echo "Install PyTorch"

export CMAKE_PREFIX_PATH=${CONDA_PREFIX:-"$(dirname $(which conda))/../"}

python setup.py install

cd ..

echo "Copy torchvision.zip"

cp /mnt/hdd1/torchvision.zip ./

unzip -o torchvision.zip

cd vision

echo "Install torchvision"

python setup.py install

