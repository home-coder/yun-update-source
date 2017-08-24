#!/bin/bash
. ./../dbginfo.sh
#首先解析出menifest 的key 和 value值
#
#
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

declare -A map=()
#parse_manifest $1
map=`parse_manifest $1`
for key in ${!map[@]}  
do  
	debug_info ${map[$key]}  
done
