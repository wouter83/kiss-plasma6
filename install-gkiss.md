# Install steps GKISS linux

## Guide followed
- https://k1ss.org/
- https://comfy.guide/client/kisslinux/
- https://youtu.be/kZYcfT0WcCo?si=H4-Cjb-OnjDFGcJ_

## Partition
Gparted:
    GPT partition table
    2 partitions
        1: boot: 512M, EFI system, fat32, boot, esp
        2: root: all else, Linux Filesystem, ext4
    
## mount
```
mount /dev/sda2 /mnt
mkdir /mnt/boot
/mount /dev/sda1 /mnt/boot
```

## Get chroot and repositories
get chroot tarball at: https://codeberg.org/kiss-community/grepo/releases/download/22.11.15/gkiss-chroot-22.11.15.tar.xz

```
tar xvf gkiss-chroot-22.11.15.tar.xz -C /mnt
# Standalone install for all OS':
git clone https://github.com/glacion/genfstab
cd genfstab

./genfstab /mnt > /mnt/etc/fstab

# Enter chroot
/mnt/bin/kiss-chroot /mnt

# clone repos
git clone https://codeberg.org/kiss-community/grepo /var/db/kiss/repo
git clone https://codeberg.org/kiss-community/community /var/db/kiss/community
```
```
cat >> /etc/profile << "EOF"

export KISS_PATH=''
KISS_PATH=/var/db/kiss/repo/core
KISS_PATH=$KISS_PATH:/var/db/kiss/repo/extra
KISS_PATH=$KISS_PATH:/var/db/kiss/repo/wayland

# Community repository
KISS_PATH=$KISS_PATH:/var/db/kiss/community/community

export CFLAGS="-O3 -pipe -march=native"
export CXXFLAGS="$CFLAGS"

# NOTE: '4' should be changed to match the number of threads.
# 	This value can be found by running 'nproc'.
export MAKEFLAGS="-j8"
EOF
```
```
# Update KISS
kiss update
kiss U
# update packages
kiss b gperf

kiss update
kiss U
cd /var/db/kiss/installed && kiss build *
```
### install needed packages
```
kiss b libelf ncurses perl baseinit grub e2fsprogs dhcpcd efibootmgr dosfstools util-linux eudev
```

## Kernel
```
mkdir -p /usr/src
cd /usr/src
curl -fLO https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.9.7.tar.xz
tar xvf linux*
## cd linux-kernel
## make defconfig
## make menuconfig

make -j8
make INSTALL_MOD_STRIP=1 modules_install
make install
mv /boot/vmlinuz /boot/vmlinuz-6.9.7
mv /boot/System.map /boot/System.map-6.9.7
cp .config /boot/config-6.9.7
```
## users
```
passwd
adduser 
```

## aditional
```
echo HOSTNAME > /etc/hostname
```

Update the /etc/hosts file
127.0.0.1  HOSTNAME.localdomain  HOSTNAME
::1        HOSTNAME.localdomain  HOSTNAME  ip6-localhost

## Grub
```
grub-install --target=x86_64-efi \
    --efi-directory=/dev/sda1 \
    --bootloader-id=kiss

grub-mkconfig -o /boot/grub/grub.cfg
```

