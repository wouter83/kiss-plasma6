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

# Set up some environment variables.
export HISTSIZE=1000
export HISTIGNORE="&:[bf]g:exit"

# Set up a red prompt for root and a green one for users.
NORMAL="\[\e[0m\]"
RED="\[\e[1;31m\]"
GREEN="\[\e[1;32m\]"
if [[ $EUID == 0 ]] ; then
  PS1="$RED\u [ $NORMAL\w$RED ]# $NORMAL"
else
  PS1="$GREEN\u [ $NORMAL\w$GREEN ]\$ $NORMAL"
fi

unset script RED GREEN NORMAL
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
kiss b libelf ncurses perl baseinit grub e2fsprogs dhcpcd efibootmgr dosfstools util-linux openssh sudo
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
ln -s /etc/sv/dhcpcd/ /var/service/
echo HOSTNAME > /etc/hostname
```

Update the /etc/hosts file
127.0.0.1  HOSTNAME.localdomain  HOSTNAME
::1        HOSTNAME.localdomain  HOSTNAME  ip6-localhost

```
ln -s /etc/sv/sshd /var/service/
```
```
addgroup wouter wheel
```

Use `visudo` as root to uncomment the wheel group settings


## Grub
```
grub-install --target=x86_64-efi \
    --efi-directory=/boot \
    --bootloader-id=kiss

grub-mkconfig -o /boot/grub/grub.cfg
```



## sway
```
kiss b sway
kiss b ttf-croscore
sudo addgroup wouter input
sudo addgroup wouter video
sudo addgroup wouter tty

ln -s /etc/sv/seatd /var/service

cat >> ~/.profile << EOF
export XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-/tmp/$(id -u)-runtime-dir}
[ -d "$XDG_RUNTIME_DIR" ] || {
        mkdir -p   "$XDG_RUNTIME_DIR"
        chmod 0700 "$XDG_RUNTIME_DIR"
}
EOF
```
