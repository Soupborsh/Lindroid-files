#!/usr/bin/env bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 3 ]; then
    echo "Error: Provide 3 arguments"
    echo "Usage: $0 vendor codename architecture"
    exit 1
fi

# Create Lindroid and TheMuppets manifests
mkdir -p .repo/local_manifests/
wget https://raw.githubusercontent.com/Soupborsh/Lindroid-files/refs/heads/main/manifests/general/lindroid.xml -O .repo/local_manifests/lindroid.xml

# TheMuppets
echo '<?xml version="1.0" encoding="UTF-8"?>' > .repo/local_manifests/muppets.xml
echo '<manifest>' >> .repo/local_manifests/muppets.xml
echo "  <project name=\"TheMuppets/proprietary_vendor_$1_$2\" path=\"vendor/$1/$2\" revision=\"lineage-21\" clone-depth=\"1\" />" >> .repo/local_manifests/muppets.xml
echo '</manifest>' >> .repo/local_manifests/muppets.xml

repo sync -c

#Pull device specific data
source build/envsetup.sh
breakfast $2

# Patches
## Linux kernel defconfig
sed -i '/CONFIG_SYSVIPC/d' kernel/$1/$2/arch/$3/configs/$2_defconfig
sed -i '/CONFIG_UTS_NS/d' kernel/$1/$2/arch/$3/configs/$2_defconfig
sed -i '/CONFIG_IPC_NS/d' kernel/$1/$2/arch/$3/configs/$2_defconfig
sed -i '/CONFIG_USER_NS/d' kernel/$1/$2/arch/$3/configs/$2_defconfig
sed -i '/CONFIG_NET_NS/d' kernel/$1/$2/arch/$3/configs/$2_defconfig
sed -i '/CONFIG_CGROUP_DEVICE/d' kernel/$1/$2/arch/$3/configs/$2_defconfig

echo 'CONFIG_SYSVIPC=y' >> kernel/$1/$2/arch/$3/configs/$2_defconfig
echo 'CONFIG_UTS_NS=y' >> kernel/$1/$2/arch/$3/configs/$2_defconfig
echo 'CONFIG_IPC_NS=y' >> kernel/$1/$2/arch/$3/configs/$2_defconfig
echo 'CONFIG_USER_NS=y' >> kernel/$1/$2/arch/$3/configs/$2_defconfig
echo 'CONFIG_NET_NS=y' >> kernel/$1/$2/arch/$3/configs/$2_defconfig
echo 'CONFIG_CGROUP_DEVICE=y' >> kernel/$1/$2/arch/$3/configs/$2_defconfig

## Download patches
wget https://raw.githubusercontent.com/Soupborsh/Lindroid-files/refs/heads/main/patches/general/EventHub.patch
wget https://github.com/android-kxxt/android_kernel_xiaomi_sm8450/commit/ae700d3d04a2cd8b34e1dae434b0fdc9cde535c7.patch
wget https://raw.githubusercontent.com/Soupborsh/Lindroid-files/refs/heads/main/patches/general/0001-Ignore-uevent-s-with-null-name-for-Extcon-WiredAcces.patch
wget https://github.com/Linux-on-droid/vendor_lindroid/commit/10f98759162a0034a2afa62c5977f9bcf921db13.patch

## Apply patches
patch frameworks/native/services/inputflinger/reader/EventHub.cpp EventHub.patch
patch kernel/$1/$2/fs/overlayfs/util.c ae700d3d04a2cd8b34e1dae434b0fdc9cde535c7.patch
git apply 0001-Ignore-uevent-s-with-null-name-for-Extcon-WiredAcces.patch --directory=frameworks/base/
patch -R vendor/lindroid/app/app/src/main/java/org/lindroid/ui/DisplayActivity.java 10f98759162a0034a2afa62c5977f9bcf921db13.patch

## Remove patch files
rm EventHub.patch
rm ae700d3d04a2cd8b34e1dae434b0fdc9cde535c7.patch
rm 0001-Ignore-uevent-s-with-null-name-for-Extcon-WiredAcces.patch
rm 10f98759162a0034a2afa62c5977f9bcf921db13.patch

# Set SELinux to permissive
echo '' >> device/$1/$2/BoardConfig.mk
echo '# Set SELinux to permissive' >> device/$1/$2/BoardConfig.mk
echo 'BOARD_KERNEL_CMDLINE += androidboot.selinux=permissive' >> device/$1/$2/BoardConfig.mk
echo '$(call inherit-product, vendor/lindroid/lindroid.mk)' >> device/$1/$2/lineage_$2.mk

# Fix building by removing CONFIG_SYSVIPC from android-base.config
KERNEL_VERSION=$(grep -E '^VERSION' kernel/$1/$2/Makefile | cut -d' ' -f3)
PATCHLEVEL=$(grep -E '^PATCHLEVEL' kernel/$1/$2/Makefile | cut -d' ' -f3)

sed -i '/# CONFIG_SYSVIPC is not set/d' kernel/configs/*/android-${KERNEL_VERSION}.${PATCHLEVEL}/android-base.config

# Build
croot
brunch $2

rm ./build.sh

exit 0
