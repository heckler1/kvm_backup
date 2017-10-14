#!/bin/bash

# Backup large virtual hard disks from running VMs stored on an LV

# This script quiesces the guest filesystems, takes an LVM Snapshot, and backs up the contents of that snapshot to the target directory with cp.
# By design it overwrites files on the target volume.
# It is designed to be used with large virtual disk images that are nearly impossible to incrementally backup, 
# and are impractical to keep multiple copies of.
# Written by Stephen Heckler - 10/14/2017

# Settings used by the below, customize this
TARGET_DIR=
VG_PATH=
LV_NAME=
# Be sure to leave adequate room for disk writes during the backup
SNAPSHOT_SIZE=10G
SNAPSHOT_NAME=kvmbackup-`date +%s`
MOUNT_DIR=/mnt/$SNAPSHOT_NAME

# Ensure there is nothing mounted to the mount directory
umount $MOUNT_DIR > /dev/null 2>&1

# Ensure there is no LV with the same name
lvremove -f $VG_PATH/$SNAPSHOT_NAME > /dev/null 2>&1

# Keep the most recent backup before the current run
# If the target directory exists
if [ -d "$TARGET_DIR" ] 
then
    # And if there are files in the directory
    TARGET_FILES=$TARGET_DIR/*
    if [ ${#TARGET_FILES[@]} -gt 0 ]
    then
        # If there is already a previous backup, delete it
        if [ -d "$TARGET_DIR.prev" ]
        then
            rm -rf $TARGET_DIR.prev
        fi
        mv $TARGET_DIR $TARGET_DIR.prev
        mkdir $TARGET_DIR
    fi
fi

# Freeze and quiesce the guest filesystems
for name in $(
    # Get the names of all running VMs
    for vm in $(sudo virsh list | tail -n +3)
    do
        echo $vm
    done | sed '/running/d' | awk 'NR%2==0' )
do
    # Quiesce the file system of each VM
    sudo virsh domfsfreeze $name
done

# Take the snapshot
lvcreate --size $SNAPSHOT_SIZE --snapshot --name $SNAPSHOT_NAME $VG_PATH/$LV_NAME || exit 1

# Thaw the guest filesystems
for name in $(
    # Get the names of all running VMs
    for vm in $(sudo virsh list | tail -n +3)
    do
        echo $vm
    done | sed '/running/d' | awk 'NR%2==0' )
do
    # Quiesce the file system of each VM
    sudo virsh domfsthaw $name
done

# Make the mount directory
mkdir $MOUNT_DIR || exit 1

# Mount the snapshot
# Add the 'nouuid' option if backing up an XFS formatted volume
mount -o ro $VG_PATH/$SNAPSHOT_NAME $MOUNT_DIR || exit 1 

# Copy the contents of the snapshotted volume to the target
cp -r --force $MOUNT_DIR/* $TARGET_DIR

# Unmount and remove the LV snapshot
umount $MOUNT_DIR
lvremove -f $VG_PATH/$SNAPSHOT_NAME

# Remove the mount directory
rmdir $MOUNT_DIR