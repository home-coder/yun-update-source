# yun-update-source
yun-update-source

#### 运行环境: 4.0版本以上的Bas ####

###### ** 整体说明 **
.
├── chat_util.sh				       用于与前端交互
├── common.sh					云编译脚本主函数框架
├── edit_util.sh				       文本编辑工具类
├── include.sh					云编译必要的环境初始化依赖
├── manifest.prot				前端配置好的云编译配置項
├── process_server.sh			具体处理manifest.prot各项配置項事物的服务
├── README.md					使用说明
└── test_data					脚本临时测试使用数据
├── r-config
│   ├── custom_branch_device         客户标识  分支  硬件平台对应关系表
│   ├── dolphin-cantv-h2_register    属性注册表
│   └── mstar638_register


整体测试命令 git checkout test_data/ && ./common.sh manifest.prot


>设计：根据文档分析，按照功能模块来逐个解析会很麻烦，最终反向直接遍历前端下发的清单文件，并将解析的内容根据注册的不同路径进行写入，特殊状况也在process_server中添加例外处理





### 备忘录
--buglist--
-----------------
- 1.include.sh中dump_map不具备通用性，还只是menifest的map打印					[江秀杰]	not
- 2.执行common.sh后到write_mk_file出不知原因的退出							[江秀杰]	ok
- 3.所有awk以空格分割的地方要考虑兼容tab键,防止那个地方是tab而引起错误				[江秀杰]	not
- 4.如果脚本执行错误发邮件的流程是怎样的								[江秀杰]	not
- 5.考虑set -e引起的退出后，我们如何知道退出的返回值						[江秀杰]	not
- 6.校验本地更新后的文件的配置local_new_map与manifestmap是否严格一致				[江秀杰]	not
- 7.fex文件的写入方法										[江秀杰]	not
- 8.cfg文件的写入方法										[闫军安]	not
- 9.config_platform_file_path平台配置文件的收集，需要将很多平台的都写好				[闫军安 江秀杰]	not
- 10.call_process_server逻辑的梳理								[江秀杰]	not
- 11.handler_event各种事件的处理，将事件类型与前端确认好						[闫军安 江秀杰]	not
- 12.creat_local_map需要考虑kl等文件的特殊化处理,生成localmap					[闫军安 江秀杰]	not
- 13.对edit_util.sh中所有方法加入if [ ! -f $1 ] || [ $# -ne参数校验				[闫军安 江秀杰]	not
- 14.creat_local_map创建满足两种local_org_map 和 local_new_map					[闫军安 江秀杰]	not
- 15.考虑修改map键值对的方式写入文件还是直接写入文件比较好						[江秀杰]	not
- 16.inside_model和external_produc.tx里面的值在具体流程中的问题					[江秀杰]	not
- 17.根据文档说明也要将kl文件的名字和键值等读取到								[江秀杰]     not
- 18.kl文件的写入要反复比较多个字段的如wake的情况                                                          [江秀杰]    not
- 19.执行路径问题，比如r-config的路径等等										[江秀杰]    not

- 20.内部型号烧录信息Can C1换成CanC1(无空格)，应用拿到此数据后转换为Can C1上报到后台，2-8以此类推。其他内部型号按原有数据读取上报。 [江秀杰]  not
- 21.内部型号是否可以直接确定分支，参照高瑞国的渠道表  [江秀杰]  not

## << 参考手册 >>  
### 所有命令链接
--
http://man.linuxde.net

AWK:
--
http://man.linuxde.net/awk

SED:
--
http://man.linuxde.net/sed

正则:
--
http://www.blogjava.net/jasmine214--love/archive/2011/10/12/361040.html
