#!/bin/bash

git clone https://github.com/facebookresearch/faiss
cd faiss

# Configure paths and set environment variables
export PATH=$PATH:$HOME/.local/bin:/usr/local/cuda/bin
source /opt/intel/oneapi/setvars.sh

# Configure using cmake

cmake -B build . -DBUILD_SHARED_LIBS=ON -DFAISS_ENABLE_GPU=ON -DFAISS_ENABLE_PYTHON=ON -DFAISS_ENABLE_RAFT=OFF -DBUILD_TESTING=ON -DBUILD_SHARED_LIBS=ON -DFAISS_ENABLE_C_API=ON -DCMAKE_BUILD_TYPE=Release -DFAISS_OPT_LEVEL=avx2 -Wno-dev

# Now build faiss

make -C build -j$(nproc) faiss
make -C build -j$(nproc) swigfaiss
pushd build/faiss/python;python3 setup.py bdist_wheel;popd

# and install it. NOTE: this will install into the pyenv virtualenv 'aw' from the begining of the script

sudo make -C build -j$(nproc) install
pip install build/faiss/python/dist/faiss-1.7.4-py3-none-any.whl
cp build/faiss/python/dist/faiss-1.7.4-py3-none-any.whl $HOME/

# Add ldconfig settings for intel and faiss libraries

echo '/opt/intel/oneapi/mkl/2023.1.0/lib/intel64' | sudo tee /etc/ld.so.conf.d/aw_intel.conf
echo '/usr/local/lib' | sudo tee /etc/ld.so.conf.d/aw_faiss.conf

# Update the ld cache

sudo ldconfig

