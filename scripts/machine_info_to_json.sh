#!/bin/bash

cpuname=$(lscpu | egrep 'Model name' | sed 's/^.*:\s\+//')
echo $cpuname

lscpu | egrep 'Thread'
cpu_threads=$(lscpu | egrep 'per core' | sed 's/^.*:\s\+//')
echo $cpu_threads

cpu_cores=$(cat /proc/cpuinfo | grep cores | xargs | sed 's/^.*:\s\+//')
echo $cpu_cores

cpu_threads=$(cat /proc/cpuinfo | grep siblings | xargs | sed 's/^.*:\s\+//')
echo $cpu_threads

gpu_name=$(nvidia-smi --query-gpu=name --format=csv,noheader)
echo $gpu_name

gpu_ram=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader)
echo $gpu_ram

gpu_driver_version=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader)
echo $gpu_driver_version

gpu_cuda_version=$(cat /usr/local/cuda/version.txt)
echo $gpu_cuda_version

os_version=$(hostnamectl | egrep 'Operating System' | sed 's/^.*:\s\+//')
kernel_version=$(hostnamectl | grep Kernel | sed 's/^.*:\s\+//')
machine_ram=$(cat /proc/meminfo | grep MemTotal | sed 's/^.*:\s\+//')

cat <<EOF > myjson.json
{
    "osInfo" : "$os_version",
    "osKernelVersion" : "$kernel_version",
    "machineRamGb" : "$machine_ram",
    "maxCpuCores" : "$cpu_cores",
    "maxCpuThreads" : "$cpu_threads",
    "gpuInfo" : "$gpu_name",
    "gpuCudaVersion" : "Driver version $gpu_driver_version $gpu_cuda_version",
    "gpuRamGb" : "$gpu_ram",
}
EOF
