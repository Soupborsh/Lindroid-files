# Lindroid-files

Build script for LineageOS with Lindroid, tested only on POCO X3 NFC (xiaomi-surya). Also contains files needed for script.

## Status

Builds, but Lindroid works with many bugs.

## Building for surya(using crave.io)

#### In devspace:

In crave devspaces clone LineageOS 21 sources just once:

    crave clone create --projectID 72 /crave-devspaces/Lineage21

each build execute:

(change "xiaomi", "surya" and "arm64" your vendor, codename and architecure)

    cd Lineage21/
    crave run --no-patch -- 'wget https://raw.githubusercontent.com/Soupborsh/Lindroid-files/refs/heads/main/build.sh && chmod +x ./build.sh && ./build.sh xiaomi surya arm64'

It should start building, you can leave from that devspace.

## Getting build output

#### In devspace:

You should be in your project folder, if not:

	cd Lineage21/

Get sha256sum of ROM zip and the name.

	crave ssh sha256sum out/target/product/surya/lineage-*.zip

Example output:

	d44b159a6588f309fc8193dd2759dce688a2039232051eaa08df0df0ff64be17  out/target/product/surya/lineage-21.0-20241021-UNOFFICIAL-surya.zip
(Copy that name of your ROM zip and change it in commands, I provide mine as example)

Then pull it from build server to devspace:

    crave pull out/target/product/surya/lineage-21.0-20241021-UNOFFICIAL-surya.zip


#### On local linux machine(your pc):

copy string after Host in .ssh/config that is about crave.
For example it is `crave-devspace-foss_crave_io-my_email`
Run this to pull that file to local pc(change `crave-devspace-foss_crave_io-my_email` to yours):

    scp crave-devspace-foss_crave_io-my_email:/crave-devspaces/Lineage21/out/target/product/surya/lineage-21.0-20241021-UNOFFICIAL-surya.zip .

Check sha256sum of ROM zip:

	sha256sum lineage-21.0-20241021-UNOFFICIAL-surya.zip

If it is same, just [install it like regular LineageOS](https://wiki.lineageos.org/devices/surya/install/)

## Thanks

Thanks to Lindroid and LineageOS developers!
