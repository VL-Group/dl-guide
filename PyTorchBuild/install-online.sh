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


echo "Fetch PyTorch"

git clone --recursive https://github.com/pytorch/pytorch
cd pytorch

set +e
set +o

git submodule sync
git submodule update --init --recursive


set -e
set -o pipefail

echo "Install PyTorch"


export CMAKE_PREFIX_PATH=${CONDA_PREFIX:-"$(dirname $(which conda))/../"}

python setup.py clean

python setup.py install

cd ..

echo "Fetch torchvision"

git clone https://github.com/pytorch/vision.git torchvision

cd torchvision

echo "Install torchvision"

python setup.py clean

python setup.py install

cd ..

echo "Fetch torchtext"

git clone https://github.com/pytorch/text torchtext
cd torchtext

set +e
set +o
git submodule update --init --recursive
set -e
set -o pipefail

echo "Install torchtext"

python setup.py clean

python setup.py install

cd ..

echo "Install complete, clean up"

cd pytorch

python setup.py clean

cd ..

cd torchvision

python setup.py clean

cd ..

cd torchtext

python setup.py clean

cd ..

rm -rf pytorch torchvision torchtext

echo "Check your install by:"

echo ">>> import torch${NEWLINE}>>> torch.randn(5).cuda()${NEWLINE}tensor([-0.0970,  0.2332, -0.7501, -0.2322,  1.0216], device='cuda:0')${NEWLINE}>>> torch.backends.cudnn.is_acceptable(torch.randn(5).cuda())${NEWLINE}True"
