#!/bin/bash

declare -A menifestmap=()
export menifestmap

export CURENT_BRANCH
export CURENT_PLATFORM

CBP_PATH="custom_branch_platform"

export LUNCH_MK
export CUSTOM_IR_KL
#export
#export
#export
#export
#export
#export
#export
#export
#export
#export


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

function creat_map()
{
	while read line; do
		key=`echo $line | awk -F '=' '{print $1}'`
		value=`echo $line | awk -F '=' '{print $2}'`
		debug_info "key=$key, value=$value"
		menifestmap["$key"]=$value
	done < $1
}

function debug_map()
{
	for key in ${!menifestmap[@]} 
	do  
		debug_warn "key=$key, value=${menifestmap[$key]}"
	done
}

#
#@PARAM: 客户的名字；@FUNC: 根据名字从配置"custom_branch_platform"获取对应的分支和硬件平台
#
function get_branch_and_platform()
{
	debug_warn "set_branch_and_platform"
	brpf=$(awk -F " " -v head="$1" '$1==head {print $2,$3}' $CBP_PATH)
	if [ -n "$brpf" ]; then
		CURENT_BRANCH=$(echo $brpf | awk '{print $1}')
		CURENT_PLATFORM=$(echo $brpf | awk '{print $2}')
	else
		debug_error "custom_branch_platform is wrong"
	fi
}

function git_checkout_branch()
{
	debug_warn "git_checkout_branch"
}

function config_platform_file_path()
{
	debug_warn "config_platform_file_path"
	case "$CURENT_PLATFORM" in
	"dolphin-cantv-h2")
		LUNCH_MK="./test_data/dolphin_cantv_h2.mk"
		CUSTOM_IR_KL="./test_data/custom_ir_"
		#TODO其它待修改文件路径
	;;
	#TODO 其它平台配置
	esac
}


#测试用例
#debug_info "----------------"
#debug_warn "----------------"
#debug_error "----------------"
#get_branch_and_platform "一点"
