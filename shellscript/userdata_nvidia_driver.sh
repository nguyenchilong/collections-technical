#!/bin/sh

BASE_URL=https://us.download.nvidia.com/tesla
DRIVER_VERSION=535.129.03

# install nvidia driver
sudo yum update -y
sudo yum install -y binutils Xorg libvdpau glibc gcc make kernel-devel-$(uname -r)
wget -O /tmp/NVIDIA-Linux-x86_64-$DRIVER_VERSION.run $BASE_URL/$DRIVER_VERSION/NVIDIA-Linux-x86_64-$DRIVER_VERSION.run
cd /tmp/
sudo CC=/usr/bin/gcc10-cc ./NVIDIA-Linux-x86_64-$DRIVER_VERSION.run
# ./nvidia-installer –ui=none –no-questions –accept-license –disable-nouveau –no-cc-version-check –install-libglvnd
cd ~/
nvidia-smi --version

# install docker
sudo yum install -y docker
sudo usermod -a -G docker ec2-user
sudo systemctl enable docker.service
sudo systemctl start docker.service
docker version

# install nvidia container runtime
sudo yum install -y nvidia-docker2 nvidia-container-runtime
sudo systemctl restart docker

# enbale ECS support GPU
sudo mkdir -p /etc/ecs/
sudo touch /etc/ecs/ecs.config
echo "ECS_ENABLE_GPU_SUPPORT=true" | sudo tee -a /etc/ecs/ecs.config

# install cuda driver
wget https://developer.download.nvidia.com/compute/cuda/12.3.1/local_installers/cuda_12.3.1_545.23.08_linux.runsudo 
sh cuda_12.3.1_545.23.08_linux.run

# install cuda_gdb open source
CUDA_GDB_ALL=cuda_gdb_src-all-all-12.3.101.tar.gz
wget https://developer.download.nvidia.com/compute/cuda/opensource/12.3.1/$CUDA_GDB_ALL
tar -zxvf CUDA_GDB_ALL
cd cuda_gdb_src
./configure --program-prefix=cuda- --enable-cuda --enable-targets="x86_64-unknown-linux-gnu,arm-elf-linux-gnu,m68k-unknown-linux-gnu" CFLAGS="-I/usr/local/cuda/include" LDFLAGS="-lpthread"
make
make install
cd ../
rm -rf CUDA_GDB_ALL cuda_gdb_src