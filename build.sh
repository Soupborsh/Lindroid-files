mkdir -p .repo/local_manifests/
wget https://raw.githubusercontent.com/Soupborsh/Lindroid-files/refs/heads/main/lindroid.xml -O .repo/local_manifests/lindroid.xml
wget https://raw.githubusercontent.com/Soupborsh/Lindroid-files/refs/heads/main/muppets.xml -O .repo/local_manifests/muppets.xml
repo sync -c
source build/envsetup.sh
breakfast surya
wget https://raw.githubusercontent.com/Soupborsh/Lindroid-files/refs/heads/main/lindroid_defconfig.patch
wget https://raw.githubusercontent.com/Soupborsh/Lindroid-files/refs/heads/main/EventHub.patch
patch kernel/xiaomi/surya/arch/arm64/configs/surya_defconfig lindroid_defconfig.patch
patch frameworks/native/services/inputflinger/reader/EventHub.cpp EventHub.patch
rm lindroid_defconfig.patch
rm EventHub.patch
echo "" >> BoardConfig.mk
echo "# Set SELinux to permissive" >> BoardConfig.mk
echo "BOARD_KERNEL_CMDLINE += androidboot.selinux=permissive" >> BoardConfig.mk
croot
brunch surya