#!/usr/bin/sh
print(){
	echo "$1"
	}
getp(){ grep "^$1" "$2" | head -n1 | cut -d = -f 2; }
printmid() {
  local CHAR=$(printf "$@" | sed 's|\\e[[0-9;]*m||g' | wc -m)
  local hfCOLUMN=$((COLUMNS/2))
  local hfCHAR=$((CHAR/2))
  local indent=$((hfCOLUMN-hfCHAR))
  echo "$(printf '%*s' "${indent}" '') $@"
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
	 esac
	}
MAKE(){
	print
	printmid "Building package"
	print
	cd $BASED/files/$ARCH/$SDK
for LIST_PROP in $(find * -name build.info -type f); do
	BASEMOD=$BASED/files/$ARCH/$SDK/$(dirname $LIST_PROP)
	NAME=`getp name $BASEMOD/$(basename $LIST_PROP)`
	ID=`getp id $BASEMOD/$(basename $LIST_PROP)`
	VERSION=`date '+%Y%m%d'`
	CODE=`date '+%Y%m%d'`
	NUM=$(((NUM+1)))
	print
	print "${NUM}. Building $NAME"
	print
	
	if [ -f $BASEMOD/null ]; then
		print "- <$BASEMOD/null> detected"
		print "- Skipping"
		continue
	fi
	for LIST_INSTALL in AUTO; do
		TMPM=$TMP/$LIST_INSTALL
		#cheking oat
		for S in $(find $BASEMOD -name oat -type d); do
			if [ -d $BASEMOD/$S ]; then
				print "- Removing oat <$BASEMOD/$S>"
				rm -rf $BASEMOD/$S
			fi
		done
	
		if [ -d $TMPM ]; then
			rm -rf $TMPM
			mkdir -p $TMPM
		else
			mkdir -p $TMPM
		fi
		if [ -d $BASEMOD/cross ] && [ "$(ls -A $BASEMOD/cross)" ]; then
		print "- Found <$BASEMOD/cross>"
			if [ $SDK -le 28 ]; then
				[ ! -d $TMPM/system ] && mkdir -p $TMPM/system
				cp -af $BASEMOD/cross/* $TMPM/system/
			else
				[ ! -d $TMPM/system/product ] && mkdir -p $TMPM/system/product
				cp -af $BASEMOD/cross/* $TMPM/system/product/
			fi
	
		fi
		if [ -d $BASEMOD/files/system ] && [ "$(ls -A $BASEMOD/files/system)" ]; then
			print "- Moving <$BASEMOD/files/$ARCH/$SDK>"
			[ ! -d $BASEMOD/files/system ] && print "! <$BASEMOD/files> not found" && exit 1
			cp -af $BASEMOD/files/* $TMPM/
		else
			print "! <$BASEMOD/files/system> Not found"
		fi
	
		#skipping
		if [ ! -d $BASEMOD/cross ] && [ ! $BASEMOD/files/$ARCH/$SDK ]; then
			print "! Skipping <$NAME>"
			continue
		fi
	
	
		if [ $ID = SetupWizard ]; then
			print "• Move Setup Wizard Script"
			LIST_MV="
			customize.sh                                           
			module-install.sh
			module-uninstall.sh                                     
			package-install.sh
			package-uninstall.sh                                    
			permissions.sh                                          
			uninstall.sh
			"
			for R in $LIST_MV; do
				cp -pf $BASED/utils/flashable/setupwizard/$R $TMPM/
			done
		elif [ $ID = GoogleKeyboard ]; then
			print "• Move Google Keyboard Script"
			LIST_MV="
			customize.sh                                           
			module-install.sh
			module-uninstall.sh                                     
			package-install.sh
			package-uninstall.sh                                    
			permissions.sh                                          
			uninstall.sh
			"
			for R in $LIST_MV; do
				cp -pf $BASED/utils/flashable/googlekeyboard/$R $TMPM/
			done
		elif [ $ID = DeskClockGoogle ]; then
			print "• Move Google Clock Script"
			LIST_MV="
			customize.sh                                           
			module-install.sh
			module-uninstall.sh                                     
			package-install.sh
			package-uninstall.sh                                    
			permissions.sh                                          
			uninstall.sh
			"
			for R in $LIST_MV; do
				cp -pf $BASED/utils/flashable/googleclock/$R $TMPM/
			done
		else
			print "• Move Flashable Script"
			LIST_MV="
			customize.sh                                           
			module-install.sh
			module-uninstall.sh                                     
			package-install.sh
			package-uninstall.sh                                    
			permissions.sh                                          
			uninstall.sh
			"
			for R in $LIST_MV; do
				cp -pf $BASED/utils/flashable/all/$R $TMPM/
			done
		fi
	
		LIST_MV="
		LICENSE
		README.md
		litegapps-prop
		module.prop
		"
		for E in $LIST_MV; do
			if [ -f $BASED/utils/etc/$E ]; then
				cp -pf $BASED/utils/etc/$E $TMPM/
			fi
		done
	
		if [ -f $BASEMOD/list-rm ]; then
			cp -pf $BASEMOD/list-rm $TMPM/
		else
			print "! <$BASEMOD/list-rm> Not found"
			exit 1
		fi

		if [ -d $BASED/utils/installer/kopi ]; then
			cp -af $BASED/utils/installer/kopi/* $TMPM/
		fi

		if [ -f $TMPM/litegapps-prop ]; then
			print "- Set litegapps-prop"
			sed -i 's/'"$(getp package.name $TMPM/litegapps-prop)"'/'"$NAME"'/g' $TMPM/litegapps-prop
			sed -i 's/'"$(getp package.module $TMPM/litegapps-prop)"'/'"$ID"'/g' $TMPM/litegapps-prop
			sed -i 's/'"$(getp package.version $TMPM/litegapps-prop)"'/'"$VERSION"'/g' $TMPM/litegapps-prop
			sed -i 's/'"$(getp package.code $TMPM/litegapps-prop)"'/'"$CODE"'/g' $TMPM/litegapps-prop
			sed -i 's/'"$(getp package.size $TMPM/litegapps-prop)"'/'"$(du -sh $TMPM | cut -f1 )"'/g' $TMPM/litegapps-prop
			sed -i 's/'"$(getp package.date $TMPM/litegapps-prop)"'/'"$(date +%d-%m-%Y)"'/g' $TMPM/litegapps-prop
		fi
		if [ -f $TMPM/module.prop ]; then
			print "- Set module.prop"
			sed -i 's/'"$(getp name $TMPM/module.prop)"'/'"LiteGapps Package ${NAME}"'/g' $TMPM/module.prop
			sed -i 's/'"$(getp id $TMPM/module.prop)"'/'"LiteGappsPackage${ID}"'/g' $TMPM/module.prop
			sed -i 's/'"$(getp version $TMPM/module.prop)"'/'"v${VERSION}"'/g' $TMPM/module.prop
			sed -i 's/'"$(getp versionCode $TMPM/module.prop)"'/'"$CODE"'/g' $TMPM/module.prop
			sed -i 's/'"$(getp author $TMPM/module.prop)"'/'"The LiteGapps Project"'/g' $TMPM/module.prop
			sed -i 's/'"$(getp date $TMPM/module.prop)"'/'"$(date +%d-%m-%Y)"'/g' $TMPM/module.prop
			sed -i 's/'"$(getp android.arch $TMPM/module.prop)"'/'"$ARCH"'/g' $TMPM/module.prop
			sed -i 's/'"$(getp android.sdk $TMPM/module.prop)"'/'"$SDK"'/g' $TMPM/module.prop
		fi
		#cheking executebale zip
		if [ "$(command -v zip)" ]; then
			ZIP=`command -v zip`
		elif [ -f $BASED/bin/zip ]; then
			ZIP=$BASED/bin/zip
		else
			print "! Executebale ZIP not detected"
			exit 1
		fi
		if [ -f $ZIP ]; then
			print "- Make Zip"
			print "- Exec Using <$ZIP>"
			cd $TMPM
			DIRNAME_PROP=$(dirname $(dirname $LIST_PROP))
			NAME_ZIP=$OUT/$ARCH/$SDK/$DIRNAME_PROP/${ID}/${LIST_INSTALL}_${ID}_LiteGapps_Addon_${ARCH}_$(get_android_version $SDK).zip
			test ! -d $(dirname $NAME_ZIP) && mkdir -p $(dirname $NAME_ZIP)
			test -f $NAME_ZIP && rm -rf $NAME_ZIP
			$ZIP -r9 $NAME_ZIP * >/dev/null
			rm -rf $TMPM
		fi
		if [ $(getp zipsigner $BASED/config) = true ]; then
			#cheking java for zip signer
			if [ "$(command -v java)" ]; then
				print "- Zip signer"
				print "- Java using <$(command -v java)>"
				print "- Input <$NAME_ZIP>"
				cd $BASED
				java -jar $BASED/bin/zipsigner.jar $NAME_ZIP ${NAME_ZIP}_signed
				if [ $? -eq 0 ]; then
					rm -rf $NAME_ZIP
					mv ${NAME_ZIP}_signed ${NAME_ZIP}
				else
					print "! Failed zip signer <$NAME_ZIP"
					exit 1
				fi
			else
				print "! java not found"
				exit 1
			fi
		fi
		if [ -f $NAME_ZIP ]; then
		print "- Name : $(basename $NAME_ZIP)"
		print "- Size : $(du -sh $NAME_ZIP | cut -f1 )"
		print "- Out  : $NAME_ZIP"
		print "- Done"
		fi
		rm -rf $TMPM
		done
	done
	#RADME.md
	local BY=`getp by $BASED/config`
	local RD=$OUT/$ARCH/$SDK/README.md
	echo "# Description" > $RD
	echo " " >> $RD
	echo "Version = v$(date '+%Y%m%d')" >> $RD
	echo " " >> $RD
	echo "Architecture = $ARCH " >> $RD
	echo " " >> $RD
	echo "Android Version = $(get_android_version $SDK)" >> $RD
	echo " " >> $RD
	echo "API = $SDK" >> $RD
	echo " " >> $RD
	echo "Update by = $BY" >> $RD
	echo " " >> $RD
	echo "Latest Update = $(date '+%d/%m/%Y %H:%M:%S')" >> $RD
	echo " " >> $RD
	echo "Total   = ${NUM} packages" >> $RD
	echo " " >> $RD
	print " "
	print "- Building ${NUM} Packages Done"
	print " "
	}

RESTORE(){
	clear
	print
	printmid "Restoring Files"
	print
	for W in curl unzip; do
		if $(command -v $W >/dev/null); then
			print "Executable <$W> <$(command -v $W)> [OK]"
		else
			print "Executable <$W> [ERROR] not found"
		exit 1
		fi
	done
	print " "
	
	local PROP_ARCH=`getp arch $BASED/config | sed "s/,/ /g"`
	local PROP_SDK=`getp sdk $BASED/config | sed "s/,/ /g"`
	for A in $PROP_ARCH; do
		for B in $PROP_SDK; do
			if [ -f $BASED/zip-server/$A/${B}.zip ]; then
				if [ -d $BASED/files/$A/$B ]; then
					rm -rf $BASED/files/$A/$B
					mkdir -p $BASED/files/$A/$B
				else
					mkdir -p $BASED/files/$A/$B
				fi
				print "- <$BASED/zip-server/$A/${B}.zip> is available extracting"
				unzip -o $BASED/zip-server/$A/${B}.zip -d $BASED/files/$A/$B >/dev/null
				
			else
				mkdir -p $BASED/zip-server/$A
				URL=https://sourceforge.net/projects/litegapps/files/files-server/package/$A/${B}.zip
				print "- Downloading <${URL}>"
				curl --progress-bar -L -o $BASED/zip-server/$A/${B}.zip $URL
				if [ -f $BASED/zip-server/$A/${B}.zip ]; then
					print "- Extract ZIP to $BASED/files/$A/$B"
					mkdir -p $BASED/files/$A/$B
					unzip -o $BASED/zip-server/$A/${B}.zip -d $BASED/files/$A/$B >/dev/null
					if [ $? -eq 0 ]; then
						print "- Unzip $BASED/zip-server/$A/${B}.zip succesfully"
					else
						print "! Unzip $BASED/zip-server/$A/${B}.zip error"
						print "+ Removing zip"
						rm -rf $BASED/zip-server/$A/${B}.zip
					fi
				else
					print "! file <$BASED/zip-server/$A/${B}.zip> is not found"
					exit 1
				fi
			fi
		done
	done
	}
CHECK(){
	clear
	print
	printmid "Cheking package"
	print
	cd $BASED/files/$ARCH/$SDK
	for LIST_PROP in $(find * -name build.info -type f); do
	BASEMOD=$BASED/files/$ARCH/$SDK/$(dirname $LIST_PROP)
	NAME=`getp name $BASEMOD/$(basename $LIST_PROP)`
	ID=`getp id $BASEMOD/$(basename $LIST_PROP)`
	VERSION=`getp version $BASEMOD/$(basename $LIST_PROP)`
	CODE=`getp code $BASEMOD/$(basename $LIST_PROP)`
	if [ -d $BASEMOD/cross ]; then
		NUM=$((($NUM+1)))
		print 
		print "${NUM}. $NAME"
		print "# <$BASEMOD/cross> cross system"
	elif [ ! -d $BASEMOD/files/system ]; then
		NUM=$((($NUM+1)))
		print 
		print "${NUM}. $NAME"
		print "! <$BASEMOD/files/system> not found"
	fi
	done
	cd $BASED/files/$ARCH/$SDK
	for LIST_PROP in $(find * -name build.info -type f); do
	BASEMOD=$BASED/files/$ARCH/$SDK/$(dirname $LIST_PROP)
	NAME=`getp name $BASEMOD/$(basename $LIST_PROP)`
	ID=`getp id $BASEMOD/$(basename $LIST_PROP)`
	VERSION=`getp version $BASEMOD/$(basename $LIST_PROP)`
	CODE=`getp code $BASEMOD/$(basename $LIST_PROP)`
		NUM=0
		for FIND_OAT in $(find $BASEMOD -name oat -type d); do
				NUM=$((($NUM+1)))
				print 
				print "${NUM}. $NAME"
				print "! <$FIND_OAT> found"
				exit 0
		done
	done
	exit 0
	}
CLEAN(){
	clear
	print
	printmid "Cleaning Dir/Files"
	print
	echo -n "Are you sure you want to delete all files? no/yes : "
	read lool
	case $lool in
	y | yes | Y | Yes)
	echo
	;;
	*)
	exit 0
	;;
	esac

	LIST_DIR="
	$BASED/output
	$BASED/files
	$BASED/zip-server
	"
	for W in $LIST_DIR; do
		print "- Removing $W"
		rm -rf $W
		mkdir -p $W
		touch $W/place_holder
	done

	if [ -d $TMP ]; then
		rm -rf $TMP
	fi
	print " "
	cd $BASED
	du -sh *
	print " "
	print "- Done "
	exit 0
	}
	
UPLOAD(){
	clear
	print
	printmid "Cheking package"
	print
	for W in sftp scp; do
		if $(command -v $W >/dev/null); then
			print "Executable <$W> <$(command -v $W)> [OK]"
		else
			print "Executable <$W> [ERROR] not found"
			exit 1
		fi
	done
	print " "
	print " Total Size file upload : $(du -sh $OUT)"
	print " Server : Sourceforge"
	echo -n " Username : "
	read USERNAME
	local SERVER=/home/frs/project/litegapps/addon
	cd $OUT
	for Y in $(find * -type f); do
		local FUPLOAD=$Y
		local SUPLOAD=$SERVER/$Y
		NUM=$(((NUM+1)))
		print "${NUM}."
		print " File : $Y"
		print " To   : $SUPLOAD"
		scp $FUPLOAD $USERNAME@web.sourceforge.net:$SUPLOAD
	done
	}
zip_make(){
	clear
	print
	printmid "Make ZIP"
	print
	local PROP_ARCH=`getp arch $BASED/config | sed "s/,/ /g"`
	local PROP_SDK=`getp sdk $BASED/config | sed "s/,/ /g"`
	for X in $PROP_ARCH; do
		for Y in $PROP_SDK; do
			if [ -d $BASED/files/$X/$Y/core ]; then
				print "- Make ZIP $BASED/files/$X/$Y"
				cd $BASED/files/$X/$Y
				mkdir -p $BASED/zip-server/$X
				local NAME_ZIP=$BASED/zip-server/$X/${Y}.zip
				zip -r9 $NAME_ZIP * >/dev/null
				print "- Name : $(basename $NAME_ZIP)"
				print "- Size : $(du -sh $NAME_ZIP | cut -f1 )"
				print "- Out  : $NAME_ZIP"
				print "- Done"
			fi
		done
	done
	
	}
zip_upload(){
	clear
	print
	printmid "Upload ZIP to sourceforge"
	print
	for W in sftp scp; do
		if $(command -v $W >/dev/null); then
			print "Executable <$W> <$(command -v $W)> [OK]"
		else
			print "Executable <$W> [ERROR] not found"
			exit 1
		fi
	done

	print " "
	print " Total Size file upload : $(du -sh $BASED/zip-server)"
	print " Server : Sourceforge"
	echo -n " Username : "
	read USERNAME
	local SERVER=/home/frs/project/litegapps/files-server/package
	cd $BASED/zip-server
	for Y in $(find * -name *zip -type f); do
		local FUPLOAD=$Y
		local SUPLOAD=$SERVER/$Y
		NUM=$(((NUM+1)))
		print "${NUM}."
		print " File : $Y"
		print " To   : $SUPLOAD"
		scp $FUPLOAD $USERNAME@web.sourceforge.net:$SUPLOAD
	done
	}
######
BASED="`dirname $(readlink -f "$0")`"
OUT=$BASED/output
TMP=$BASED/tmp
ARCH=`getp arch $BASED/config`
SDK=`getp sdk $BASED/config`
chmod -R 755 $BASED/bin

case $1 in
restore | r )
RESTORE
;;
c | clear | clean)
CLEAN
;;
u | upload )
UPLOAD
;;
c | check)
CHECK
;;
make | m )
MAKE
;;
zip-upload)
zip_upload
;;
zip-make)
zip_make
;;
*)
print
print " usage : bash make <options>"
print " "
print " List options"
print " restore         restoring files"
print " make            building package"
print " clean           clean files"
print " check           check confict"
print " upload          upload packages"
print " zip-make        make zip files"
print " zip-upload      upload zip files"
print " "
;;
esac

