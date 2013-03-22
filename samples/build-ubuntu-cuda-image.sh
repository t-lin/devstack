#!/bin/sh

if [ -n "$1" ]; then
    IMG=$1
else
    echo "Must specify first parameter (name of image to be made)"
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

#image size in MB (NOTE: Leave at least 100 MB extra space for final image size)
IMAGE_SIZE=6000
FINAL_IMAGE_SIZE=3000
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
CUDA_CACHE=${CACHE_DIR}/cuda_files
CUDA_CACHE=`readlink -f ${CUDA_CACHE}`
sudo mkdir -p ${CUDA_CACHE}

CUDA_FILENAME=cuda_installer.run
CUDA_INSTALLER_URL=http://developer.download.nvidia.com/compute/cuda/5_0/rel-update-1/installers/cuda_5.0.35_linux_64_ubuntu11.10-1.run
CUDA_INSTALLER=${CUDA_CACHE}/${CUDA_FILENAME}

# Download the CUDA SDK Toolkit + Driver installers
if [ ! -f "${CUDA_INSTALLER}" ]; then
    # First clear cache to avoid any conflicting files
    sudo rm -rf ${CUDA_CACHE}/*

    echo "Downloading CUDA SDK Toolkit + Driver installer..."
    wget "$CUDA_INSTALLER_URL" -O - > "$CUDA_INSTALLER"
    sudo chmod 755 $CUDA_INSTALLER
fi

# First clear cuda cache to avoid any conflicting files
sudo mv ${CUDA_INSTALLER} ${CACHE_DIR}/
sudo rm -rf ${CUDA_CACHE}/*
sudo mv ${CACHE_DIR}/${CUDA_FILENAME} ${CUDA_INSTALLER}

# Extract individual installers (samples, toolkit, driver)
sudo ${CUDA_INSTALLER} -extract=${CUDA_CACHE}

SAMPLES_FILENAME=`sudo ls -l ${CUDA_CACHE} | grep samples | awk '{print $9}'`
DRIVER_FILENAME=`sudo ls -l ${CUDA_CACHE} | grep devdriver | awk '{print $9}'`
SDK_TOOLKIT_FILENAME=`sudo ls -l ${CUDA_CACHE} | grep toolkit | awk '{print $9}'`

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
sudo cp "${CUDA_CACHE}/${DRIVER_FILENAME}" "${MNT_DIR}/home/ubuntu/${DRIVER_FILENAME}"

echo ""
echo "About to run installer for NVIDIA driver"
echo "Press 'enter' for any questions asked"
read -p "Press any key to continue..." blek

# Install NVIDIA driver
sudo chroot "${MNT_DIR}" chmod +x /home/ubuntu/${DRIVER_FILENAME}
sudo chroot "${MNT_DIR}" /home/ubuntu/${DRIVER_FILENAME} -a -k `uname -r`

# Delete NVIDIA driver installer
sudo rm "${MNT_DIR}/home/ubuntu/${DRIVER_FILENAME}"

# Copy CUDA SDK Toolkit installer over
sudo cp "${CACHE_DIR}/cuda_files/${SDK_TOOLKIT_FILENAME}" "${MNT_DIR}/home/ubuntu/${SDK_TOOLKIT_FILENAME}"

# Install CUDA SDK Toolkit
echo ""
echo "Running installer for CUDA SDK Toolkit..."
sudo chroot "${MNT_DIR}" chmod +x /home/ubuntu/${SDK_TOOLKIT_FILENAME}
sudo chroot "${MNT_DIR}" /home/ubuntu/${SDK_TOOLKIT_FILENAME} -noprompt

# Delete CUDA SDK Toolkit installer
sudo rm "${MNT_DIR}/home/ubuntu/${SDK_TOOLKIT_FILENAME}"

# Update environment variables in bashrc
sudo sh -c "echo '' >> "${MNT_DIR}/home/ubuntu/.bashrc""
sudo sh -c "echo 'export PATH=$PATH:/usr/local/cuda-5.0/bin' >> "${MNT_DIR}/home/ubuntu/.bashrc""
sudo sh -c "echo 'export LD_LIBRARY_PATH=/usr/local/cuda-5.0/lib64:/lib' >> "${MNT_DIR}/home/ubuntu/.bashrc""
sudo sh -c "echo '' >> "${MNT_DIR}/home/ubuntu/.bashrc""

# Create cudainit file
CUDAINIT_CACHE=${CACHE_DIR}/cuda_files/cudainit
if [ ! -f "${CUDAINIT_CACHE}" ]; then
    sudo touch ${CUDAINIT_CACHE}
    sudo chmod o+w ${CUDAINIT_CACHE}
    sudo cat <<EOF > ${CUDAINIT_CACHE}
#!/bin/bash

/sbin/modprobe nvidia

if [ "\$?" -eq 0 ]; then
  # Count the number of NVIDIA controllers found.
  NVDEVS=\`lspci | grep -i NVIDIA\`
  N3D=\`echo "\$NVDEVS" | grep "3D controller" | wc -l\`
  NVGA=\`echo "\$NVDEVS" | grep "VGA compatible controller" | wc -l\`

  N=\`expr \$N3D + \$NVGA - 1\`
  for i in \`seq 0 \$N\`; do
    mknod -m 666 /dev/nvidia\$i c 195 \$i
  done

  mknod -m 666 /dev/nvidiactl c 195 255

else
  exit 1
fi

EOF
    sudo chmod 755 ${CUDAINIT_CACHE}
fi
sudo cp "${CUDAINIT_CACHE}" "${MNT_DIR}/bin/cudainit"
sudo chroot "${MNT_DIR}" chmod 755 /bin/cudainit

# Add cudainit to rc.local
sudo sed -i -e 's/exit 0/cudainit/g' "${MNT_DIR}/etc/rc.local"
sudo sh -c "echo '' >> "${MNT_DIR}/etc/rc.local""
sudo sh -c "echo 'exit 0' >> "${MNT_DIR}/etc/rc.local""

# Clean up installer files
sudo rm ${CUDA_CACHE}/${SAMPLES_FILENAME}
sudo rm ${CUDA_CACHE}/${SDK_TOOLKIT_FILENAME}
sudo rm ${CUDA_CACHE}/${DRIVER_FILENAME}
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

