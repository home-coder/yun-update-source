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

export CURENT_BRANCH  CURENT_PLATFORM PLATFORM_PATH

CBP_PATH="./r-config/custom_branch_platform"

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
	if [ ! -f $1 ] || [ $# -ne 1 ];then	
		debug_error "creat_local_map, invalid param. exit(-1)"
		exit -1
	fi
	while read line; do
		key=`echo $line | awk -F '=' '{gsub(" |\t","",$1); print $1}'`
		value=`echo $line | awk -F '=' '{gsub("^ |\t","",$2); print $2}'`
		debug_info "key=$key, value=$value"
		manifestmap["$key"]=$value
	done < $1
}


#
#@PARM:以字符串形式对应map， @FUNC: 根据名称分别dump。 此方法有重复代码，未优化
#@PARM:以字符串形式对应map， @FUNC: 根据名称分别dump。 此方法有重复代码，未优化
#@PARM:以字符串形式对应map， @FUNC: 根据名称分别dump。 此方法有重复代码，未优化
#
function dump_map()
{
	debug_func "dump map->[$1]     >>>>>"
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
		"local_org_map")
			if [[ -z ${!local_org_map[@]} ]]; then
				debug_error "this a null map, exit(-1)"
				exit -1
			fi
			for key in ${!local_org_map[@]}; do
				if [[ -z ${local_org_map["$key"]} ]]; then
					debug_warn "a null value here key->$key"
				else
					debug_import "key=$key, value=${local_org_map["$key"]}"
				fi
			done
			;;
		"local_new_map")
			if [[ -z ${!local_new_map[@]} ]]; then
				debug_error "this a null map, exit(-1)"
				exit -1
			fi
			for key in ${!local_new_map[@]}; do
				if [[ -z ${local_new_map["$key"]} ]]; then
					debug_warn "a null value here key->$key"
				else
					debug_import "key=$key, value=${local_new_map["$key"]}"
				fi
			done
			;;
		*)
			debug_warn "invalid map dump, it->[$1] is not exsit"
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
	local manufacturer  model
	brpf=$(awk -F " " -v manufacturer="$1" -v model="$2" '($1==manufacturer && $2==model) {print $2,$3}' $CBP_PATH)
	if [ -n "$brpf" ]; then
		CURENT_BRANCH=$(echo $brpf | awk '{print $1}')
		CURENT_PLATFORM=$(echo $brpf | awk '{print $2}')
		debug_import "branch->$CURENT_BRANCH  platform->$CURENT_PLATFORM"
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
	PLATFORM_PATH="./r-config/${CURENT_PLATFORM}_register"
	debug_info "current platform_path-->$PLATFORM_PATH"
}

#
#@PARAM: null; @FUNC: 收集本地文件的配置量，并创建一个MAP
#
function creat_local_map()
{
	debug_func "creat_local_map"
	#TODO 仿照manifestmap声明，根据不同平台配置文件路径一一收集key-value对
	if [ ! -f $1 ] || [ $# -ne 2 ];then	
		debug_error "creat_local_map, invalid param. exit(-1)"
		exit -1
	fi
	while read line; do
		key=`echo $line | awk -F '=' '{gsub(" |\t","",$1); print $1}'`
		value=`echo $line | awk -F '=' '{gsub("^ |\t","",$2); print $2}'`
		debug_info "key=$key, value=$value"
		if [[ "$2"x == "local_org_map"x ]]; then
			local_org_map["$key"]=$value
		elif [[ "$2"x == "local_new_map"x ]]; then
			local_new_map["$key"]=$value
		else
			debug_warn "intend to create invalid map, ignore"
		fi
	done < $1
}

#测试用例
#!/bin/bash
#debug_important "hello world"
#debug_func "hello world"
#debug_info "----------------"
#debug_warn "----------------"
#debug_error "----------------"
#creat_local_map manifest.prot local_org_map
#dump_map local_org_map
#get_branch_and_platform "亿典" "BBC_H12"
creat_local_map manifest.prot "local_org_map"
dump_map "local_org_map"
