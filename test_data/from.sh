#!/bin/bash
writeIni() {
	file=$1;section=$2;item=$3;val=$4
	awk -F '=' '/\['${section}'\]/{a=1} (a==1 && "'${item}'"==$1){gsub($2,"'${val}'");a=0} {print $0 > "'$file'"}' ${file}
	#echo "$sed_file" >> $1
	#1<>${file}
}
writeIni "version.ini" "VERSION" "DATE" "0001234"
