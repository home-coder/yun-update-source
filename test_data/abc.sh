#########################################################################
# File Name: abc.sh
# Author   : oneface
# mail     : one_face@sina.com
# Company  : FBI
# Time     : 2018年05月07日 星期一 19时30分50秒
#########################################################################
#!/bin/bash
abc=`cat include.sh | grep debug2`
if [[ -z $abc ]];then
	echo "-----"
else
	echo "++++++"
fi
