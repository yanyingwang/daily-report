2019-nCov-report
================


主要为我家人发送手机短信通知每日新型肺炎统计报告而开发，该程序开发使用了 sina.cn 或 www.tianqiapi.com 提供的api，亦感谢之。

统计报告的内容为：
1. 全国病例报告、河南省病例报告、郑州市病理报告。
2. 2月27日增加了国内省份和国外国家确诊病例排名报告。


# usage
clone this repo, cd in it, and then:

~~~racket
raco pkg install --auto

SENDER="abc@qq.com" RECIPIENT="edf@qq.com" AUTH_USER="abc" AUTH_PASSWD="abc-pswd" ./main.rkt
~~~

Or, you can check this repo's github action file for how I am using it.



