#!/bin/bash
set -e

BASEDIR=$(dirname $0)

FLOPPY_IMAGE=$BASEDIR/Unattend.vfd
CONTENT_SRC="$BASEDIR/Autounattend.xml $BASEDIR/UnattendResources"

# TODO: Parametrize creation of Autounattend.xml
cp UnattendTemplate.xml Autounattend.xml

case `uname` in
Linux)	if [ $EUID -ne 0 ]; then
		echo "This script must be run as root" 1>&2
		exit 1
	fi
	TMP_FLOPPY_IMAGE=`mktemp tmp.XXXXXXXXXX`
	TMP_MOUNT_PATH=`mktemp -d tmp.XXXXXXXXXX`

	dd if=/dev/zero of=$TMP_FLOPPY_IMAGE count=2880
	mkfs.vfat $TMP_FLOPPY_IMAGE

	mkdir $TMP_MOUNT_PATH
	mount -t vfat -o loop $TMP_FLOPPY_IMAGE $TMP_MOUNT_PATH
	cp -r $CONTENT_SRC $TMP_MOUNT_PATH

	umount $TMP_MOUNT_PATH
	rmdir $TMP_MOUNT_PATH
	;;
Darwin)	
	TMP_FLOPPY_IMAGE=`mktemp tmp.XXXXXXXXXX`
	mv $TMP_FLOPPY_IMAGE $TMP_FLOPPY_IMAGE.dmg
	TMP_FLOPPY_IMAGE=$TMP_FLOPPY_IMAGE.dmg
	TMP_MOUNT_PATH=/Volumes/FLOPPY

	dd if=/dev/zero of=$TMP_FLOPPY_IMAGE count=2880
	TMP_DEV=`hdiutil attach -nomount $TMP_FLOPPY_IMAGE`
	newfs_msdos -v FLOPPY -F 12 $TMP_DEV
	hdiutil detach  $TMP_DEV
	hdiutil mount $TMP_FLOPPY_IMAGE
	cp -r $CONTENT_SRC $TMP_MOUNT_PATH
	hdiutil unmount $TMP_MOUNT_PATH
	hdiutil detach  $TMP_DEV
	;;
esac
mv $TMP_FLOPPY_IMAGE $FLOPPY_IMAGE
