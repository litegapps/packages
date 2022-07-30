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
MAKE(){
	print
	printmid "Building package"
	print
	cd $BASED/files/$ARCH/$SDK
for LIST_PROP in $(find * -name build.info -type f); do
	BASEMOD=$BASED/files/$ARCH/$SDK/$(dirname $LIST_PROP)
	NAME=`getp name $BASEMOD/$(basename $LIST_PROP)`
	ID=`getp id $BASEMOD/$(basename $LIST_PROP)`
	VERSION=`getp version $BASEMOD/$(basename $LIST_PROP)`
	CODE=`getp code $BASEMOD/$(basename $LIST_PROP)`
	NUM=$(((NUM+1)))
	print
	print "${NUM}. Building $NAME"
	print
	
	if [ -f $BASEMOD/null ]; then
		print "- <$BASEMOD/null> detected"
		print "- Skipping"
		continue
	fi
	#cheking oat
	for S in $(find $BASEMOD -name oat -type d); do
		if [ -d $BASEMOD/$S ]; then
			print "- Removing oat <$BASEMOD/$S>"
			rm -rf $BASEMOD/$S
		fi
	done
	
	if [ -d $TMP ]; then
		rm -rf $TMP
		mkdir -p $TMP
	else
		mkdir -p $TMP
	fi
	if [ -d $BASEMOD/cross ] && [ "$(ls -A $BASEMOD/cross)" ]; then
	print "- Found <$BASEMOD/cross>"
		if [ $SDK -le 28 ]; then
			[ ! -d $TMP/system ] && mkdir -p $TMP/system
			cp -af $BASEMOD/cross/* $TMP/system/
		else
			[ ! -d $TMP/system/product ] && mkdir -p $TMP/system/product
			cp -af $BASEMOD/cross/* $TMP/system/product/
		fi
	
	fi
	if [ -d $BASEMOD/files/system ] && [ "$(ls -A $BASEMOD/files/system)" ]; then
		print "- Moving <$BASEMOD/files/$ARCH/$SDK>"
		[ ! -d $BASEMOD/files/system ] && print "! <$BASEMOD/files> not found" && exit 1
		cp -af $BASEMOD/files/* $TMP/
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
			cp -pf $BASED/utils/flashable/setupwizard/$R $TMP/
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
			cp -pf $BASED/utils/flashable/googlekeyboard/$R $TMP/
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
			cp -pf $BASED/utils/flashable/googleclock/$R $TMP/
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
			cp -pf $BASED/utils/flashable/all/$R $TMP/
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
			cp -pf $BASED/utils/etc/$E $TMP/
		fi
	done
	
	if [ -f $BASEMOD/list-rm ]; then
		cp -pf $BASEMOD/list-rm $TMP/
	else
		print "! <$BASEMOD/list-rm> Not found"
		exit 1
	fi

	if [ -d $BASED/utils/installer/kopi ]; then
		cp -af $BASED/utils/installer/kopi/* $TMP/
	fi

	if [ -f $TMP/litegapps-prop ]; then
		print "- Set litegapps-prop"
		sed -i 's/'"$(getp package.name $TMP/litegapps-prop)"'/'"$NAME"'/g' $TMP/litegapps-prop
		sed -i 's/'"$(getp package.module $TMP/litegapps-prop)"'/'"$ID"'/g' $TMP/litegapps-prop
		sed -i 's/'"$(getp package.version $TMP/litegapps-prop)"'/'"$VERSION"'/g' $TMP/litegapps-prop
		sed -i 's/'"$(getp package.code $TMP/litegapps-prop)"'/'"$CODE"'/g' $TMP/litegapps-prop
		sed -i 's/'"$(getp package.size $TMP/litegapps-prop)"'/'"$(du -sh $TMP | cut -f1 )"'/g' $TMP/litegapps-prop
		sed -i 's/'"$(getp package.date $TMP/litegapps-prop)"'/'"$(date +%d-%m-%Y)"'/g' $TMP/litegapps-prop
	fi
	if [ -f $TMP/module.prop ]; then
		print "- Set module.prop"
		sed -i 's/'"$(getp name $TMP/module.prop)"'/'"LiteGapps Package ${NAME}"'/g' $TMP/module.prop
		sed -i 's/'"$(getp id $TMP/module.prop)"'/'"LiteGappsPackage${ID}"'/g' $TMP/module.prop
		sed -i 's/'"$(getp version $TMP/module.prop)"'/'"v${VERSION}"'/g' $TMP/module.prop
		sed -i 's/'"$(getp versionCode $TMP/module.prop)"'/'"$CODE"'/g' $TMP/module.prop
		sed -i 's/'"$(getp author $TMP/module.prop)"'/'"The LiteGapps Project"'/g' $TMP/module.prop
		sed -i 's/'"$(getp date $TMP/module.prop)"'/'"$(date +%d-%m-%Y)"'/g' $TMP/module.prop
		sed -i 's/'"$(getp android.arch $TMP/module.prop)"'/'"$ARCH"'/g' $TMP/module.prop
		sed -i 's/'"$(getp android.sdk $TMP/module.prop)"'/'"$SDK"'/g' $TMP/module.prop
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
		cd $TMP
		
		NAME_ZIP=$OUT/$ARCH/$SDK/$(dirname $(dirname $LIST_PROP))/${ID}.zip
		test ! -d $(dirname $NAME_ZIP) && mkdir -p $(dirname $NAME_ZIP)
		test -f $NAME_ZIP && rm -rf $NAME_ZIP
		$ZIP -r9 $NAME_ZIP * >/dev/null
		rm -rf $TMP
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
	rm -rf $TMP
	done

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

