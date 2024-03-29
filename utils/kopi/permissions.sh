# Copyright (C) 2020-2024 The LiteGapps Project
# by wahyu6070
# permissions.sh (run by update-binary)
#

case $TYPEINSTALL in
magisk | ksu)
chcon -hR u:object_r:system_file:s0 $MAGISKUP/system
find $MAGISKUP/system -type f | while read anjay; do
	dir6070=$(dirname $anjay)
	chcon -h u:object_r:system_file:s0 $anjay
	chmod 644 $anjay
	chcon -h u:object_r:system_file:s0 $dir6070
	chmod 755 $dir6070
done
;;
esac
