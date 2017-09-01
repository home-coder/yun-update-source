#
# include.sh 环境依赖项
#

export SCRIPT_PWD=`pwd`

declare -A manifestmap=()
export manifestmap

export CURENT_BRANCH  CURENT_PLATFORM REGISTER_PATH

CBP_PATH="$SCRIPT_PWD/r-config/custom_branch_platform"


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
	debug_func "creat_manifest_map"
	if [ ! -f $1 ] || [ $# -ne 1 ];then	
		debug_error "creat_local_map, invalid param. exit(-1)"
		exit -1
	fi
	while read line; do
		local key=`echo $line | awk -F '=' '{gsub(" |\t","",$1); print $1}'`
		local value=`echo $line | awk -F '=' '{gsub("^ |\t","",$2); print $2}'`
		manifestmap["$key"]=$value
	done < $1
}

#
#@PARM:以字符串形式对应map， @FUNC: 根据名称分别dump。 此方法有重复代码，未优化
#
function dump_map()
{
	debug_func "dump map->[$1]     >>>>>"
	if [ -z $1 ] || [ $# -ne 1 ];then
		debug_error "dump_map, invalid param. exit(-1)"
		exit -1
	fi
	case "$1" in
		"manifestmap")
			if [[ -z ${!manifestmap[@]} ]]; then
				debug_error "this a null map, exit(-1)"
				exit -1
			fi
			for key in ${!manifestmap[@]}; do
				if [[ -z ${manifestmap["$key"]} ]]; then
					debug_warn "a null value here key->$key"
				else
					debug_import "key=$key, value=${manifestmap["$key"]}"
				fi
			done
			;;
			## any other map ?
		*)
			debug_warn "undefined map dump, it->[$1] is not supported"
		;;
	esac
	debug_func "dump map->[$1]     <<<<<"
}

#
#@PARAM: 客户的名字；@FUNC: 根据一个唯一标示组合从配置"./r-config/custom_branch_platform"获取对应的分支以及硬件平台映射表路径
#
function get_branch_and_platform()
{
	debug_func "get_branch_and_platform"
	local manufacturer  bmodel
	brpf=$(awk -F " " -v manufacturer="$1" -v bmodel="$2" '($1==manufacturer && $2==bmodel) {print $3,$4}' $CBP_PATH)
	if [ -n "$brpf" ]; then
		CURENT_BRANCH=$(echo $brpf | awk '{print $1}')
		CURENT_PLATFORM=$(echo $brpf | awk '{print $2}')
		debug_import "branch->$CURENT_BRANCH  platform->$CURENT_PLATFORM"
	else
		debug_error "the file "custom_branch_platform" is not match this custom Id[$1, $2], exit(-1)"
		exit -1
	fi
}

function git_checkout_branch()
{
	debug_warn "git_checkout_branch"
}

function config_register_path()
{
	debug_func "config_register_path"
	REGISTER_PATH="./r-config/${CURENT_PLATFORM}_register"
	if [ ! -f "$REGISTER_PATH" ]; then
		debug_error "$REGISTER_PATH may be not exsit, exit(-1)"
		exit -1
	fi
	debug_info "current registed_path-->$REGISTER_PATH"
}

#测试用例
##!/bin/bash
#set -x
#debug_important "hello world"
#debug_func "hello world"
#debug_info "----------------"
#debug_warn "----------------"
#debug_error "----------------"
#dump_map local_org_map
#get_branch_and_platform "亿典" "BBC_H12"
#dump_map "local_org_map"
