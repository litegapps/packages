# Copyright (C) 2020-2024 The LiteGapps Open Source Project
#
# write by wahyu6070 (wahyu kurniawan)
#


print(){ ui_print "$1"; }
del (){ rm -rf "$@"; }
cdir (){ mkdir -p "$@"; }
getp(){ grep "^$1" "$2" | head -n1 | cut -d = -f 2; }

GET_PROP(){
	local LIST_PROP="
	$SYSTEM/build.prop
	$VENDOR/build.prop
	$PRODUCT/build.prop
	$SYSTEM_EXT/build.prop
	"
	local HJ VARPROP
	for HJ in $LIST_PROP; do
		if [ -f $HJ ] && grep -q "$1" "$HJ" 2>/dev/null; then
			VARPROP=`grep "^$1" "$HJ" | head -n1 | cut -d = -f 2`
			break
		fi
	done
	
	if [ "$VARPROP" ]; then
		echo "$VARPROP"
	elif [ "$(getprop $1)" ]; then
		getprop $1
	else
		return 1
	fi
	
	}
get_android_codename(){
	local input=$1
	case $input in
		21) echo "Lollipop" ;;
		22) echo "Lollipop" ;;
		23) echo "Marshmallow" ;;
		24) echo "Nougat" ;;
		25) echo "Nougat" ;;
		26) echo "Oreo" ;;
		27) echo "Oreo" ;;
		28) echo "Pie" ;;
		29) echo "Quince Tart" ;;
		30) echo "Red Velvet Cake" ;;
		31) echo "Snow Cone" ;;
		32) echo "Snow Cone" ;;
		33) echo "Tiramisu" ;;
		34) echo "Upside Down Cake" ;;
		*) echo "null" ;;
	 esac
	}
INFO(){
MODULEVERSION=`getp version $MODPATH/module.prop`
MODULECODE=`getp versionCode $MODPATH/module.prop`
MODULENAME=`getp name $MODPATH/module.prop`
MODULEANDROID=`getp android $MODPATH/module.prop`
MODULEDATE=`getp date $MODPATH/module.prop`
MODULEAUTHOR=`getp author $MODPATH/module.prop`

packagename=`getp package.name $MODPATH/litegapps-prop`
packagesize=`getp package.size $MODPATH/litegapps-prop`
packagedate=`getp package.date $MODPATH/litegapps-prop`
packageversion=`getp package.version $MODPATH/litegapps-prop`
packagecode=`getp package.code $MODPATH/litegapps-prop`
packageid=`getp package.id $MODPATH/litegapps-prop`


print "____________________________________"
print "|"
case $1 in
install)
print "| Mode            : Install"
;;
uninstall)
print "| Mode            : Uninstall"
;;
*)
print "| Mode            : Not Detected"
;;
esac
print "| Name            : ${packagename}"
print "| Version         : ${packageversion}"
print "| Build date      : $MODULEDATE"
print "| Size            : ${packagesize}"
case $TYPEINSTALL in
magisk)
print "| Install As      : systemless (Magisk Module)"
;;
ksu)
print "| Install As      : systemless (KSU Module)"
;;
*)
print "| Install As      : non systemless"
;;
esac
print "|___________________________________"
print "|"
print "| Website         : https://litegapps.github.io"
print "|___________________________________"
print "|              Device Info"
print "| Name Rom        : $(GET_PROP ro.build.display.id)"
if [ "$(GET_PROP ro.product.vendor.model)" ]; then
print "| Device          : $(GET_PROP ro.product.vendor.model)"
elif [ "$(GET_PROP ro.product.model)" ]; then
print "| Device          : $(GET_PROP ro.product.model)"
else
print "| Device          : null"
fi

if [ "$(GET_PROP ro.product.vendor.device)" ]; then
print "| Codename        : $(GET_PROP ro.product.vendor.device)"
elif [ "$(GET_PROP ro.product.device)" ]; then
print "| Codename        : $(GET_PROP ro.product.device)"
else
print "| Codename        : null"
fi
print "| Android Version : $(GET_PROP ro.build.version.release) ($(get_android_codename $(GET_PROP ro.build.version.sdk)))"
print "| Architecture    : $ARCH"
print "| Api             : $(GET_PROP ro.build.version.sdk)"
print "| Density         : $(GET_PROP ro.sf.lcd_density)"
if [ $(getprop ro.build.ab_update) = true ]; then
	print "| Seamless        : A/B (slot $(find_slot))"
else
	print "| Seamless        : A only"
fi

print "|___________________________________"
print " "
}

ch_con(){
chcon -h u:object_r:system_file:s0 "$1" || sedlog "Failed chcon $1"
}

ch_con_r(){
chcon -hR u:object_r:system_file:s0 "$1" || sedlog "Failed chcon $1"
}


get_android_version(){
	local input=$1
	case $input in
		21) echo 5.0 ;;
		22) echo 5.1 ;;
		23) echo 6.0 ;;
		24) echo 7.0 ;;
		25) echo 7.1 ;;
		26) echo 8.0 ;;
		27) echo 8.1 ;;
		28) echo 9.0 ;;
		29) echo 10.0 ;;
		30) echo 11.0 ;;
		31) echo 12.0 ;;
		32) echo 12.1 ;;
		33) echo 13.0 ;;
		34) echo 14.0 ;;
		*) echo null ;;
	 esac
	}

app_true(){
	
	pm list packages | grep -q $1
	if [ $? -eq "0" ]; then
	return 0
	else
	return 1
	fi
	
	}

	
