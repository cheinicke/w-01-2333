#!/bin/bash
# Filename: sc-main.sh (script), main (csv)
# Version : 1.2
#
# Comment : Check 
#		download+decrypt new file
#		read+verify user input
#		add user input to file
#		Crypt+upload file

source config
id=0
name=""
file="main"
outputfile="cmain"

clear

function f_addtofile {
	echo $id";"$name";"$id >> $file
}

function f_askid {
	while [[ $id -gt 10000000000 || $id -eq 0 ]]; do
		echo "Type the ID from your card: "
	       	read id
	done
}

function f_askfoldername {
	echo "Type the name: "
	read name
}

function f_cryptfile {
	echo "Try to crypt main file for upload..."
	openssl enc -e -aes-256-cbc -k $k -in $file -out $outputfile
	sha1sum $outputfile > $outputfile.sha1
}

function f_decryptfile {
        echo "Try to decrypt cmain file..."
        openssl enc -d -aes-256-cbc -k $k -in $outputfile -out $file
}

function f_downloadfile {
	echo "Try to download new cryptfile..."
	wget $domainfile -O $outputfile
	wget $domainfile.sha1 -O $outputfile.sha1
}

function f_uploadfile {
	echo "Try to upload cryptfile..."
	lftp -c 'set ftp:ssl-allow true ; set ssl:verify-certificate no; open -u '$ftpu','$ftpp' -e "cd '$co'/; mput cmain; mput cmain.sha1;quit" '$ftps''
}

f_downloadfile
f_decryptfile
f_askid
f_askfoldername
f_addtofile
f_cryptfile
f_uploadfile
