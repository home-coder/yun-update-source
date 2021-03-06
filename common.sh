#
# common.sh 云编译脚本top
#

#set -e
#!/bin/bash
. ./include.sh
. ./edit_util.sh
. ./process_server.sh

#
#@FUNC: 为方便生成map而对数据做预处理
#去掉所有#开头行; 去掉所有空行; 去掉所有//开头的行; 去掉行首空格和tab; 去掉行尾空格和tab; 去掉所有=开头的行，防止key为空
#最后的结果可以是 "key=value" 或者 "key = value"，等号两边的空格在创建map时再处理
#
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

#
#@PARAM:null; @FUNC: 获取分支，平台，属性注册表 
#
function load_local_config()
{
	debug_func "load_local_config"
	
	#根据客户唯一标识码(厂商+型号), 从custom_branch_device（随便一个，无论平台mstar还是全志或者晶晨前两个字段都是一样的）中解析对应的分支和平台下设备
	manufacturer_tmp=$(awk '($2=="PRODUCT_MANUFACTURER"){print $1}' "$SCRIPT_PWD/r-config/dolphin-cantv-h2_register")
	bmodel_tmp=$(awk '($2=="business_model"){print $1}' "$SCRIPT_PWD/r-config/dolphin-cantv-h2_register")
	if [[ -z $manufacturer_tmp || -z $bmodel_tmp ]]; then
		debug_error "Please check the register excel, exit(-1)"
		exit -1
	fi
	manufacturer=${manifestmap["$manufacturer_tmp"]}
	bmodel=${manifestmap["$bmodel_tmp"]}

	get_branch_and_device $manufacturer $bmodel

	#TODO 编译服务器切分支,
	git_checkout_branch 

	#加载开放平台所有属性在不同平台下的注册表文件
	config_register_path
}

#
#
#TODO 返回老版本，通过chat_util通知前端
#
function call_version_manager()
{
	debug_func "call_version_manager, $1"
	#TODO
}

#
#
#@FUNC: 使用一次针对manifestmap整体的扫描确定更新情况，如果更新便直接更新。
#       处理过程中要求每个事件都有确认是否更新的返回标志，并通过0+0+0+0==0判定结果
#RET  : 
# TODO
function update_local_code()
{
	debug_func "update_local_code"
	#检查是否需要更新，返回值: 1->更新并正常写入文件 0->已是最新版本无需更新
	process_manifest_event
	UPDATE_FLAG=$?
	if [[ $UPDATE_FLAG -eq 0 ]]; then
		debug_import "No changes, nothing to commit. It is latest Version"
		call_version_manager "nochange"
		#git reset 2>&1 1>/dev/null
	else
		debug_import "Some changes, It will update itself ..."
		#XXX Beta版加下面的reset作为结果diff使用，Release 将去除该行
		git reset 2>&1 1>/dev/null
	fi
}

#TODO 如果不出意外，直接调用我们原有的jeckens.sh就可以
function call_jeckens_work()
{
	debug_func "call_jeckens_work"
	#XXX Beta版添加一个build.sh方式来编译
	if [[ $UPDATE_FLAG -eq 1 ]]; then
		cd "$WORKSPACE/Allwinner-h2/scripts/"
		i=9 
		while(($i >= 0)); do
			echo -ne  "\033[41;33m马上就要编译了 $i...\033[0m\r"
			sleep 1
			let i=i-1
		done
		echo -e ""

		./build.sh
	fi
}

#TODO 去include.sh中实现UPDATE_FLAG整个代码环境的更新提交工作
function wind_up_work()
{
	debug_func "wind_up_work"
	#如果编译返回值没有出错就提交代码
	#如果出错就git reset
	call_version_manager "changed"
}

function common_main()
{
	debug_func "common_main"

	format_manifest $1

	parse_manifest $1

	load_local_config

	update_local_code

	call_jeckens_work

	wind_up_work
}

debug_func "Start . . ."
common_main $1
debug_func "End=$? . . ."