INITIAL(){
	local mode=$1
	#path
	if [ -f /system_root/system/build.prop ]; then
		SYSTEM=/system_root/system 
	elif [ -f /system_root/build.prop ]; then
		SYSTEM=/system_root
	elif [ -f /system/system/build.prop ]; then
		SYSTEM=/system/system
	else
		SYSTEM=/system
	fi

	if [ ! -L $SYSTEM/vendor ]; then
		VENDOR=$SYSTEM/vendor
	else
		VENDOR=/vendor
	fi

	# /product dir (android 10+)
	if [ ! -L $SYSTEM/product ]; then
		PRODUCT=$SYSTEM/product
	else
		PRODUCT=/product
	fi

	# /system_ext dir (android 11+)
	if [ ! -L $SYSTEM/system_ext ]; then
		SYSTEM_EXT=$SYSTEM/system_ext
	else
		SYSTEM_EXT=/system_ext
	fi
	
	
	[ "TMPDIR" ] || TMPDIR=/dev/tmp
	LITEGAPPS=/data/media/0/Android/litegapps
	log=$LITEGAPPS/log/litegapps.log
	files=$MODPATH/files

	#detected build.prop
	[ ! -f $SYSTEM/build.prop ] && report_bug "System build.prop not found"


	[ $API ] || API=$(getp ro.build.version.sdk $SYSTEM/build.prop)
	[ $ARCH ] || ARCH=$(getp ro.product.cpu.abi $SYSTEM/build.prop | cut -d '-' -f -1)

	case $ARCH in
	arm64) ARCH=arm64 ;;
	armeabi | arm) ARCH=arm ;;
	x86) ARCH=x86 ;;
	x86_64) ARCH=x86_64 ;;
	*) report_bug " <$ARCH> Your Architecture Not Support" ;;
	esac


	#mode installation
	if [ ! $TYPEINSTALL ] && [ $KSU ]; then
	TYPEINSTALL=ksu
	elif [ ! $TYPEINSTALL ] && [ ! $KSU ]; then
	TYPEINSTALL=magisk
	elif [ $TYPEINSTALL = "ksu" ]; then
	TYPEINSTALL=ksu
	sedlog "- Type install KOPI installer convert to ksu module"a
	elif [ $TYPEINSTALL = "magisk" ]; then
	TYPEINSTALL=magisk
	sedlog "- Type install KOPI installer convert to magisk module"
	elif [ $TYPEINSTALL = "kopi" ]; then
	TYPEINSTALL=kopi
	sedlog "- Type install KOPI installer convert to kopi module"
	else
	TYPEINSTALL=kopi
	sedlog "- Type install is not found, use default to kopi module"
	fi


	# Test /data rw partition
	case $TYPEINSTALL in
	magisk | ksu )
	DIR_TEST=/data/adb/test8989
	cdir $DIR_TEST
	touch $DIR_TEST/io
	[ -f $DIR_TEST/io ] && del $DIR_TEST || report_bug "/data partition is encrypt or read only"
	;;
	esac

	for CCACHE in $LITEGAPPS/log; do
		test -d $CCACHE && del $CCACHE && cdir $CCACHE || cdir $CCACHE
	done

	#functions litegapps info module.prop and build.prop
	INFO $mode
	print " "
		
}


set_prop() {
  local property="$1"
  local value="$2"
  file_location="$3"
  if grep -q "${property}" "${file_location}"; then
    sed -i "s/\(${property}\)=.*/\1=${value}/g" "${file_location}"
  else
    echo "${property}=${value}" >>"${file_location}"
  fi
}

INITIAL uninstall

if [ $TYPEINSTALL != "magisk" ] || [ $TYPEINSTALL != "ksu" ]; then
	if [ -f $KOPIMOD/list-debloat ]; then
		for D in $(cat $KOPIMOD/list-debloat); do
			print " • Restoring $D"
			test ! -d $D && mkdir -p $D
			cp -rdf $KOPIMOD/backup${D}/* $D/
		done
	fi
fi

if [ -f $KOPIMOD/list_install_system ]; then
	for i in $(cat $KOPIMOD/list_install_system); do
		
		if [ -f $SYSTEM/$i ]; then
			del $SYSTEM/$i
			rmdir $(dirname $SYSTEM/$i) 2>/dev/null
		fi
	done
fi


if [ -f $KOPIMOD/list_install_vendor ]; then
	for i in $(cat $KOPIMOD/list_install_vendor); do
		if [ -f $VENDOR/$i ]; then
			del $VENDOR/$i
			rmdir $(dirname $VENDOR/$i) 2>/dev/null
		fi
	done
fi

if [ -f $KOPIMOD/list_install_product ]; then
	for i in $(cat $KOPIMOD/list_install_product); do
		
		if [ -f $PRODUCT/$i ]; then
			del $PRODUCT/$i
			rmdir $(dirname $PRODUCT/$i) 2>/dev/null
		fi
	done
fi

if [ -f $KOPIMOD/list_install_system_ext ]; then
	for i in $(cat $KOPIMOD/list_install_system_ext); do
		if [ -f $SYSTEM_EXT/$i ]; then
			del $SYSTEM_EXT/$i
			rmdir $(dirname $SYSTEM_EXT/$i) 2>/dev/null
			
		fi
	done
fi

# restoring product/build.prop
if [ -f $KOPIMOD/build.prop ]; then
	cp -pf $KOPIMOD/build.prop $SYSTEM_DIR/product/build.prop
fi

print "- Uninstalling successfully"
