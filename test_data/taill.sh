#########################################################################
# File Name: taill.sh
# Author   : oneface
# mail     : one_face@sina.com
# Company  : FBI
# Time     : 2018年05月07日 星期一 20时25分58秒
#########################################################################
#!/bin/bash

adb shell tail -f /usr/data/duer/log/dcssdk.log | grep "onKeyWordDetected:小度小度"&
