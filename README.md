# KVM Backup
This bash script backs up virtual disk images from running VMs stored on an LVM Volume.

It is designed to be used with large disk images that are impractical to keep many full copies of. Even a small change to a virtual disk requires the whole thing to be backed up again with most incremental backup software, so incremental backups are impractical as well.
This script only keeps the 2 most recent versions of the disk images, and overwrites the oldest images every time it runs.

The main goal of this script is to have very little effect on the uptime of the VM it is run on. The uptime hiccup is less than 2 seconds on moderate-spec hardware.

Filesystem quiescing requires the QEMU Guest Agent to be installed on the VMs that are being backed up.

#### Backup Process
1. Check to make sure the mount directory and snapshot name have not already been used
2. Check for a previous backup, move it out of the way if needed. Only keeps two backups - one current one and one previous one.
3. Freeze and quiesce the guest filesystems
4. Create an LVM snapshot of the volume the disk images are on
5. Thaw the guest filesystems
6. Create the mount directory and mount the snapshot
7. Copy the contents of the snapshot to the specificied folder.
8. Unmount the snapshot and remove it
