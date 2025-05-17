#!/bin/bash
set -e
RANK=$(echo $POD_NAME | awk -F'-' '{print $NF}')
STATEFULSET_NAME=$(echo $POD_NAME | sed 's/-[0-9]*$//')
# 构造目标文件路径
FILE_PATH="`pwd`/${STATEFULSET_NAME}.txt"
DIR_PATH=$(dirname "$FILE_PATH")

# 检查并创建文件路径的目录
if [ ! -d "$DIR_PATH" ]; then
  echo "Directory $DIR_PATH does not exist, creating it..."
  mkdir -p "$DIR_PATH"
fi

# 判断 rank 是否为 0
if [ "$RANK" -eq 0 ]; then
  MASTER_IP=$POD_IP
  echo "Rank 0 Pod, writing IP to $FILE_PATH"
  echo "$POD_IP" > "$FILE_PATH"
  echo "Wrote IP $POD_IP to $FILE_PATH"
else
  # 如果不是 rank 0，等待 /cfs/model/STATEFULSET_NAME.txt 文件被创建并且不为空
  echo "Rank $RANK Pod, waiting for master to write IP to $FILE_PATH"
  while [ ! -s "$FILE_PATH" ]; do
    echo "Waiting for $FILE_PATH to be populated..."
    sleep 1  # 每秒检查一次
  done
  MASTER_IP=$(cat "$FILE_PATH")
  echo "Discovered Master IP: $MASTER_IP"
fi

echo "MASTER_IP ${MASTER_IP}, RANK ${RANK}"
export MASTER_IP=$MASTER_IP
export RANK=$RANK

#设置cuda_device
pci_bus_id=$(cat /dev/shm/get_cuda_pci.txt)
DEVIVES=$(nvidia-smi --query-gpu=index,pci.bus_id --format=csv,noheader | grep "$pci_bus_id" | awk -F, '{print $1}')
export CUDA_VISIBLE_DEVICES=$DEVIVES
