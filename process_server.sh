#
# process_server.sh 事件处理方法
#


#
#@PARAM: key; @FUNC: 根据key值来处理不同事物
#
function handler_event()
{
	debug_func "handler_event"
	key=$1
	value=${menifestmap[$key]}
	if [ -n "&key" ]; then
		debug_error "key is NULL (exit -1)"
		exit -1
	fi
	debug_info "key=$key, value=${menifestmap[$key]}"

	case "$key" in
	"platform")
		write_mk_file $LUNCH_MK $key $value
	;;
	#TODO 其他事件
	esac
}

#
#@PARAM: null; @FUNC: 主要根据menifest生成的map来分别处理事件
#
function call_process_server()
{
	debug_func "call_process_server     >>>>>"
	for key in ${!menifestmap[@]}; do
		handler_event $key
	done
	debug_func "call_process_server     <<<<<"
}

#测试用例
##!/bin/bash
#. ./include.sh
#. ./edit_util.sh
#call_process_server
#creat_map ./test_data/manifest.prot && LUNCH_MK="./test_data/dolphin_cantv_h2.mk" && handler_event "platform" "H2"
