# Lindroid-files

Build script for LineageOS with Lindroid for POCO X3 NFC (xiaomi-surya). Also contains files needed for script.

## Status

Builds, but Lindroid may not work.

## Building for surya

#### In devspace:

In crave devspaces clone LineageOS 21 sources just once:

    crave clone create --projectID 72 /crave-devspaces/Lineage21

each build execute:

    cd Lineage21/
    crave run --no-patch -- 'curl https://raw.githubusercontent.com/Soupborsh/Lindroid-files/refs/heads/main/build.sh | bash'
It should start building, you can leave from that devspace.

## Getting build output

#### In devspace:

You should be in your project folder, if not:

	cd Lineage21/

Get sha256sum of ROM zip.(optional, helps avoid corrupted files)

	crave ssh sha256sum out/target/product/surya/lineage-*.zip
Then pull it from build server to devspace:

    crave pull out/target/product/surya/lineage-*.zip


#### On local linux machine(your pc):

copy string after Host in .ssh/config that is about crave.
For example it is `crave-devspace-foss_crave_io-my_email`
Run this to pull that file to local pc(change `crave-devspace-foss_crave_io-my_email` to yours):

    scp crave-devspace-foss_crave_io-my_email:/crave-devspaces/Lineage21/out/target/product/surya/lineage-*.zip .

Check sha256sum of ROM zip:

	sha256sum lineage-*.zip

If it is same, just flash it like regular LineageOS

## Thanks

Thanks to Lindroid and LineageOS developers!
