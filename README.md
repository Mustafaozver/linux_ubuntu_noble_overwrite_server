# MY-SERVER

---

```bash
sudo apt update
sudo apt install grub-efi-amd64 -y
sudo apt install debootstrap -y
sudo apt install arch-install-scripts -y
sudo apt install pacman-package-manager -y
```

| Bölüm          | Türü | Tür Kodu | Yol        | Boyut             | İlk Sektör | Son Sektör |
| -------------- | ---- | -------- | ---------- | ----------------- | ---------- | ---------- |
| /dev/nvme0n1p1 | UEFI | 1        | /boot/efi/ | 1G                | Boş Bırak  | +1G        |
| /dev/nvme0n1p2 | BOOT | 20       | /boot/     | 4 GB              | Boş Bırak  | +4G        |
| /dev/nvme0n1p3 | SWAP | 19       | -          | 16 GB (RAM Kadar) | Boş Bırak  | +16G       |
| /dev/nvme0n1p4 | ROOT | 23       | /          | Geri Kalan Alan   | Boş Bırak  | Boş Bırak  |

``` bash

lsblk # diskleri öğrenmek için
blkid # bölümleri öğrenmek için

sudo fdisk /dev/nvme0n1

# g: GPT,  n: NEW t: TYPE
# t 1 : UEFI
# t 20 : BOOT, Linux FS
# t 19 : SWAP
# t 23 : ROOT

```

```bash

DISK_UEFI="nvme0n1p1"
DISK_BOOT="nvme0n1p2"
DISK_SWAP="nvme0n1p3"
DISK_ROOT="nvme0n1p4"

DISKID_UEFI=$(blkid -s UUID -o value /dev/$DISK_UEFI)
DISKID_BOOT=$(blkid -s UUID -o value /dev/$DISK_BOOT)
DISKID_SWAP=$(blkid -s UUID -o value /dev/$DISK_SWAP)
DISKID_ROOT=$(blkid -s UUID -o value /dev/$DISK_ROOT)

sudo mkswap /dev/$DISK_SWAP
sudo swapon /dev/$DISK_SWAP

sudo mkfs.vfat /dev/$DISK_UEFI
sudo mkfs.ext4 /dev/$DISK_BOOT
sudo mkfs.btrfs /dev/$DISK_ROOT


```

```bash

## ROOT SUB VOLUME
sudo mount /dev/$DISK_ROOT /mnt
sudo btrfs su cr /mnt/@
sudo btrfs su cr /mnt/@home
sudo btrfs su cr /mnt/@var
sudo btrfs su cr /mnt/@snapshots
sudo umount -R /mnt

## btrfs subvolume snapshot /@ /@snapshots/FIRST_SETUP # backup
## btrfs subvolume snapshot /mnt/@snapshots/FIRST_SETUP /mnt/@ # restore


sudo mount -t btrfs -o noatime,compress=lzo,space_cache=v2,subvol=@ /dev/$DISK_ROOT /mnt

sudo mkdir -p /mnt/home
sudo mkdir -p /mnt/var

sudo mount -t btrfs -o noatime,compress=lzo,space_cache=v2,subvol=@home /dev/$DISK_ROOT /mnt/home
sudo mount -t btrfs -o noatime,compress=lzo,space_cache=v2,subvol=@var /dev/$DISK_ROOT /mnt/var

sudo mkdir -p /mnt/boot
sudo mount /dev/$DISK_BOOT /mnt/boot

sudo mkdir -p /mnt/boot/efi
sudo mount /dev/$DISK_UEFI /mnt/boot/efi

# görmek için
pkexec env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY KDE_SESSION_VERSION=5 KDE_FULL_SESSION=true dolphin

# bölüm UUID elde etmek için
blkid -s UUID -o value /dev/nvme0n1p4

```

```bash

DISTRO="noble"

##ubuntu mnatic veya noble
sudo debootstrap  --variant=minbase  $DISTRO /mnt/

## sudo su

for dir in sys dev proc ; do mount --rbind /$dir /mnt/$dir && mount --make-rslave /mnt/$dir ; done

sudo chroot /mnt apt update
sudo chroot /mnt apt upgrade -y
sudo chroot /mnt apt dist-upgrade -y

sudo chroot /mnt apt install linux-image-generic -y

```

```bash
sudo chroot /mnt apt install samba samba-client samba-common -y

sudo chroot /mnt passwd

sudo chroot /mnt useradd -mG sudo server
sudo chroot /mnt useradd -mG sudo admin
sudo chroot /mnt useradd sandbox
sudo chroot /mnt useradd sshuser

sudo chroot /mnt passwd admin
sudo chroot /mnt passwd server
sudo chroot /mnt passwd sandbox
sudo chroot /mnt passwd sshuser

# samba kullanıcısı

sudo chroot /mnt useradd samba
sudo chroot /mnt smbpasswd -a samba
```

