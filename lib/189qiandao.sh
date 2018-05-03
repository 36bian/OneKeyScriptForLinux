#/bin/bash

# 如果是每月的前5天
if [ `date +"%d"` -lt 6 ]  
then  
    # 获取cookies
    curl http://wapbj.189.cn/wap2017/re/sign/signQry\?pno\=33Jrsfu1wD8JIG9wW1kUjQ%3D%3D\&uim_no\=1\&imei\=null\&activ_id\=1019\&_\=1523033123747 -c cookie.189.cn --output /dev/null
    # 带cookies签到
    curl http://wapbj.189.cn/wap2017/re/sign/signOn\?activ_id\=1019\&_\=1522778681339 -b cookie.189.cn
    # 删除cookies
    rm cookie.189.cn
fi