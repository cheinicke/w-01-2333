#!/bin/bash
# Filename: sc-crypter.sh (script)
# Version : 1.2
#
# Comment : 	Download + Decrypt mainfile
#		Check available folder for next step
#		Compress folder to file and crypt file
source config
file="main"
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

function f_uploadfile {
        echo "Try to upload cryptfile..."
        lftp -c 'set ftp:ssl-allow true ; set ssl:verify-certificate no; open -u '$ftpu','$ftpp' -e "cd data/; mput output/*;quit" '$ftps''
	rm output/*
}



f_downloadfile
f_decryptfile

OIFS=$IFS
IFS=";"    #notice: this is your field separator
mkdir output
while read var1 var2 var3

do
if [ "$var1" != "CardID" ]; then
	if [ -d "$var2" ]; then
        	tar -zvchf - "$var2"/* | openssl enc -e -aes-256-cbc -k $m -out output/$var3.tar.gz
        	rm -R $var2
	fi
fi

done < $file
IFS=$OIFS

f_uploadfile
