This bash script backs up virtual disk images from running VMs stored on an LVM Volume.

It is designed to be used with large disk images that are impractical to keep multiple copies of.

Even a small change to a virtual disk requires the whole thing to be backed up again in the eyes of most incremental backup software, so incremental backups are impractical as well.
This script only keeps the 2 most recent versions of the disk images, and deletes the old images every time it runs.

The benifit of this script is that it should have very little effect on the uptime of the VM it is run on, generally less than 10 seconds

It requires the QEMU Guest Agent to be installed on the VMs that are being backed up

The backup process:
1. Check to make sure the mount point and snapshot name have not already been used
2. Check for a previous backup, move it out of the way if needed. Delete any older backups.
3. Freeze and quiesce the guest filesystems
4. Create an LVM snapshot of the volume the disk images are on
5. Thaw the guest filesystems
6. Create the mount directory if necessary and mount the snapshot
7. Copy the contents of the snapshot to the specificied folder. This overwrites existing files on purpose.
8. Unmount the snapshot and remove it