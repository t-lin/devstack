#!/bin/sh

IMG=$1
CACHE_DIR=$2

UBUNTU_PASS=savi
PASS_FILE=$CACHE_DIR/passfile

touch $PASS_FILE
echo $UBUNTU_PASS > $PASS_FILE
echo $UBUNTU_PASS >> $PASS_FILE
echo "\n" >> $PASS_FILE

SRC_URL=http://cloud-images.ubuntu.com/precise/current/precise-server-cloudimg-amd64-root.tar.gz
SRC_CACHE=$CACHE_DIR/precise-server-cloudimg-amd64-root.tar.gz

if [ -f "$IMG" ]; then
    exit 0
fi

if ! [ -f "$SRC_CACHE" ]; then
    wget "$SRC_URL" -O - > "$SRC_CACHE"
fi

#image size in MB
IMAGE_SIZE=1600
dd if=/dev/zero of="$IMG" bs=1M count=0 seek=$IMAGE_SIZE
mkfs -F -t ext4 "$IMG"
MNT_DIR=`mktemp -d`
sudo mount -o loop "$IMG" "${MNT_DIR}"
sudo tar -C "${MNT_DIR}" -xzf "$SRC_CACHE"
sudo mv "${MNT_DIR}/etc/resolv.conf" "${MNT_DIR}/etc/resolv.conf_orig"
sudo cp /etc/resolv.conf "${MNT_DIR}/etc/resolv.conf"
sudo chroot "${MNT_DIR}" apt-get -y install linux-image-3.2.0-26-generic vlan open-iscsi
sudo chroot "${MNT_DIR}" passwd ubuntu < $PASS_FILE
sudo mv "${MNT_DIR}/etc/resolv.conf_orig" "${MNT_DIR}/etc/resolv.conf"

#This part is specific to whatever an image needs 

sudo sudo tar -C "${MNT_DIR}/home/ubuntu/" -xzf NetFPGA-10G-live.tar.gz
sudo mkdir -p "${MNT_DIR}/lib/modules/3.2.0-26-generic/kernel/drivers/net/ethernet/nf10"
sudo cp "${MNT_DIR}/home/ubuntu/NetFPGA-10G-live/contrib-projects/nic/sw/host/driver/nf10.ko" "${MNT_DIR}/lib/modules/3.2.0-26-generic/kernel/drivers/net/ethernet/nf10/nf10.ko"
sudo cp "${MNT_DIR}/home/ubuntu/NetFPGA-10G-live/contrib-projects/nic/sw/host/driver/nf10.ko" "${MNT_DIR}/home/ubuntu/"
sudo cp "${MNT_DIR}/home/ubuntu/NetFPGA-10G-live/contrib-projects/flash/sw/host/nf10_configure/nf10_configure" "${MNT_DIR}/home/ubuntu/"
sudo cp "${MNT_DIR}/home/ubuntu/NetFPGA-10G-live/projects/reference_nic/sw/host/driver/bin/nf10_eth_driver*" "${MNT_DIR}/home/ubuntu/"

#do not change this part

sudo sh -c "cat \"${MNT_DIR}/etc/rc.local\" | sed \"s/exit 0/\/sbin\/depmod -a\nexit 0/g\" > /tmp/temp_file1"
sudo cp /tmp/temp_file1 "${MNT_DIR}/etc/rc.local"

sudo sh -c "cat \"${MNT_DIR}/etc/init/cloud-init-nonet.conf\" | sed \"s/long=120/long=15/g\" > /tmp/temp_file1"
sudo cp /tmp/temp_file1 "${MNT_DIR}/etc/init/cloud-init-nonet.conf"

sudo sh -c "cat \"${MNT_DIR}/etc/init/failsafe.conf\" | sed \"s/sleep 20/sleep 8/g\" | sed \"s/sleep 40/sleep 2/g\" | sed \"s/sleep 59/sleep 10/g\" > /tmp/temp_file1"
sudo cp /tmp/temp_file1 "${MNT_DIR}/etc/init/failsafe.conf"

sudo sh -c "cat \"${MNT_DIR}/usr/lib/python2.7/dist-packages/cloudinit/DataSourceEc2.py\" | sed \"s/max_wait = 120/max_wait = 15/g\" > /tmp/temp_file1"
sudo cp /tmp/temp_file1 "${MNT_DIR}/usr/lib/python2.7/dist-packages/cloudinit/DataSourceEc2.py"

sudo rm /tmp/temp_file1

sudo cp "${CACHE_DIR}/upstart" "${MNT_DIR}/etc/network/if-up.d/upstart"

#up to here

#sudo cp "${MNT_DIR}/boot/vmlinuz-3.2.0-26-generic" "$CACHE_DIR/kernel"
#sudo chmod a+r "$CACHE_DIR/kernel"
#cp "${MNT_DIR}/boot/initrd.img-3.2.0-26-generic" "$CACHE_DIR/initrd"
sudo umount "${MNT_DIR}"
