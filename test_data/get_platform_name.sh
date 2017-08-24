#!/bin/bash

. ../dbginfo.sh

function parse_manifest()
{
	local -A map=()

	while read line; do
		key=`echo $line | awk -F '=' '{print $1}'`
		value=`echo $line | awk -F '=' '{print $2}'`
		debug_info "key=$key, value=$value"
		map["$key"]=$value
	done < $1

	#	for key in ${!map[@]}  
	#	do  
	#		debug_info ${map[$key]}  
	#	done
	return $map
}

function get_platform_name()
{
	debug_info "get_platform_name"
	index="PRODUCT_NAME"

}

get_platform_name $1
