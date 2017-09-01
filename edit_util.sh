#
# edit_util.sh 文本编辑方法
#

#
#@PARAM:本地文件路径 @FUNC:删除行首的空格和tab.目的是搜索以key开头的关键字时是严格的
#						   因为如果文本中关键字前面有空格或者tab会匹配不到，虽然费时但是便于观察
#
function format_local_file()
{
	sed -i 's/^[ \t]*//g' $1
}

#
#@PARAM: 1:path
#		 2:key
#		 3:value
#@FUNC : 用 1:= $param_value表示替换结果, 如果不存在则追加 >>
#
function write_mk_file() 
{
	debug_func "write_mk_file in"
	debug_info $*
	if [ ! -f $1 ] || [ $# -ne 3 ];then
		debug_error "param is wrong, exit(-1)"
		exit -1
	fi
	local param_file=$1
	local param_key=$2
	local param_value=$3

	format_local_file $param_file
	if grep -r ^$param_key $param_file 2>&1 1>/dev/null; then
		sed -i '/^'$param_key'/s/\(.*\):=.*/\1:= '$param_value'/g' $param_file
	else
		debug_warn "Just add key-value, maybe not useful, Please check where it used"
		add_prop="$param_key := $param_value"
		echo $add_prop >> $param_file
	fi
}

#
#@PARAM: 1:path
#		 2:key
#		 3:value
#@FUNC : 用'$param_key'='$param_value'表示替换结果，如果不存在则追加 >>
#
function write_txt_file()
{
	debug_func "write_txt_file"
	debug_info $*
	if [ ! -f $1 ] || [ $# -ne 3 ];then
		debug_error "param is wrong, exit(-1)"
		exit -1
	fi
	local param_file=$1
	local param_key=$2
	local param_value=$3

	format_local_file $param_file
	if grep -r ^$param_key $param_file 2>&1 1>/dev/null; then
		sed -i '/^'$param_key='/s/.*/'$param_key'='$param_value',/g' $param_file
	else
		debug_warn "Just add key-value, maybe not useful, Please check where it used"
		add_prop="$param_key=$param_value,"
		echo $add_prop >> $param_file
	fi
}

#
#@PARAM: 1:path
#		 2:key
#		 3:value
#@FUNC : 用'key' '$param_key'    '$sed_value'表示替换结果，如果不存在则追加 >>
#
#@RET @1->更新 @0->无需更新
#
function write_kl_file()
{
	debug_func "write_kl_file"
	debug_info $*
	if [ $# -lt 3 ];then
		debug_error "param is wrong, exit(-1)"
		exit -1
	fi

	local retflag=0
	if [ ! -f $1 ]; then
		touch $1
		retflag=1
	else
		format_local_file $1
	fi

	local param_file=$1
	local param_key=$2
	#查看传入参数的设定，此项($3,4)可能为多项式,不可定死
	local param_value

	while read line; do
		need_ignore=$(echo $line | awk 'BEGIN{ret=0} /^#/{ret=1} /^$/{ret=1} END{print ret}')
		if [ $need_ignore -eq 1 ];then
			continue
		fi

		key_num=$(echo $line | awk '{print $2}')
		if [[ x"$key_num" == x"$param_key" ]]; then
			local flag=1
			break
		else
			flag=0
		fi
	done < $param_file

	#比较key的码值要注意可能会有 POWER WAKEUP这种两个部分构成的值
	if [[ $flag -eq 1 ]]; then
		#这个if当中的key_num 和 入参param_key是相等的, 因为break
		key_value_1=$(awk -v key_tmp="$key_num" '($2==key_tmp){print $3}' $1)
		key_value_2=$(awk -v key_tmp="$key_num" '($2==key_tmp){print $4}' $1)
		if [[ $# -eq 3 ]]; then
			#如果对应的键值是不同的，则如下方式更新[原因是kl文件可能是单项或者多项] 并将retflag置1；否则不处理保持retflag的不变
			param_value="$3"
			if [[ "$param_value"x != "$key_value_1"x || -n "$key_value_2" ]]; then
				sed -i '/'[[:space:]]$key_num[[:space:]]'/s/.*/'key' '$key_num'    '$param_value'/g'  $param_file
			fi
		elif [[ $# -eq 4 ]]; then
			#TODO
		else
			debug_warn "undefined kl inner format, just support like 1 'POWER' or 2 'POWER WAKE', this case maybe 3 'POWER WAKE HELLO'"
		fi
	else
		add_kv="key $param_key    $3   $4"
		#TODO
		if [[ $retflag -eq 0 ]]; then
			debug_warn "Add new keycod to the file->$param_file"
		fi
		echo $add_kv >> $param_file
	fi

	return $retflag



#
#	if [[ $flag -eq 0 ]]; then
#		debug_warn "Just add key-value, maybe not useful, Please check it used"
#		add_kv="key $param_key    $param_value"
#		echo $add_kv >> $param_file
#	else
#		sed_value=""
#		value_arry=$(echo $param_value|awk '{for(i=1; i<=NF; i++) print $i}')
#		#sed 不能加载含有空格的变量(还没有找到方法,TODO 加两个引号试一下)，将所有空格变成,逗号。完成sed后将,逗号替换回空格
#		for value in ${value_arry[*]}; do
#			if [[ -z $sed_value ]]; then
#				sed_value=$value
#			else
#				sed_value="$sed_value,,,,$value"
#			fi
#		done
#
#		sed -i '/'[[:space:]]$param_key[[:space:]]'/s/.*/'key' '$param_key'    '$sed_value'/g'  $param_file
#		sed -i 's/,,,,/\ \ \ \ /g' $param_file
#	fi
}

#
#@PARAM: 1:path
#		 2:section fex文件中括号内选项 boot_init_gpi
#		 3:item 为item标签下的子项，如pin脚
#		 4:value
#@FUNC : 
#
function write_fex_file()
{
	debug_func "write_fex_file"

	debug_info $*
	if [ ! -f $1 ] || [ $# -ne 4 ];then
		debug_error "param is wrong, exit(-1)"
		exit -1
	fi
	local param_file=$1
	local param_section=$2
	local param_item=$3
	local param_value=$4

	#awk -F '=' '/\['${param_section}'\]/{a=1 gsub(" |\t","",$1)} (a==1 && "'${param_item}'"==$1){gsub($2,"'${param_value}'"); a=0} {print $0 > "'${param_file}'"}' ${param_file}

	begin_section=0
	end_section=0
	has_section=0
	has_item=0

	format_local_file $param_file
	while read line; do
		let num=num+1

		if [ X"$line" = X"[$param_section]" ];then
			has_section=1
			begin_section=1
			continue
		fi

		if [ $begin_section -eq 1 ];then
			end_section=$(echo $line | awk 'BEGIN{ret=0} /^\[.*\]$/{ret=1} END{print ret}')
			if [ $end_section -eq 1 ];then
				break
			fi

			need_ignore=$(echo $line | awk 'BEGIN{ret=0} /^;/{ret=1} /^$/{ret=1} END{print ret}')
			if [ $need_ignore -eq 1 ];then
				continue
			fi
			item=$(echo $line | awk -F= '{gsub(" |\t","",$1); print $1}')
			value=$(echo $line | awk -F= '{gsub(" |\t","",$2); print $2}')

			if [ "$param_item"x == "$item"x ];then
				has_item=1
				debug_import "fex modify line num = $num, section[$param_section], item[$param_item], value[$param_value]"
				break
			else
				has_item=0
			fi
		fi
	done < $1

	#sed -i '99s/'"port:PA15<1><default><default><1>"'/'"port:PA12<1><default><default><1>"'/' $param_file

	if [[ ($has_section -ne 0)&&($has_item -ne 0)&&("$value"x != "$param_value"x) ]]; then
		sed -i "${num}s/$value/$param_value/" $param_file
		debug_import "$num: $param_item = $param_value"
	elif [[ ($has_section -ne 0)&&($has_item -ne 0)&&("$value"x == "$param_value"x) ]]; then
		debug_warn "[Do nothing]!! But Never go here, We filter and ignore the same key-value in process_server"
	elif [[ ($has_section -ne 0)&&($has_item -eq 0) ]]; then
		debug_warn "just add item, Please check your source code use or not use the item"
		sed -i "/^\[${param_section}\]/a\\$param_item = $param_value" $param_file
	else
		debug_warn "the valid item<$param_item> is not exsit, it will just add but unuseful"
		echo "[${param_section}]" >> $param_file
		echo "$param_item = $param_value" >> $param_file
	fi
}

#
#@PARAM: 1:path
#		 2:key 
#		 4:value
#@FUNC : 
#
function write_cfg_file()
{
	debug_func "write_cfg_file"
}


#测试用例
##!/bin/bash
#set -x -e
#. ./include.sh
#dump_map "local_org_map"
#write_mk_file "./test_data/dolphin_cantv_h2.mk"  "PRODUCT_MANUFACTURER"  "忆典"
#write_txt_file "./test_data/external_product.txt"  "BOX"  "迪优美特222=东莞市智而浦实业有限公司=4007772628=3375381074@qq.com" 
#write_kl_file "custom_ir_1044.kl" "128" "POWER   WAKE"
#write_fex_file "./test_data/sys_config.fex" "boot_init_gpio" "gpio1" "port:PA12<1><default><default><1>"
#write_cfg_file
