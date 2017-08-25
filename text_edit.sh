#!/bin/bash

#
#@PARAM: 1:path, "dolphin_cantv_h2.mk"
#		 2:key, "PRODUCT_MANUFACTURER"
#		 3:value, "忆典"
#@FUNC : 功能实现主要说明
#

#
#@PARAM: 1:path
#		 2:key
#		 3:value
#@FUNC : 根据key对应的value比较替换path中的文件相应的变量
#
function write_mk_file() 
{
	param_file=$1
	param_key=$2
	param_value=$3
	echo $param_file $param_key $param_value

	grep -r ^$param_key $param_file
	if [ $? -eq 0 ]; then
		sed -i '/^'$param_key'/s/\(.*\):=.*/\1:= '$param_value'/g' $param_file
	else
		add_prop="$param_key := $param_value"
		echo $add_prop
		echo $add_prop >> $param_file
	fi
}

#
#@PARAM: 1:path
#		 2:key
#		 3:value
#@FUNC : 根据BOX将后面的值替换掉，如果是新的就追加txt文件尾
#
function write_txt_file()
{
	param_file=$1
	param_key=$2
	param_value=$3
	echo $param_file $param_key $param_value
	
	grep -r ^$param_key $param_file
	if [ $? -eq 0 ]; then
		sed -i '/^'$param_key='/s/.*/'$param_key'='$param_value',/g' $param_file
	else
		add_prop="$param_key=$param_value,"
		echo $add_prop >> $param_file
	fi
}

#
#@PARAM: 1:path
#		 2:key
#		 3:value
#@FUNC : 根据参数param_key判断是否是新的num，如果不是则替换key_code，如果是则追加到kl文件末尾
#
function write_kl_file()
{
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

function write_efex_file()
{
	echo -----
}

write_mk_file "dolphin_cantv_h2.mk"  "PRODUCT_MANUFACTURER"  "忆典"
write_txt_file "external_product.txt"  "BOX"  "迪优美特222=东莞市智而浦实业有限公司=4007772628=3375381074@qq.com"
write_kl_file "custom_ir_1044.kl" "128" "POWER   WAKE"
#write_efex_file
