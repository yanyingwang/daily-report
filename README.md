daily report
================

## covid-19.rkt
## covid-19-sina-cn.rkt
## weather-forecast.rkt


<del>
主要为我家人发送手机短信通知每日新型肺炎统计报告而开发，该程序开发使用了 sina.cn（<del>或 www.tianqiapi.com </del>：[已移除](https://github.com/yanyingwang/2019-nCov-report/commit/693bf3746bde79063773c3db364327ba017b5d0b#diff-35f1a3a934ba13a4b17438067c7233fdL43)）提供的api，亦感谢之。

统计报告的内容为：
1. 全国病例报告、河南省病例报告、郑州市病理报告。
2. 2月27日增加了国内省份和国外国家确诊病例排名报告。
</del>

## Usage Example
clone this repo, cd in it, and then:

~~~racket
raco pkg install --auto

SENDER="abc@qq.com" RECIPIENT="edf@qq.com" AUTH_USER="abc" AUTH_PASSWD="abc-pswd" ./main.rkt
QWEATHER_API_KEY="the key" SENDER="name@qq.com" RECIPIENT_CM=“pn@139.com” AUTH_USER="name" AUTH_PASSWD="passwd" ./weather-forecast.rkt
~~~

You can check this repo's github action file as well for how I am using it to send a daily report email to myself.

