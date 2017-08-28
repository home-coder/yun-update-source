# yun-update-source
yun-update-source

##################################################整体说明###############################################################################
.
├── chat_util.sh				用于与前端交互
├── common.sh					云编译脚本主函数框架
├── custom_branch_platform			客户标识  分支  硬件平台对应关系表
├── edit_util.sh				文本编辑工具类
├── include.sh					云编译必要的环境初始化依赖
├── manifest.prot				前端配置好的云编译配置項
├── process_server.sh				具体处理manifest.prot各项配置項事物的服务
├── README.md					使用说明
└── test_data					脚本临时测试使用数据

1 directory, 8 files



###################################################备忘录##############################################################################
--buglist--
-----------------
1.include.sh中debug_map不具备通用性，还只是menifest的map打印					[江秀杰]	not
2.执行common.sh后到write_mk_file出不知原因的退出							[江秀杰]	ok
3.所有awk以空格分割的地方要考虑兼容tab键,防止那个地方是tab而引起错误				[江秀杰]	not
4.如果脚本执行错误发邮件的流程是怎样的								[江秀杰]	not
5.考虑set -e引起的退出后，我们如何知道退出的返回值						[江秀杰]	not
6.校验本地更新后的文件的配置processedmap与manifestmap是否严格一致					[江秀杰]	not
