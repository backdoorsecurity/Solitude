#!/bin/bash
cryptsetup luksOpen UUID=6de118f7-17cb-4feb-98ec-29b87238fd33 crypt --key-file /root/.keys/backup-keyfile && \
mount /dev/mapper/crypt /mnt/backup && \
rsync -avh /root/* /mnt/backup/root/ && \
#rsync -avh /var/lib/libvirt/images/* /mnt/backup/libvirt/images/ && \
umount /mnt/backup && cryptsetup luksClose crypt

