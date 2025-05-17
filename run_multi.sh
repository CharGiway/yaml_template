#!/bin/bash

source get_pod_info.sh

export MASTER_IP=$MASTER_IP
export RANK=$RANK
echo "MASTER_IP ${MASTER_IP}, RANK ${RANK}"

export NCCL_DEBUG=INFO
export NCCL_SOCKET_IFNAME=eth0
export NCCL_IB_GID_INDEX=3
export NCCL_IB_DISABLE=0
export NCCL_IB_HCA=mlx5_bond_0,mlx5_bond_1,mlx5_bond_2,mlx5_bond_3,mlx5_bond_4,mlx5_bond_5,mlx5_bond_6,mlx5_bond_7
export NCCL_NET_GDR_LEVEL=2
export NCCL_IB_QPS_PER_CONNECTION=4
export NCCL_IB_TC=160
export NCCL_IB_TIMEOUT=22
export NCCL_PXN_DISABLE=0
export NCCL_CUMEM_ENABLE=0
export GLOO_SOCKET_IFNAME=eth0

accelerate launch -m \
  --config_file accelerate_cfg_multi.yaml \
  --machine_rank ${RANK} \
  --main_process_ip ${MASTER_IP} \
  --main_process_port 20055 \
  --num_machines 4 \
  --num_processes 4 \
  scripts.train_stage1 --config ./configs/train/stage1.test.yaml

# --config_file accelerate_cfg_multi.yaml
