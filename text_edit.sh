#!/bin/bash
function write_mk_file() 
{
	#test
	echo "write_mk_file"
	param_file="dolphin_cantv_h2.mk"
	param_key="PRODUCT_MANUFACTURER"
	param_value="忆典"
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

function write_txt_file()
{
	param_file="external_product.txt"
	param_key="BOX"
	param_value="迪优美特222=东莞市智而浦实业有限公司=4007772628=3375381074@qq.com"
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
#@PARAM: 1:custom_ir_1044.kl
#		 2:128
#		 3:POWER   WAKE
#@FUNCTION: 根据参数param_key判断是否是新的num，如果不是则替换key_code，如果是则追加到kl文件末尾
#
function write_kl_file()
{
	param_file="custom_ir_1044.kl"
	param_key="128"
	param_value="POWER   WAKE"

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

#write_mk_file
#write_txt_file
write_kl_file
#write_efex_file
