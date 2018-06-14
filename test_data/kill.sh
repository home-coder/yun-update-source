#########################################################################
# File Name: kill.sh
# Author   : oneface
# mail     : one_face@sina.com
# Company  : FBI
# Time     : 2018年05月07日 星期一 19时51分26秒
#########################################################################
#!/bin/bash
NAME=tail

ID=`adb shell ps -ef | grep "$NAME" | grep -v "grep" | awk '{print $1}'`
echo 'found ID list:' $ID
for id in $ID
do
# 杀掉进程
adb shell kill -9 $id
echo "killed $id"
done
