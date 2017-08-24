#!/bin/bash

set -e

#加载头文件
. ./dbginfo.sh

function format_manifest()
{
	debug_info "format_manifest"
}

function get_platform_name()
{
	debug_info "get_platform_name"
}

function load_config_byname()
{
	debug_info "load_config_byname"
}

function parse_manifest()
{
	debug_info "parse_manifest"
	local -A map=()

	while read line; do
		key=`echo $line | awk -F '=' '{print $1}'`
		value=`echo $line | awk -F '=' '{print $2}'`
		debug_info "key=$key, value=$value"
		map["$key"]=$value
	done < $1

	for key in ${!map[@]}  
	do  
		debug_info ${map[$key]}  
	done
	return $map
}

function update_source_bymap()
{
	debug_info "update_source_bymap"
}

function init_update_source()
{
	debug_info "init_update_source"
	format_manifest $1
	platform_name=$(get_platform_name $1)
	
	load_config_byname $platform_name

	declare -A map=()
#	parse_manifest $1
	map=$(parse_manifest $1)

	update_source_bymap $map
}

init_update_source $1
