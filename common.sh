#
# common.sh 云编译脚本top
#

#!/bin/bash

set -e
. ./include.sh
. ./edit_util.sh
. ./process_server.sh

#@FUNC：方便map的生成
#
#去掉所有#开头行
#去掉所有空行
#去掉所有//开头的行
#去掉行首空格和tab
#去掉行尾空格和tab
#去掉所有=开头的行，防止key为空
#最后的结果可以是 "key=value" 或者 "key = value"，等号两边的空格在创建map时再处理
function format_manifest()
{
	debug_func "format_manifest"

	sed -i -e '/^#.*/d' -e '/^[[:space:]]*$/d' -e '/^\/\/.*/d' -e 's/^[ \t]*//g' -e 's/[ \t]*$//g' -e '/^=.*/d' $1
}

#将清单文件保存为map集合，便于存取
function parse_manifest()
{
	debug_func "parse_manifest"

	creat_manifest_map $1

	dump_map "manifestmap"
}

#包含：1.编译服务器根据如"亿典"切换到亿典分支, 2.将该分支相关需要改动的路径导出
function load_local_config()
{
	debug_func "load_local_config"
	
	#根据客户唯一标识码, 从属性注册表（随便一个）和配置文件"custom_branch_platform"中解析对应的分支和平台
	manufacturer_tmp=$(awk '($2=="PRODUCT_MANUFACTURER"){print $1}' "./r-config/dolphin-cantv-h2_register")
	bmodel_tmp=$(awk '($2=="business_model"){print $1}' "./r-config/dolphin-cantv-h2_register")
	if [[ -z $manufacturer_tmp || -z $bmodel_tmp ]]; then
		debug_error "Please check the register excel, exit(-1)"
		exit -1
	fi
	manufacturer=${manifestmap["$manufacturer_tmp"]}
	bmodel=${manifestmap["$bmodel_tmp"]}

	get_branch_and_platform $manufacturer $bmodel

	#TODO 编译服务器切分支,
	git_checkout_branch 

	#TODO 根据平台加载批量修改文件的路径
	config_platform_file_path

	#将本地原始版本的配置映射为map集合
	creat_local_map
}

#修改平台代码的方法
function update_local_code()
{
	debug_func "update_local_code"
	call_process_server
}

#如果不出意外，直接调用我们原有的jeckens.sh就可以
function call_jeckens_work()
{
	debug_func "call_jeckens_work"
}

function init_update_source()
{
	debug_func "init_update_source"

	format_manifest $1

	parse_manifest $1

	load_local_config

	#TODO 注意接收返回值
	update_local_code

	call_jeckens_work
}

debug_func "Start ..."
init_update_source $1
debug_func "End=$? ..."
