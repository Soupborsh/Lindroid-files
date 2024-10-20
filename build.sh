mkdir -p .repo/local_manifests/
wget https://raw.githubusercontent.com/Soupborsh/Lindroid-files/refs/heads/main/lindroid.xml -O .repo/local_manifests/lindroid.xml
wget https://raw.githubusercontent.com/Soupborsh/Lindroid-files/refs/heads/main/muppets.xml -O .repo/local_manifests/muppets.xml
repo sync -c
source build/envsetup.sh
breakfast surya
wget https://raw.githubusercontent.com/Soupborsh/Lindroid-files/refs/heads/main/lindroid_defconfig.patch
wget https://raw.githubusercontent.com/Soupborsh/Lindroid-files/refs/heads/main/EventHub.patch
wget https://github.com/android-kxxt/android_kernel_xiaomi_sm8450/commit/ae700d3d04a2cd8b34e1dae434b0fdc9cde535c7.patch
wget https://raw.githubusercontent.com/Soupborsh/Lindroid-files/refs/heads/main/0001-Ignore-uevent-s-with-null-name-for-Extcon-WiredAcces.patch
patch kernel/xiaomi/surya/arch/arm64/configs/surya_defconfig lindroid_defconfig.patch
patch frameworks/native/services/inputflinger/reader/EventHub.cpp EventHub.patch
patch kernel/xiaomi/surya/fs/overlayfs/util.c ae700d3d04a2cd8b34e1dae434b0fdc9cde535c7.patch
git apply 0001-Ignore-uevent-s-with-null-name-for-Extcon-WiredAcces.patch --directory=frameworks/base/
rm lindroid_defconfig.patch
rm EventHub.patch
rm ae700d3d04a2cd8b34e1dae434b0fdc9cde535c7.patch
rm 0001-Ignore-uevent-s-with-null-name-for-Extcon-WiredAcces.patch
echo '' >> device/xiaomi/surya/BoardConfig.mk
echo '# Set SELinux to permissive' >> device/xiaomi/surya/BoardConfig.mk
echo 'BOARD_KERNEL_CMDLINE += androidboot.selinux=permissive' >> device/xiaomi/surya/BoardConfig.mk
echo '$(call inherit-product, vendor/lindroid/lindroid.mk)' >> device/xiaomi/surya/lineage_surya.mk
sed -i '/# CONFIG_SYSVIPC is not set/d' kernel/configs/r/android-4.14/android-base.config
croot
brunch surya
