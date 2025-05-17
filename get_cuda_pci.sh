#!/bin/bash
set -e
nvidia-smi --query-gpu=pci.bus_id --format=csv,noheader | head -n 1 > /dev/shm/get_cuda_pci.txt
