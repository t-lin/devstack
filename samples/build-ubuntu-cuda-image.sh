#!/bin/sh

if [ -n "$1" ]; then
    IMG=$1
else
    echo "Must specify first parameter (name of image)"
    ERR=1
fi

if [ -n "$2" ]; then
    CACHE_DIR=$2
else
    echo "Must specify second parameter (cache directory)"
    ERR=1
fi

if [ "$ERR" ]; then
    exit 0
fi

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
IMAGE_SIZE=6000
FINAL_IMAGE_SIZE=2800
dd if=/dev/zero of="$IMG" bs=1M count=0 seek=$IMAGE_SIZE
mkfs -F -t ext4 "$IMG"
MNT_DIR=`mktemp -d`
sudo mount -o loop "$IMG" "${MNT_DIR}"
sudo tar -C "${MNT_DIR}" -xzf "$SRC_CACHE"
sudo mv "${MNT_DIR}/etc/resolv.conf" "${MNT_DIR}/etc/resolv.conf_orig"
sudo cp /etc/resolv.conf "${MNT_DIR}/etc/resolv.conf"
sudo chroot "${MNT_DIR}" apt-get -y install linux-image-`uname -r` vlan open-iscsi
sudo chroot "${MNT_DIR}" passwd ubuntu < $PASS_FILE

#This part is specific to whatever an image needs 

# Install ncessary tools and libraries
sudo chroot "${MNT_DIR}" apt-get -y update
sudo chroot "${MNT_DIR}" apt-get -y install freeglut3-dev build-essential libx11-dev libxmu-dev libxi-dev libgl1-mesa-glx libglu1-mesa libglu1-mesa-dev --fix-missing
sudo chroot "${MNT_DIR}" apt-get remove --purge nvidia*

# Install linux headers
sudo chroot "${MNT_DIR}" apt-get -y install linux-headers-`uname -r`

# Update module blacklist (may conflict with installation)
sudo sh -c "echo '' >> "${MNT_DIR}/etc/modprobe.d/blacklist.conf""
#sudo sh -c "echo 'blacklist amd76x_edac' >> "${MNT_DIR}/etc/modprobe.d/blacklist.conf""
sudo sh -c "echo 'blacklist vga16fb' >> "${MNT_DIR}/etc/modprobe.d/blacklist.conf""
sudo sh -c "echo 'blacklist nouveau' >> "${MNT_DIR}/etc/modprobe.d/blacklist.conf""
sudo sh -c "echo 'blacklist rivafb' >> "${MNT_DIR}/etc/modprobe.d/blacklist.conf""
sudo sh -c "echo 'blacklist nvidiafb' >> "${MNT_DIR}/etc/modprobe.d/blacklist.conf""
sudo sh -c "echo 'blacklist rivatv' >> "${MNT_DIR}/etc/modprobe.d/blacklist.conf""
sudo sh -c "echo '' >> "${MNT_DIR}/etc/modprobe.d/blacklist.conf""

# Create symbolic link for missing library
sudo chroot "${MNT_DIR}" ln -s /usr/lib/x86_64-linux-gnu/libglut.so.3 /usr/lib/libglut.so

# Copy NVIDIA driver installer over
sudo cp "${CACHE_DIR}/cuda_files/devdriver_5.0_linux_64_304.54.run" "${MNT_DIR}/home/ubuntu/devdriver_5.0_linux_64_304.54.run"

echo "About to run installer for NVIDIA driver"
echo "Press 'enter' for any questions asked"
read -p "Press any key to continue..." blek

# Install NVIDIA driver
sudo chroot "${MNT_DIR}" chmod +x /home/ubuntu/devdriver_5.0_linux_64_304.54.run
sudo chroot "${MNT_DIR}" /home/ubuntu/devdriver_5.0_linux_64_304.54.run -a -k `uname -r`

# Delete NVIDIA driver installer
sudo rm "${MNT_DIR}/home/ubuntu/devdriver_5.0_linux_64_304.54.run"

# Copy CUDA SDK Toolkit installer over
sudo cp "${CACHE_DIR}/cuda_files/cudatoolkit_5.0.35_linux_64_ubuntu11.10.run" "${MNT_DIR}/home/ubuntu/cudatoolkit_5.0.35_linux_64_ubuntu11.10.run"

echo "About to run installer for CUDA SDK Toolkit"
read -p "Press any key to continue..." blek

# Install CUDA SDK Toolkit
sudo chroot "${MNT_DIR}" chmod +x /home/ubuntu/cudatoolkit_5.0.35_linux_64_ubuntu11.10.run
sudo chroot "${MNT_DIR}" /home/ubuntu/cudatoolkit_5.0.35_linux_64_ubuntu11.10.run -noprompt

# Delete CUDA SDK Toolkit installer
sudo rm "${MNT_DIR}/home/ubuntu/cudatoolkit_5.0.35_linux_64_ubuntu11.10.run"

# Update environment variables
sudo sh -c "echo '' >> "${MNT_DIR}/home/ubuntu/.bashrc""
sudo sh -c "echo 'export PATH=$PATH:/usr/local/cuda-5.0/bin' >> "${MNT_DIR}/home/ubuntu/.bashrc""
sudo sh -c "echo 'export LD_LIBRARY_PATH=/usr/local/cuda-5.0/lib64:/lib' >> "${MNT_DIR}/home/ubuntu/.bashrc""
sudo sh -c "echo '' >> "${MNT_DIR}/home/ubuntu/.bashrc""

# Create cudainit file
sudo cp "${CACHE_DIR}/cuda_files/cudainit" "${MNT_DIR}/bin/cudainit"
sudo chroot "${MNT_DIR}" chmod 755 /bin/cudainit

# Add cudainit to rc.local
sudo sed -i -e 's/exit 0/cudainit/g' "${MNT_DIR}/etc/rc.local"
sudo sh -c "echo '' >> "${MNT_DIR}/etc/rc.local""
sudo sh -c "echo 'exit 0' >> "${MNT_DIR}/etc/rc.local""
#up to here

#sudo cp "${MNT_DIR}/boot/vmlinuz-3.2.0-26-generic" "$CACHE_DIR/kernel"
#sudo chmod a+r "$CACHE_DIR/kernel"
#cp "${MNT_DIR}/boot/initrd.img-3.2.0-26-generic" "$CACHE_DIR/initrd"
sudo mv "${MNT_DIR}/etc/resolv.conf_orig" "${MNT_DIR}/etc/resolv.conf"
sudo umount "${MNT_DIR}"

# Resize the image
echo "Resizing the image, please wait..."
sudo e2fsck -f -p $IMG
sudo resize2fs -p $IMG ${FINAL_IMAGE_SIZE}M

