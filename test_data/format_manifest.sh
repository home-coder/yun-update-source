#!/bin/bash
. ../dbginfo.sh

function format_manifest()
{
	debug_info "format_manifest"
	sed -i '/^#.*/d' $1
	sed -i '/^[[:space:]]*$/d' $1
	sed -i '/^\/\/.*/d' $1
}

format_manifest $1