```bash


##################################

sudo mkdir -p /mnt/__tmp/grub_bios_theme/
sudo mkdir -p /mnt/boot/grub/themes/
git clone https://github.com/Mustafaozver/my_linux_grub_theme.git /mnt/__tmp/grub_bios_theme/
sudo cp -R /mnt/__tmp/grub_bios_theme/* /mnt/boot/grub/themes/

sudo mkdir -p /mnt/__tmp/grub-btrfs/
git clone https://github.com/Antynea/grub-btrfs.git /mnt/__tmp/grub-btrfs/

sudo mkdir -p /mnt/__tmp/debs/




```

---

```bash
sudo nano /mnt/etc/apt/sources.list
```

```read
deb http://archive.ubuntu.com/ubuntu/ noble main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu/ noble-updates main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu/ noble-backports main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu/ noble-security main restricted universe multiverse

deb http://archive.ubuntu.com/ubuntu/ noble-proposed main restricted universe multiverse
```

```bash
sudo chroot /mnt apt update
sudo chroot /mnt apt upgrade -y
sudo chroot /mnt apt dist-upgrade -y
```

---

```bash
sudo nano /mnt/etc/resolv.conf
```

```read
nameserver 127.0.0.53
options edns0 trust-ad
search home
```

---

```bash
sudo rm /mnt/etc/localtime
sudo ln -sf /mnt/usr/share/zoneinfo/Europe/Istanbul /mnt/etc/localtime


sudo nano /mnt/etc/locale.gen
```

```read
en_US.UTF-8 UTF-8
tr_TR.UTF-8 UTF-8
```

---

```bash
sudo nano /mnt/etc/locale.conf
```

```read
LANG=tr_TR.UTF-8
```

---

```bash
sudo nano /mnt/etc/vconsole.conf
```

```read
KEYMAP=trq
```

---

```bash
sudo chroot /mnt apt install locales -y
sudo chroot /mnt dpkg-reconfigure tzdata
sudo chroot /mnt dpkg-reconfigure locales
sudo chroot /mnt dpkg-reconfigure console-setup
sudo chroot /mnt locale-gen
```

---

```bash
sudo chroot /mnt apt update
sudo chroot /mnt apt install linux-image-generic -y
#sudo chroot /mnt apt install linux-headers-generic -y
#sudo chroot /mnt apt install linux-tools-generic -y

## Diğer library ler

sudo chroot /mnt dpkg -i /linux-image-zenmod.deb

sudo chroot /mnt apt install sudo dhcpcd5 -y

sudo chroot /mnt apt install linux-image-amd64 -y
sudo chroot /mnt apt install linux-headers-amd64 -y
sudo chroot /mnt apt install console-setup ntp -y
sudo chroot /mnt apt install plymouth-themes -y


sudo chroot /mnt apt install systemd-sysv -y
sudo chroot /mnt apt install net-tools -y
sudo chroot /mnt apt install iproute2 -y
sudo chroot /mnt apt install bash-completion -y
sudo chroot /mnt apt install systemd-networkd -y
sudo chroot /mnt apt install netplan.io -y



sudo chroot /mnt apt install grub-efi-amd64 -y
sudo chroot /mnt apt install btrfs-progs -y
sudo chroot /mnt apt install btrfs-tools -y
sudo chroot /mnt apt install cryptsetup -y
sudo chroot /mnt apt install cryptsetup-initramfs -y
sudo chroot /mnt apt install lvm2 -y
sudo chroot /mnt apt install exfatprogs -y
sudo chroot /mnt apt install exfat-utils -y
sudo chroot /mnt apt install exfat-fuse -y

sudo chroot /mnt apt install build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev wget -y

sudo chroot /mnt apt install git dosfstools amd64-microcode nano -y






sudo chroot /mnt apt install dosfstools amd64-microcode network-manager git cryptsetup lvm2 sudo -y

sudo chroot /mnt apt install lsb-release ca-certificates apt-transport-https software-properties-common -y



sudo chroot /mnt apt install tmux -y




sudo chroot /mnt apt install tzdata curl ca-certificates openssh-server curl -y

sudo chroot /mnt apt install ufw -y


sudo chroot /mnt apt --fix-missing update
sudo chroot /mnt apt --fix-broken install -y
sudo chroot /mnt apt autoremove
sudo chroot /mnt apt clean
sudo chroot /mnt update-initramfs -t -u -k all


```

---

```bash
sudo su # dosyaya yazma sırasında sudo lazım
sudo genfstab -U /mnt >> /mnt/etc/fstab
```

```bash
sudo nano /mnt/etc/fstab

## DISKID_ROOT, DISKID_BOOT, DISKID_HOME, DISKID_UEFI, DISKID_SWAP
## PART_ROOT, PART_HOME

```

```read
tmpfs /tmp tmpfs rw,nosuid,nodev,inode64 0 0
```

```bash
sudo chroot /mnt apt install grub-efi-amd64 -y

```

