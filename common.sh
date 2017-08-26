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
function format_manifest()
{
	debug_error "format_manifest"

	sed -i '/^#.*/d' $1
	sed -i '/^[[:space:]]*$/d' $1
	sed -i '/^\/\/.*/d' $1
	sed -i 's/^[ \t]*//g' $1
	sed -i 's/[ \t]*$//g' $1
	sed -i '/^=.*/d' $1
}

#将清单文件保存为map集合，便于存取
function parse_manifest()
{
	debug_error "parse_manifest"

	creat_map $1

	debug_map
}

#包含：1.编译服务器根据如"亿典"切换到亿典分支, 2.将该分支相关需要改动的路径导出
function load_local_config()
{
	debug_error "load_local_config"
	
	#根据客户名字, 从配置文件"custom_branch_platform"中读取对应的分支和平台
	manu_name="${menifestmap["PRODUCT_MANUFACTURER"]}"
	debug_warn "PRODUCT_MANUFACTURER = $manu_name"
	get_branch_and_platform $manu_name 
	debug_info "branch:$CURENT_BRANCH  platform:$CURENT_PLATFORM"

	#TODO 编译服务器切分支,
	git_checkout_branch 

	#TODO 根据平台加载批量修改文件的路径
	config_platform_file_path
}

#修改平台代码的方法
function update_local_code()
{
	debug_error "update_local_code"
	#TODO 遍历map的value并做相应的处理:1.一般情况判断该写入上面export出来的路径中，2满足条件请求服务器并接收logo等资源，然后写入上面的路径中
	call_process_server
}

#如果不出意外，直接调用我们原有的jeckens.sh就可以
function call_jeckens_work()
{
	debug_error "call_jeckens_work"
}

function init_update_source()
{
	debug_error "init_update_source"

	format_manifest $1

	parse_manifest $1

	load_local_config

	update_local_code

	call_jeckens_work
}

debug_error "Start ..."
init_update_source $1
debug_error "End=$? ..."
