#
# include.sh 环境依赖项
#
set -e

declare -A manifestmap=()
export manifestmap

declare -A local_org_map=()
export local_org_map

declare -A local_new_map=()
export local_new_map

export CURENT_BRANCH  CURENT_PLATFORM

CBP_PATH="custom_branch_platform"

export LUNCH_MK	 CUSTOM_IR_KL	
#export
#export

function debug_import()
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


#
#@FUNC: 去除key后面的空格，去除value前面的空格, 保存为一个MAP
#
function creat_manifest_map()
{
	while read line; do
		key=`echo $line | awk -F '=' '{gsub(" |\t","",$1); print $1}'`
		value=`echo $line | awk -F '=' '{gsub("^ |\t","",$2); print $2}'`
		debug_info "key=$key, value=$value"
		manifestmap["$key"]=$value
	done < $1
}

function dump_map()
{
	debug_func "dump map     >>>>>"
	mapname=$1
	for key in ${!mapname[@]} 
	do  
		debug_import "key=$key, value=${mapname["$key"]}"
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
		debug_error "the file "custom_branch_platform" is not match this custom_id[$custom_id], exit(-1)"
		exit -1
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

#
#@PARAM: null; @FUNC: 收集本地文件的配置量，并创建一个MAP
#
function creat_local_map()
{
	debug_func "creat_local_map"
	#TODO 仿照manifestmap声明，根据不同平台配置文件路径一一收集key-value对
	mapname=$2
	for key in ${!mapname[@]} 
	do  
		debug_import "key=$key, value=${mapname["$key"]}"
	done
	while read line; do
		key=`echo $line | awk -F '=' '{gsub(" |\t","",$1); print $1}'`
		value=`echo $line | awk -F '=' '{gsub("^ |\t","",$2); print $2}'`
		debug_info "key=$key, value=$value"
		mapname["$key"]=$value
	done < $1
	for key in ${!mapname[@]} 
	do  
		debug_import "key=$key, value=${mapname["$key"]}"
	done
}

#测试用例
##!/bin/bash
#debug_important "hello world"
#debug_func "hello world"
#debug_info "----------------"
#debug_warn "----------------"
#debug_error "----------------"
creat_local_map manifest.prot local_org_map
dump_map local_org_map
#get_branch_and_platform "一点"
#creat_local_map
