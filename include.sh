#
# include.sh 环境依赖项
#

declare -A menifestmap=()
export menifestmap

export CURENT_BRANCH  CURENT_PLATFORM

CBP_PATH="custom_branch_platform"

export LUNCH_MK	 CUSTOM_IR_KL	
#export
#export

function debug_important()
{
	echo -e "\033[42;37mIMPORT: $*\033[0m"
}

function debug_func()
{
	echo -e "\033[44;37mFUNC: $*\033[0m"
}

function debug_error()
{
	echo -e "\033[41;30mERROR: $*\033[0m"
}

function debug_warn()
{
	echo -e "\033[43;30mWARN: $*\033[0m"
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
	debug_func "dump map     >>>>>"
	for key in ${!menifestmap[@]} 
	do  
		debug_warn "key=$key, value=${menifestmap[$key]}"
	done
	debug_func "dump map     <<<<<"
}

#
#@PARAM: 客户的名字；@FUNC: 根据名字从配置"custom_branch_platform"获取对应的分支和硬件平台
#
function get_branch_and_platform()
{
	debug_func "get_branch_and_platform"
	local custom_id
	brpf=$(awk -F " " -v custom_id="$1" '$1==custom_id {print $2,$3}' $CBP_PATH)
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
	debug_func "config_platform_file_path"
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
##!/bin/bash
#debug_important "hello world"
#debug_func "hello world"
#debug_info "----------------"
#debug_warn "----------------"
#debug_error "----------------"
#get_branch_and_platform "一点"
