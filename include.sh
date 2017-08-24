#!/bin/sh

declare -A menifestmap=()
export menifestmap

function debug_error()
{
	echo -e "\033[47;31mERROR: $*\033[0m"
}

function debug_warn()
{
	echo -e "\033[47;34mWARN: $*\033[0m"
}

function debug_info()
{
	echo -e "\033[47;30mINFO: $*\033[0m"
}

function debug_map()
{
	for key in ${!menifestmap[@]} 
	do  
		debug_warn "key=$key, value=${menifestmap[$key]}"
	done
}
#debug_info "---------------- ..."
#debug_warn "---------------- ..."
#debug_error "---------------- ..."
