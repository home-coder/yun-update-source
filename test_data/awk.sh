#!/bin/bash


function awk_test()
{
	awk -F '=' '{print $2}' $1
	awk -F '=' '/PRODUCT_MANUFACTURER/{print $2}' $1
	awk -F '=' '{
		if ($1=="PRODUCT_MANUFACTURER") {
			print $2
		}
	}' $1
	awk -F "=" -v value="讯玛" '(value==$2){print "value="value}' $1

	echo ====================================

	awk -F "=" -v file=$1 '($1=="PRODUCT_MANUFACTURER"){$2="无敌 先锋"}{print $1"="$2 > file}' $1
	#awk -F "=" -v 
	awk -F "=" -v file=$1 '/^0x11/{$2="what fuck"} {print $1"= " $2 > file}' $1
}

awk_test manifest.prot
