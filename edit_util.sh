#
# edit_util.sh 文本编辑方法
#

#############################################################################
#@PARAM:本地文件路径 
#@FUNC:删除行首的空格和tab.目的是搜索以key开头的关键字时是严格的因为如果
#	   文本中关键字前面有空格或者tab会匹配不到，虽然费时但是便于观察
#
#############################################################################
function format_local_file()
{
	sed -i 's/^[ \t]*//g' $1
}

#############################################################################
#@PARAM: 1:path 文本以 # 作为注释， 以 := 作为键和值的关系
#				FIXME: 仅仅支持文本中关键字如'PRODUCT_MANUFACTURER'必须在行首,
#					   前面不要有空格
#		 2:key
#		 3:value
#@FUNC : 用 1:= $param_value表示替换结果, 如果不存在则追加 >>
#
#@RET  : @1->更新 @0->无需更新
#############################################################################
function write_mk_file() 
{
	debug_func "write_mk_file $*"

	if [ $# -ne 3 ];then
		debug_error "param is wrong, exit(-1)"
		exit -1
	fi

	local retflag=0

	if [ ! -f $1 ]; then
		debug_warn "There is not a file->'$1', now creat it"
		touch $1
		retflag=1
	fi

	local param_file=$1
	local param_key=$2
	local param_value=$3

	#如果找不到以$param_key开头的行则认为不存在正在写入的key-value, 追加到文本尾, 并更新升级标志
	if ! grep -r ^"$param_key" "$param_file"; then
		add_prop="$param_key := $param_value"
		echo "$add_prop" >> $param_file
		retflag=1
		debug_warn "Add <$param_key, $param_value>, Please ensure it is useful"
	else
		#2>&1 1>/dev/null
		#如果找到这样的关键字，则匹配后面的value如果不同则更新，并更新升级标志
		file_value=$(grep -r ^"$param_key" "$param_file" | awk -F ':=' '{gsub(" |\t","",$2); print $2}')
		if [[ x"$file_value" != x"$param_value" ]]; then
			retflag=1
			sed -i '/^'$param_key'/s/\(.*\):=.*/\1:= '$param_value'/g' $param_file
			debug_info "Change '$file_value' -> '$param_value'"
		else
			debug_info "same key-value, skip"
		fi
	fi

	return $retflag
}

#############################################################################
#@PARAM: 1:path 文本以 // 作为注释， 以 = 作为键和值的关系
#		 2:key
#		 3:value
#@FUNC : 用'$param_key'='$param_value'表示替换结果，如果不存在则追加 >>
#
#RET   : @1->更新 @0->无需更新
#############################################################################
function write_txt_file()
{
	debug_func "write_txt_file $*"

	if [ $# -ne 3 ];then
		debug_error "param is wrong, exit(-1)"
		exit -1
	fi

	local retflag=0

	if [ ! -f $1 ]; then
		debug_warn "There is not a file->'$1', now creat it"
		touch $1
		retflag=1
	else
		format_local_file $1
	fi

	local param_file=$1
	local param_key=$2
	local param_value=$3

	#如果找不到以$pkey_value开头的行则认为不存在正在写入的key-value, 追加到文本尾, 并更新升级标志
	pkey_value="$param_key="$param_value,""
	if ! grep -r ^"$pkey_value" "$param_file"; then
		echo "$pkey_value" >> $param_file
		retflag=1
		debug_warn "Just add <$param_key, $param_value>, Please ensure it is useful"
	else
		debug_info "same key-value, skip"
	fi

	#sed -i '/^'$param_key='/s/.*/'$param_key'='$param_value',/g' $param_file

	return $retflag
}

#############################################################################
#@PARAM: 1:path 文本以 # 作为注释， 以 空格 作为键和值的关系; 
#			    FIXME:仅仅支持key的value为单项或者两项如"POWER  WAKE"
#		 2:key
#		 3:value
#@FUNC : 用'key' '$param_key'    '$value'表示替换结果，如果不存在则追加 >>
#
#@RET  : @1->更新 @0->无需更新
#############################################################################
function write_kl_file()
{
	debug_func "write_kl_file $*"

	if [ $# -lt 3 ];then
		debug_error "param is wrong, exit(-1)"
		exit -1
	fi

	local retflag=0

	if [ ! -f $1 ]; then
		debug_warn "There is not a file->'$1', now creat it"
		touch $1
		retflag=1
	else
		format_local_file $1
	fi

	local param_file=$1
	local param_key=$2
	#查看传入参数的设定，此项($3,4)可能为多项式,不可定死
	local param_value_1 param_value_2

	local flag
	while read line; do
		need_ignore=$(echo "$line" | awk 'BEGIN{ret=0} /^#/{ret=1} /^$/{ret=1} END{print ret}')
		if [ $need_ignore -eq 1 ];then
			continue
		fi

		key_num=$(echo "$line" | awk '{print $2}')
		#如果在kl文件中匹配到了keycode就跳出循环，哪怕下面还有重复值(因为后续的sed操作会检查所有重复值无需担心)
		if [[ x"$key_num" == x"$param_key" ]]; then
			flag=1
			break
		else
			flag=0
		fi
	done < $param_file

	#比较key的码值要注意不止类似有 "MENU" 还有 "POWER WAKEUP"这种多项式构成的值,但是没有第三种形式了
	if [[ $flag -eq 1 ]]; then
		#这个if当中的key_num 和 入参param_key是相等的, 因为break
		key_value_1=$(awk -v key_tmp="$key_num" '($2==key_tmp){print $3}' $1)
		key_value_2=$(awk -v key_tmp="$key_num" '($2==key_tmp){print $4}' $1)
		if [[ $# -eq 3 ]]; then
			param_value_1="$3"
			#如果对应的键值是不同的，则如下方式更新[原因是本地kl文件可能是单项或者多项] 并将retflag置1；否则维持不变依据0+0+0==0
			if [[ "$param_value_1"x != "$key_value_1"x || -n "$key_value_2" ]]; then
				#'key\([[:space:]]\)\+'起到防止这一行是#注释行的话引起的源文件污染
				sed -i '/'^'key\([[:space:]]\)\+'$key_num[[:space:]]'/s/.*/'key' '$key_num'   '$param_value_1'/g'  $param_file
				debug_info "change "key $key_num  $key_value_1 $key_value_2" -->"key $key_num  $param_value_1""
				retflag=1
			else
				debug_info "same code, skip"
			fi
		elif [[ $# -eq 4 ]]; then
			param_value_1="$3"
			param_value_2="$4"
			#如果对应的键值是不同的，则如下方式更新[原因是本地kl文件可能是单项或者多项] 并将retflag置1；否则维持不变依据0+0+0==0
			if [[ "$param_value_1"x != "$key_value_1"x ||  "$param_value_2"x != "$key_value_2"x ]]; then
				#'key\([[:space:]]\)\+'起到防止这一行是#注释行的话引起的源文件污染
				sed -i '/'^'key\([[:space:]]\)\+'$key_num[[:space:]]'/s/.*/'key' '$key_num'   '$param_value_1'   '$param_value_2'/g'  $param_file
				debug_info "change "key $key_num  $key_value_1 $key_value_2" -->"key $key_num  $param_value_1 $param_value_2""
				retflag=1
			else
				debug_info "same code, skip 666"
			fi
		else
			debug_error "undefined kl inner format, just support like 1 'POWER' or 2 'POWER WAKE', this case maybe 3 'POWER WAKE HELLO', exit (-1)"
			exit -1
		fi
	else #flag=0包含kl文件不存在和manifest的键值在kl文件中不存在两种情况
		if [[ $# -eq 3 ]]; then
			add_kv="key $param_key   $3"
		elif [[ $# -eq 4 ]]; then
			add_kv="key $param_key   $3     $4"
		else
			debug_error "undefined kl inner format, just support like 1 'POWER' or 2 'POWER WAKE', this case maybe 3 'POWER WAKE HELLO', exit (-1)"
			exit -1
		fi
		retflag=1
		echo "$add_kv" >> $param_file
		debug_info "add "key $add_kv""
	fi

	return $retflag
}

#############################################################################
#@PARAM: 1:path 文本以 ; 作为注释， 以 = 作为键和值的关系, 含有[]这种块区域划分
#				FIXME:处理是以字面行为准，所以文本中不要有换行转义 "\"
#		 2:section fex文件中括号内选项 boot_init_gpi
#		 3:item 为item标签下的子项，如pin脚
#		 4:value
#@FUNC : 

#RET   :TODO
#############################################################################
function write_fex_file()
{
	debug_func "write_fex_file $*"

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

		#块区[ ]开始标志
		if [ X"$line" = X"[$param_section]" ];then
			has_section=1
			begin_section=1
			continue
		fi

		if [ $begin_section -eq 1 ];then
			#块区[ ]结束标志
			end_section=$(echo $line | awk 'BEGIN{ret=0} /^\[.*\]$/{ret=1} END{print ret}')
			if [ $end_section -eq 1 ];then
				break
			fi

			#跳过 ; 开头的注释行
			need_ignore=$(echo $line | awk 'BEGIN{ret=0} /^;/{ret=1} /^#/{ret=1} END{print ret}')
			if [ $need_ignore -eq 1 ];then
				continue
			fi
			#获取过程
			item=$(echo $line | awk -F= '{gsub(" |\t","",$1); print $1}')
			value=$(echo $line | awk -F= '{gsub(" |\t","",$2); print $2}')

			#匹配过程
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

	#业务逻辑
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

#############################################################################
#@PARAM: 1:path
#		 2:key 
#		 4:value
#@FUNC : 
#############################################################################
function write_cfg_file()
{
	debug_func "write_cfg_file"
}


#测试用例
##!/bin/bash
#set  -e
#. ./include.sh
#dump_map "local_org_map"
#write_mk_file "./test_data/dolphin_cantv_h2.mk"  "PRODUCT_MANUFACTURER"  "忆典"
#write_txt_file "./test_data/external_product.txt"  "BOX"  "迪优美特222=东莞市智而浦实业有限公司=4007772628=3375381074@qq.com" 
#write_kl_file "./test_data/custom_ir_1044.kl" "128" POWER   
#write_fex_file "./test_data/sys_config.fex" "boot_init_gpio" "gpio1" "port:PA12<1><default><default><1>"
#write_cfg_file
