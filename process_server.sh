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
	value=${manifestmap[$key]}
	if [ -z "&key" ]; then
		debug_error "key is NULL (exit -1)"
		exit -1
	fi
	debug_info "key=$key, value=${manifestmap[$key]}"

	case "$key" in
		"PRODUCT_MANUFACTURER")
			write_mk_file $LUNCH_MK $key $value
			;;
			#TODO 其他事件
	esac
}

#
#@PARAM: null; @FUNC: 主要根据manifest生成的map来分别处理事件
#@RET:   0 更新成功， 1 无需更新， -1 更新失败
#
function call_process_server()
{
	debug_func "call_process_server     >>>>>"

	for key in ${!manifestmap[@]}; do
		#TODO 判断服务器下发配置manifestmap和本地收集到的配置localmap是否严格一致，不一致则升级
		handler_event $key
	done
	#TODO 当所有事件处理完成后，校验本地更新后的文件的配置processedmap与manifestmap是否严格一致，一致表明改动成功 可以升级

	debug_func "call_process_server     <<<<<"
}

#测试用例
##!/bin/bash
#. ./include.sh
#. ./edit_util.sh
#call_process_server
#creat_map ./test_data/manifest.prot && LUNCH_MK="./test_data/dolphin_cantv_h2.mk" && handler_event "platform" "H2"
