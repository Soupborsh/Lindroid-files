#!/usr/bin/env bash

# Get Lindroid and TheMuppets manifest
mkdir -p .repo/local_manifests/
wget https://raw.githubusercontent.com/Soupborsh/Lindroid-files/refs/heads/main/manifests/general/lindroid.xml -O .repo/local_manifests/lindroid.xml
wget https://raw.githubusercontent.com/Soupborsh/Lindroid-files/refs/heads/main/manifests/$1-$2/muppets.xml -O .repo/local_manifests/muppets.xml
repo sync -c

#Pull device specific data
source build/envsetup.sh
breakfast $2

# Patches
## Download patches
wget https://raw.githubusercontent.com/Soupborsh/Lindroid-files/refs/heads/main/lindroid_defconfig.patch
wget https://raw.githubusercontent.com/Soupborsh/Lindroid-files/refs/heads/main/patches/general/EventHub.patch
wget https://github.com/android-kxxt/android_kernel_xiaomi_sm8450/commit/ae700d3d04a2cd8b34e1dae434b0fdc9cde535c7.patch
wget https://raw.githubusercontent.com/Soupborsh/Lindroid-files/refs/heads/main/patches/general/0001-Ignore-uevent-s-with-null-name-for-Extcon-WiredAcces.patch
wget https://github.com/Linux-on-droid/vendor_lindroid/commit/10f98759162a0034a2afa62c5977f9bcf921db13.patch

## Apply patches
patch kernel/$1/$2/arch/arm64/configs/$2_defconfig lindroid_defconfig.patch
patch frameworks/native/services/inputflinger/reader/EventHub.cpp EventHub.patch
patch kernel/$1/$2/fs/overlayfs/util.c ae700d3d04a2cd8b34e1dae434b0fdc9cde535c7.patch
git apply 0001-Ignore-uevent-s-with-null-name-for-Extcon-WiredAcces.patch --directory=frameworks/base/
patch -R app/app/src/main/java/org/lindroid/ui/DisplayActivity.java 10f98759162a0034a2afa62c5977f9bcf921db13.patch

## Remove patch files
rm lindroid_defconfig.patch
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
sed -i '/# CONFIG_SYSVIPC is not set/d' kernel/configs/r/android-4.14/android-base.config

# Build
croot
brunch $2

rm ./build.sh
