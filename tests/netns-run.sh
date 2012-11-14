#!/bin/sh
echo "all netns:"
ip netns list
echo "running in netns:"
ip netns list | grep $1
sudo ip netns exec `ip netns list | grep $1` $2 
