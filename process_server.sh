#
# process_server.sh 事件处理方法
#

#
#所有平台都有external_product.txt文件，文件内容特殊 5个字段有顺序，特殊处理
#inside_model=PRODUCT_MANUFACTURER=product_company=product_hotline=product_email
#
#@RET :@1->更新并正常写入文件 @0->已是最新版本无需更新
#
#特殊说明，此方法是在文档中明确说明各个字段为必填选项情况下成立
#
function process_external_product()
{
	debug_func "process_external_product"

	#BOX=迪优美特222=东莞市智而浦实业有限公司=4007772628=3375381074@qq.com,

	#根据内部机型属性从manifest获取对应的键值
	local key_index="inside_model"
	local key_tmp=$(awk -v var="$key_index" '($2==var){print $1}' $REGISTER_PATH)
	local inside_model_value=${manifestmap["$key_tmp"]}
	if [ -z "$inside_model_value" ]; then
		debug_error "not exsit 'inside_model'...please ask manifest"
		exit -1
	fi

	local external_product_file=$(awk -v mindex="$key_index" '($2==mindex){print $3}' $REGISTER_PATH)

	#取第一个字段在manifest查询到的value做为key, 其余字段在manifest中的查询结果拼接后作为为value
	#两个for，一个是先找到manifest定义的字段，er个然后通过该字段找到对应的value，并使用 = 拼接成一个value
	local external_product=("PRODUCT_MANUFACTURER" "product_company" "product_hotline" "product_email")

	local i=0
	local var
	declare -a external_product_tmp
	for var in "${external_product[@]}"; do
		external_product_tmp[$i]=$(awk -v var_tmp="$var" '($2==var_tmp){print $1}' $REGISTER_PATH)
		let i=i+1
	done
	local len=${#external_product_tmp}
	local first=1
	for var in "${external_product_tmp[@]}"; do
		if [[ -n "$var" ]]; then
			if [[ $first -eq 1 ]]; then
				local use_var=${manifestmap["$var"]}
				first=0
			else
				use_var="${use_var}=${manifestmap["$var"]}"
			fi
		else
			debug_error "is null ?! kidding me ? This is a must write data, please ask manifest"
			exit -1
		fi
	done

	write_txt_file "$external_product_file" "$inside_model_value" "$use_var"

	return $?
}

#
#@PARAM: TODO
#
function process_keyboard_layout()
{
	debug_func "process_keyboard_layout"
	debug_info $*
	if [ -z $1 ] || [ $# -ne 2 ];then
		debug_error "param is wrong, exit(-1)"
		exit -1
	fi

	local irlabel=$1
	local key_tmp=$2
	local key=${key_tmp:2:4}
	local value="${manifestmap["$key_tmp"]}"

	#不同平台对kl文件名字不同处理; 比如全志: custom_code+business_model唯一指定一个kl配置文件
	#TODO 其它平台还需要可扩展
	case $CURENT_PLATFORM in
		"dolphin-cantv-h2")
			local path_tmp=$(awk '($2=="customer_code"){print $3}' $REGISTER_PATH)
			local path="$path_tmp/custom_ir_${irlabel}.kl"
			;;
			#TODO 638
			#TODO z11
	esac

	#注意不讲$value加""是特意安排的，目的是传入时将字段的个数完全暴露而不当做一个整体, 因为有的键码值是多项式
	write_kl_file "$path" "$key" $value
}

#
#@RET  :@1->更新并正常写入文件 @0->已是最新版本无需更新  @出错处理:直接exit -1退出当前shell进程
#@FUNC :两点-> 1.检测本地原始配置是否需要更新,满足更新条件则写入文件；2.修改后的本地配置和manifest中的是否达成一致
#
#处理流程 TODO
#
#
function call_process_server()
{
	debug_func "call_process_server    >>>>>"

	if [[ ! -f "$REGISTER_PATH" ]]; then
		debug_error "$REGISTER_PATH is not exsit, please run 'config_platform_file_path' first, exit (-1)"
		exit -1
	fi



	##################################################################################################################################################
	#要兼容一些特殊情况   ：1.特殊属性的特殊处理   :如external_product.txt文件内容的格式定义的很独特，特殊处理
	#					    2.不同平台下的特殊处理 :如红外遥控配置的kl文件的命名方式有不同,有些兼容android通用平台，有些平台厂商有自定义的命名处理规则
	#						3.等待以后遇到添加
	#
	#其它共性情况统一处理  :如mk文件的操作等是具有简单的key-value对应填写关系的
	#
	#另外注意返回值的判定  :bash 不支持位运算,仅支持逻辑运算; 此处使用0+0+0+0==0方式判定最后的累计结果
	##################################################################################################################################################



	local retflag=0

##---external product----#
	process_external_product
	let retflag=retflag+$?

	#for将跳过特殊处理过的key, 然后统一处理普通的属性
	local key
	for key in ${!manifestmap[@]}; do
		#awk -v tmp="$key" '{print $0}' $REGISTER_PATH
		#prop 和 path是本地注册表中的属性和修改路径; prop以后将作为key，而value需要从manifest中获取

		local pp=$(awk -v tmp="$key" '($1==tmp){print $2,$3}' $REGISTER_PATH)
		if [[ -n "$pp" ]]; then
			local prop=$(echo $pp |awk '{print $1}')
		elif [[ "${key:0:2}" == "0x" ]]; then
			#下面操作将0x开头的键码事件不作为普通事件封装,并注意变量的静态性,赋值为空目的是洗掉上一次的值
			prop=""
		else
			debug_warn "Not yet register this prop->$key"
		fi

##---keyboad layout---#
		if [[ "$prop" == "customer_code" ]]; then
			continue
		elif [[ "${key:0:2}" == "0x" ]]; then
			local irlabel_tmp=$(awk '($2=="customer_code"){print $1}' $REGISTER_PATH)
			local irlabel=${manifestmap["$irlabel_tmp"]}
			process_keyboard_layout $irlabel $key
			let retflag=retflag+$?
			continue
		fi

##---如果还有例外事件，add the Exception Event Function here---#


		#inside_model=PRODUCT_MANUFACTURER=product_company=product_hotline=product_email
		if [[  "$prop" == "inside_model"
			#注释掉是因为这个字段在另一处即device下的mk文件中有用到,所以不加入blacklist
			#|| "$prop" == "PRODUCT_MANUFACTURER"
			|| "$prop" == "product_company"
			|| "$prop" == "product_hotline"
			|| "$prop" == "product_email"  ]]; then

			continue
		fi

##---normal property---#
		local path=$(echo $pp |awk '{print $2}')
		local value=${manifestmap["$key"]}
		debug_import "$key", "$prop, $path",  "是[ ${path##*.} ]类型文件"
		case ${path##*.} in
			"mk")
				write_mk_file "$path" "$prop" "$value";;
			"txt")
				write_txt_file "$path" "$prop" "$value";;
			"cfg")
				write_cfg_file "$path" "$prop" "$value";;
			"fex")
				write_fex_file "$path" "$prop" "$value";;
			*)
				debug_warn "undefined case [${path##*.}] file"
				;;
		esac

		let retflag=retflag+$?
	done

	debug_func "call_process_server    <<<<<"

	return $retflag
}

#测试用例
##!/bin/bash
#. ./include.sh
#. ./edit_util.sh
#call_process_server
