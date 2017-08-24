#!/bin/bash

set -e
. ./include.sh
. ./text_edit.sh


function format_manifest()
{
	debug_error "format_manifest"

	sed -i '/^#.*/d' $1
	sed -i '/^[[:space:]]*$/d' $1
	sed -i '/^\/\/.*/d' $1
}

function parse_manifest()
{
	debug_error "parse_manifest"

	while read line; do
		key=`echo $line | awk -F '=' '{print $1}'`
		value=`echo $line | awk -F '=' '{print $2}'`
		debug_info "key=$key, value=$value"
		menifestmap["$key"]=$value
	done < $1

	debug_map
}

function load_local_config()
{
	debug_error "load_config_byname"

	platform_name="${menifestmap["PRODUCT_NAME"]}"
	debug_warn "PRODUCT_NAME = $platform_name}"
	
}

function update_local_code()
{
	debug_error "update_source_bymap"
}

function init_update_source()
{
	debug_error "init_update_source"

	format_manifest $1

	parse_manifest $1
	
	load_local_config

	update_local_code
}

init_update_source $1