```bash
sudo nano /mnt/etc/default/grub
```

```read
GRUB_DEFAULT=saved
GRUB_SAVEDEFAULT=true
GRUB_TIMEOUT_STYLE=menu
GRUB_TIMEOUT=10
GRUB_DISTRIBUTOR=`lsb_release -i -s 2> /dev/null || echo Debian`
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"
GRUB_CMDLINE_LINUX=""
```

```bash
sudo chroot /mnt update-grub
sudo chroot /mnt systemctl hibernate
```

```bash
sudo nano /mnt/etc/sudoers
```

```read
server ALL=(ALL:ALL) ALL,!ALL
sshuser ALL=(ALL) NOPASSWD: ALL
```

---

```bash


sudo chroot /mnt apt install python3 -y
sudo chroot /mnt apt install python3-pip -y
sudo chroot /mnt apt install pipx -y
sudo chroot /mnt apt install python3-full -y

sudo chroot /mnt apt install wget gpd nano -y

sudo chroot /mnt apt install openssh-server openssh-client -y
sudo chroot /mnt apt install distrobox -y
sudo chroot /mnt apt install curl apt-transport-https -y

sudo chroot /mnt apt install nodejs npm -y
sudo chroot /mnt apt install postgresql postgresql-contrib -y
sudo chroot /mnt apt install sqlite3 libsqlite3-dev -y

sudo chroot /mnt apt install redis -y

sudo chroot /mnt apt install rabbitmq-server -y
sudo chroot /mnt apt install elasticsearch -y

sudo chroot /mnt apt update
sudo chroot /mnt apt --fix-missing update
sudo chroot /mnt apt --fix-broken install
sudo chroot /mnt apt autoremove
sudo chroot /mnt apt clean

```

---

```bash

sudo mkdir -p /mnt/home/server/app/
sudo chmod 777 /mnt/home/server/app/

sudo mkdir -p  /mnt/home/server/.ssh/

sudo nano /mnt/etc/systemd/system/server.service

```

```read
[Unit]
Description=My NodeJS App
After=network.target

[Service]
User=server
WorkingDirectory=/home/server/app
ExecStart=sh /home/server/app/init.sh
Restart=always
Environment=NODE_ENV=production

[Install]
WantedBy=multi-user.target

```

```javascript
sudo nano /home/server/.tmux.conf
```

```text
set -g default-shell /usr/bin/bash
set -g mouse on
set -g history-limit 1000
```

```bash
sudo nano /mnt/home/server/app/init.sh
```

```bash
# System Start

tmux new-session -d -s tunnel0
tmux new-session -d -s app0

tmux pipe-pane -t tunnel0 -o 'cat >> /home/server/app/tunnel0.log'
tmux pipe-pane -t app0 -o 'cat >> /home/server/app/app0.log'

tmux send-keys -t app0 "node '/home/server/app/app.js'" C-m
tmux send-keys -t tunnel0 "sh '/home/server/app/start_web_tunnel.sh'" C-m

## tmux attach -t tunnel0
## ctrl + b -> d => çıkış


```

```bash
sudo nano /mnt/home/server/app/check.sh
```

```bash
# System Check




```

```bash
sudo nano /mnt/etc/netplan/01-netcfg.yaml
```

```read

network:
  version: 2
  ethernets:
    eno1:
      dhcp4: true


```

```bash

sudo chroot /mnt systemctl restart ssh

sudo chroot /mnt systemctl enable --now server
sudo chroot /mnt systemctl status server

sudo chroot /mnt systemctl enable cron
sudo chroot /mnt systemctl start cron


sudo chroot /mnt netplan apply

sudo chroot /mnt ufw default deny incoming
sudo chroot /mnt ufw default allow outgoing
sudo chroot /mnt ufw allow 22/tcp # ssh
sudo chroot /mnt ufw allow 80/tcp # http
sudo chroot /mnt ufw allow 443/tcp # https

sudo chroot /mnt ufw enable


```

```bash
sudo chroot /mnt node -v
sudo chroot /mnt npm -v


```

---

```bash
sudo chroot /mnt cron -e
sudo nano /mnt/var/spool/cron/crontabs/root
# sudo nano /mnt/etc/crontab

```

```text
# cron ile denetleme mekanizması
30 3 * * * su server sh /home/server/app/check.sh

```

---

```bash


sudo chroot /mnt update-initramfs -t -u -k all
sudo chroot /mnt update-grub

sudo chroot /mnt grub-install


sudo chmod -R g-rwx,o-rwx /mnt/boot

sudo umount -lf -R /mnt/* 2>/dev/null

sudo rm -rf /mnt/__tmp/*

sudo chroot /mnt apt autoremove
sudo rm -f /mnt/root/.bash_history
sudo rm -rf /mnt/var/lib/apt/lists/*
find /mnt/var/log/ -type f | xargs rm -f

sudo swapoff --all

```
