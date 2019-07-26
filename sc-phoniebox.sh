#!/bin/bash
# Filename: sc-phoniebox.sh (script)
# Version : 1.2
#
# Comment :     Download + Decrypt mainfile
#		Check non available for next step
#		Download, decrypt files
#		Extract files to destination folder

source config
file="main"
target="/home/pi/RPi-Jukebox-RFID/shared/audiofolders"
target2="/home/pi/RPi-Jukebox-RFID/shared/shortcuts"
outputfile="cmain"

clear

function f_decryptfile {
        echo "Try to decrypt cmain file..."
        openssl enc -d -aes-256-cbc -k $k -in $outputfile -out $file
}

function f_downloadfile {
        echo "Try to download new cryptfile..."
        wget $domainfile -O $outputfile
        wget $domainfile.sha1 -O $outputfile.sha1
}

f_downloadfile
f_decryptfile

OIFS=$IFS
IFS=";"    #notice: this is your field separator

while read var1 var2 var3

do
if [ "$var1" != "CardID" ]; then
	if [ ! -d "$target/$var2" ]; then
		wget $containerfolder$var3 -O /tmp/$var3.tar.gz
		echo "Verzeichnis "$var2" gibt es noch nicht!"

		if [ -f "/tmp/$var3.tar.gz" ]; then
			openssl enc -d -aes-256-cbc -k $m -in /tmp/$var3.tar.gz | tar xz -C $target
			rm /tmp/$var3.tar.gz
			touch $target2/$var1
			echo -n $var2 > $target2/$var1
		fi
	fi
fi

done < $file
IFS=$OIFS

sudo chown -R pi:www-data /home/pi/RPi-Jukebox-RFID/shared/audiofolders/
sudo chmod -R 775 /home/pi/RPi-Jukebox-RFID/shared/audiofolders/
sudo chown www-data:www-data /home/pi/RPi-Jukebox-RFID/shared/shortcuts/*
sudo chmod 777 /home/pi/RPi-Jukebox-RFID/shared/shortcuts/*
