#
# edit_util.sh 文本编辑方法
#


#
#@PARAM: 1:path
#		 2:key
#		 3:value
#@FUNC : 用 1:= $param_value表示替换结果, 如果不存在则追加 >>
#
function write_mk_file() 
{
	debug_func "write_mk_file in"
	param_file=$1
	param_key=$2
	param_value=$3
	debug_info $param_file $param_key $param_value

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
	param_file=$1
	param_key=$2
	param_value=$3
	debug_info $param_file $param_key $param_value

	if grep -r ^$param_key $param_file; then
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
function write_kl_file()
{
	debug_func "write_kl_file"

	param_file=$1
	param_key=$2
	param_value=$3

	local num
	key_num=$(cat $param_file|awk '{for(i=1; i<=NF; i++) print $i}')
	for num in ${key_num[*]}; do
		if [[ $num == $param_key ]]; then
			flag=1
			break
		else
			flag=0
		fi
	done

	if [[ $flag -eq 0 ]]; then
		debug_warn "Just add key-value, maybe not useful, Please check it used"
		add_kv="key $param_key    $param_value"
		echo $add_kv >> $param_file
	else
		sed_value=""
		value_arry=$(echo $param_value|awk '{for(i=1; i<=NF; i++) print $i}')
		#sed 不能加载含有空格的变量，将所有空格变成,逗号。完成sed后将,逗号替换回空格
		for value in ${value_arry[*]}; do
			if [[ -z $sed_value ]]; then
				sed_value=$value
			else
				sed_value="$sed_value,,,,$value"
			fi
		done

		sed -i '/'[[:space:]]$param_key[[:space:]]'/s/.*/'key' '$param_key'    '$sed_value'/g'  $param_file
		sed -i 's/,,,,/\ \ \ \ /g' $param_file
	fi
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
	if [ ! -f $1 ] || [ $# -ne 4 ];then
		debug_error "param is wrong, exit(-1)"
		exit -1
	fi  

	param_file=$1
	param_section=$2
	param_item=$3
	param_value=$4

	#awk -F '=' '/\['${param_section}'\]/{a=1 gsub(" |\t","",$1)} (a==1 && "'${param_item}'"==$1){gsub($2,"'${param_value}'"); a=0} {print $0 > "'${param_file}'"}' ${param_file}
	#awk -F "=" '/^\['${param_section}'\]/{a=1} {i++} (a==1 && !""'${param_item}'"==$1"){print i; a=0}' $param_file

	begin_block=0
	end_block=0
	has_section=0
	has_item=0

	cat $1 | while read line; do
    	num=`expr $num + 1`
    	if [ "X$line" = "X[$param_section]" ];then
			has_section=1
    		begin_block=1
    		continue
    	fi  
    
    	if [ $begin_block -eq 1 ];then
    		end_block=$(echo $line | awk 'BEGIN{ret=0} /^\[.*\]$/{ret=1} END{print ret}')
    		if [ $end_block -eq 1 ];then
    			break
    		fi 
 
    		need_ignore=$(echo $line | awk 'BEGIN{ret=0} /^#/{ret=1} /^$/{ret=1} END{print ret}')
    		if [ $need_ignore -eq 1 ];then
    			continue
    		fi 
    		field=$(echo $line | awk -F= '{gsub(" |\t","",$1); print $1}')
    		#####Fix Me We Support Space Value
    		value=$(echo $line | awk -F= '{gsub("","",$2); print $2}')
    		if [ "X$param_item" = "X$field" ];then
				has_item=1
    			debug_import "fex modify line num = $num"
    			break
			else
				has_item=0
    		fi
    	fi
	done

	if [ $has_section&&$has_item&&$value!=$param_value ]; then
		sed -i "${num}s/$param_value/$value/g" $param_file
	elif [ $has_section&&$has_item&&$value==$param_value ]
		debug_info "because there is not any different, so do nothing"
	elif [ $has_section&&!$has_item ]
		debug_warn "just add item, Please check your source code use or not use the item"
	else
		debug_warn "the valid item<$param_item> is not exsit, it will just add but unuseful"
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
#!/bin/bash
. ../include.sh
#write_mk_file "./test_data/dolphin_cantv_h2.mk"  "PRODUCT_MANUFACTURER"  "忆典"
#write_txt_file "external_product.txt"  "BOX"  "迪优美特222=东莞市智而浦实业有限公司=4007772628=3375381074@qq.com"
#write_kl_file "custom_ir_1044.kl" "128" "POWER   WAKE"
write_fex_file "sys_config.fex" "boot_init_gpio" "gpio1" "port:PA12<1><default><default><1>"
#write_cfg_file
