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

function config_platform_file_path()
{
	debug_func "config_platform_file_path"
	PLATFORM_PATH="./r-config/${CURENT_PLATFORM}_register"
	if [ ! -f "$PLATFORM_PATH" ]; then
		debug_error "$PLATFORM_PATH may be not exsit, exit(-1)"
		exit -1
	fi
	debug_info "current registed platform_path-->$PLATFORM_PATH"
}

#
#@PARAM: map的名字，以下但凡调用添加键值对到map的过程都会用到该参数; @FUNC: 收集本地文件的配置量，并创建一个MAP
#
function creat_local_map()
{
	debug_func "creat_local_map"
	debug_info $*
	if [ -z $1 ] || [ $# -ne 1 ];then	
		debug_error "creat_local_map, invalid param. exit(-1)"
		exit -1
	fi

	if [ ! -f "$PLATFORM_PATH" ]; then
		debug_error "$PLATFORM_PATH is not exsit, please run 'config_platform_file_path' first, exit (-1)"
		exit -1
	fi
	#遍历manifestmap中的每一项key，通过此key在属性注册表中找到本地对应的value并且生成map；其它地方会用到这个map
	#要兼容 不同平台 和 特殊属性的特殊处理

	#所有平台都有external_product.txt文件，文件格式特殊，特殊处理
	#inside_model=PRODUCT_MANUFACTURER=product_company=product_hotline=product_email
	#BOX=迪优美特222=东莞市智而浦实业有限公司=4007772628=3375381074@qq.com,

	external_product=("inside_model" "PRODUCT_MANUFACTURER" "product_company" "product_hotline" "product_email")
	local i=0
	declare -a external_product_tmp
	for var in ${external_product[@]}; do
		external_product_tmp[$i]=$(awk -v var_tmp="$var" '($2==var_tmp){print $1}' $PLATFORM_PATH)
		debug_import "${external_product_tmp[$i]}"
		let i=i+1
	done

	for key in ${!manifestmap[@]}; do
		#awk -v tmp="$key" '{print $0}' $PLATFORM_PATH
		# 1.特殊处理的属性优先处理, 厂商信息，因为external_product.txt的书写  有 顺 序  问题，需要特殊处理
		#   如果manifest中有关于厂商信息的描述，则去本地查找对应的信息并生成map, 注意external_product中各项的顺序是固定的
		for var in ${external_product_tmp[@]}; do
			if [[ "$var"x == "$key"x ]]; then
				debug_info "key的值: $var, 将统一map_external_product管理"
				any_index="$var"
				has_external=1
				continue
			fi
		done
		if [[ $has_external -eq 1 ]]; then
			external_product_file=$(awk -v var_tmp="$any_index" '($1==var_tmp){print $3}' $PLATFORM_PATH)
			map_external_product $external_product_file $1 ${external_product[@]}
		fi

		pp=$(awk -v tmp="$key" '(tmp==$1){print $2,$3}' $PLATFORM_PATH)
		#prop 和 path是本地注册表中的属性和修改路径
		prop=$(echo $pp |awk '{print $1}')
		path=$(echo $pp |awk '{print $2}')
		# 2. 特殊处理的属性优先处理, 红外设备
		if [[ ${key:0:2} == "0x" ]]; then
			case $CURENT_PLATFORM in
				"dolphin-cantv-h2")
					vendor_tmp=$(awk '($2=="customer_code"){print $1}' $PLATFORM_PATH)
					path_tmp=$(awk '($2=="customer_code"){print $3}' $PLATFORM_PATH)
					vendor=${manifestmap["$vendor_tmp"]}
					path="${path_tmp}_${vendor}.kl"
					prop=${key:2:4}
					;;
					#TODO 638
					#TODO z11
			esac
		fi

		debug_import "$key", "$prop, $path",  "是[ ${path##*.} ]类型文件"


		# 3. 没有特殊型的文件统一如下处理(包含处理过的特殊文件如表示红外的kl文件不再具有特殊性), 如修改dolphin-cantv-h2.mk文件的属性
		case ${path##*.} in
			"mk")
				map_mk_file "$1" "$prop" "$path";;
			"kl")
				map_kl_file "$1" "$prop" "$path";;
			"txt")
				map_txt_file "$1" "$prop" "$path";;
		esac
	done
}

#测试用例
#!/bin/bash
#set -x
#debug_important "hello world"
#debug_func "hello world"
#debug_info "----------------"
#debug_warn "----------------"
#debug_error "----------------"
#dump_map local_org_map
#get_branch_and_platform "亿典" "BBC_H12"
#creat_local_map "local_org_map"
#dump_map "local_org_map"
