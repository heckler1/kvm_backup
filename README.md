This bash script backs up virtual disk images from running VMs stored on an LVM Volume.
It is designed to be used with large disk images that are impractical to keep multiple copies of.
Even a small change to a virtual disk requires the whole thing to be backed up again in the eyes of most incremental backup software, so incremental backups are impractical as well.
This script only keeps the most recent version of the disk images, and overwrites the old images every time it runs.
The benifit of this script is that it should have very little effect on the uptime of the VM it is run on, generally less than 10 seconds
It requires the QEMU Guest Agent to be installed on the VMs that are backed up

The backup process:
1. Check to make sure the mount point and snapshot name have not already been used
2. Freeze and quiesce the guest filesystems
3. Create an LVM snapshot of the volume the disk images are on
4. Thaw the guest filesystems
5. Create the mount directory if necessary and mount the snapshot
6. Copy the contents of the snapshot to the specificied folder. This overwrites existing files on purpose.
7. Unmount the snapshot and remove it