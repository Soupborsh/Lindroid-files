#!/usr/bin/env bash

Help()
{
   # Display Help
   echo "LineageOS with Lindroid building script."
   echo
   echo "Usage: $0 vendor codename architecture [-f|h]"
   echo "options:"
   echo "-h     Print this help text."
   echo "-f     No firmware(experimental, probably won't work)"
   echo
}

# Check if the correct number of arguments is provided
if [ "$#" -lt 3 ]; then
    echo "Error: Provide at least 3 arguments"
    Help
    exit 1
fi

VENDOR=$1
CODENAME=$2
ARCHITECTURE=$3

EMBED_FIRMWARE=1

# Get the options
while getopts ":hf" option; do
   case $option in
      h) # display Help
         Help
         exit;;
      f) # do not embed firmware
         EMBED_FIRMWARE=0
         ;;
     \?) # Invalid option
         echo "Error: Invalid option"
         echo
         exit 1;;
   esac
done

# Create Lindroid and TheMuppets manifests
mkdir -p .repo/local_manifests/
wget https://raw.githubusercontent.com/Soupborsh/Lindroid-files/refs/heads/main/manifests/general/lindroid.xml -O .repo/local_manifests/lindroid.xml

if [ EMBED_FIRMWARE -eq 1 ]; then
    # TheMuppets
    echo '<?xml version="1.0" encoding="UTF-8"?>' > .repo/local_manifests/muppets.xml
    echo '<manifest>' >> .repo/local_manifests/muppets.xml
    echo "  <project name=\"TheMuppets/proprietary_vendor_$VENDOR_$CODENAME\" path=\"vendor/$VENDOR/$CODENAME\" revision=\"lineage-21\" clone-depth=\"1\" />" >> .repo/local_manifests/muppets.xml
    echo '</manifest>' >> .repo/local_manifests/muppets.xml

else
    if [[ "$CODENAME" == "surya" ]]; then
        wget https://github.com/LineageOS/android_device_xiaomi_surya/commit/5f1c5e920a982e3c2cac76c73bbf34933da3a282.patch
        git apply -R 5f1c5e920a982e3c2cac76c73bbf34933da3a282.patch --directory=device/$VENDOR/$CODENAME
        rm 5f1c5e920a982e3c2cac76c73bbf34933da3a282.patch
    fi
fi


repo sync -c

#Pull device specific data
source build/envsetup.sh
breakfast $CODENAME

# Patches
## Linux kernel defconfig
sed -i '/CONFIG_SYSVIPC/d' kernel/$VENDOR/$CODENAME/arch/$ARCHITECTURE/configs/$CODENAME_defconfig
sed -i '/CONFIG_UTS_NS/d' kernel/$VENDOR/$CODENAME/arch/$ARCHITECTURE/configs/$CODENAME_defconfig
sed -i '/CONFIG_PID_NS/d' kernel/$VENDOR/$CODENAME/arch/$ARCHITECTURE/configs/$CODENAME_defconfig
sed -i '/CONFIG_IPC_NS/d' kernel/$VENDOR/$CODENAME/arch/$ARCHITECTURE/configs/$CODENAME_defconfig
sed -i '/CONFIG_USER_NS/d' kernel/$VENDOR/$CODENAME/arch/$ARCHITECTURE/configs/$CODENAME_defconfig
sed -i '/CONFIG_NET_NS/d' kernel/$VENDOR/$CODENAME/arch/$ARCHITECTURE/configs/$CODENAME_defconfig
sed -i '/CONFIG_CGROUP_DEVICE/d' kernel/$VENDOR/$CODENAME/arch/$ARCHITECTURE/configs/$CODENAME_defconfig
sed -i '/CONFIG_GROUP_FREEZER/d' kernel/$VENDOR/$CODENAME/arch/$ARCHITECTURE/configs/$CODENAME_defconfig

echo 'CONFIG_SYSVIPC=y' >> kernel/$VENDOR/$CODENAME/arch/$ARCHITECTURE/configs/$CODENAME_defconfig
echo 'CONFIG_UTS_NS=y' >> kernel/$VENDOR/$CODENAME/arch/$ARCHITECTURE/configs/$CODENAME_defconfig
echo 'CONFIG_PID_NS=y' >> kernel/$VENDOR/$CODENAME/arch/$ARCHITECTURE/configs/$CODENAME_defconfig
echo 'CONFIG_IPC_NS=y' >> kernel/$VENDOR/$CODENAME/arch/$ARCHITECTURE/configs/$CODENAME_defconfig
echo 'CONFIG_USER_NS=y' >> kernel/$VENDOR/$CODENAME/arch/$ARCHITECTURE/configs/$CODENAME_defconfig
echo 'CONFIG_NET_NS=y' >> kernel/$VENDOR/$CODENAME/arch/$ARCHITECTURE/configs/$CODENAME_defconfig
echo 'CONFIG_CGROUP_DEVICE=y' >> kernel/$VENDOR/$CODENAME/arch/$ARCHITECTURE/configs/$CODENAME_defconfig
echo 'CONFIG_GROUP_FREEZER=y' >> kernel/$VENDOR/$CODENAME/arch/$ARCHITECTURE/configs/$CODENAME_defconfig

## Download patches
wget https://raw.githubusercontent.com/Soupborsh/Lindroid-files/refs/heads/main/patches/general/EventHub.patch
wget https://github.com/android-kxxt/android_kernel_xiaomi_sm8450/commit/ae700d3d04a2cd8b34e1dae434b0fdc9cde535c7.patch
wget https://raw.githubusercontent.com/Soupborsh/Lindroid-files/refs/heads/main/patches/general/0001-Ignore-uevent-s-with-null-name-for-Extcon-WiredAcces.patch
wget https://github.com/Linux-on-droid/vendor_lindroid/commit/10f98759162a0034a2afa62c5977f9bcf921db13.patch

## Apply patches
patch frameworks/native/services/inputflinger/reader/EventHub.cpp EventHub.patch
patch kernel/$VENDOR/$CODENAME/fs/overlayfs/util.c ae700d3d04a2cd8b34e1dae434b0fdc9cde535c7.patch
git apply 0001-Ignore-uevent-s-with-null-name-for-Extcon-WiredAcces.patch --directory=frameworks/base/
patch -R vendor/lindroid/app/app/src/main/java/org/lindroid/ui/DisplayActivity.java 10f98759162a0034a2afa62c5977f9bcf921db13.patch

## Remove patch files
rm EventHub.patch
rm ae700d3d04a2cd8b34e1dae434b0fdc9cde535c7.patch
rm 0001-Ignore-uevent-s-with-null-name-for-Extcon-WiredAcces.patch
rm 10f98759162a0034a2afa62c5977f9bcf921db13.patch

# Fix building by removing CONFIG_SYSVIPC from android-base.config
KERNEL_VERSION=$(grep -E '^VERSION' kernel/$VENDOR/$CODENAME/Makefile | cut -d' ' -f3)
PATCHLEVEL=$(grep -E '^PATCHLEVEL' kernel/$VENDOR/$CODENAME/Makefile | cut -d' ' -f3)

sed -i '/# CONFIG_SYSVIPC is not set/d' kernel/configs/*/android-${KERNEL_VERSION}.${PATCHLEVEL}/android-base.config

# Build
croot
brunch $CODENAME

exit 0
