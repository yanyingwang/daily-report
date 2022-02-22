daily report
================
https://www.yanying.wang/daily-report/


## covid-19
covid-19的图表统计数据，以及给予github action的邮件通知功能。

统计报告的内容为：
1. 全国病例报告、河南省病例报告、郑州市病理报告、上海市病理报告。
2. 国内省份和国外国家确诊病例排名报告。
3. 国外病例统计数据。
等。


## weather-forecast
中国城市天气预报，以及每日天气预报邮件通知和异常天气提醒功能。


## Usage Example
clone this repo, cd in it, and then:

~~~racket
raco pkg install --auto

SENDER="abc@qq.com" RECIPIENT="edf@qq.com" AUTH_USER="abc" AUTH_PASSWD="abc-pswd" ./covid-19.rkt
QWEATHER_API_KEY="the key" SENDER="name@qq.com" RECIPIENT_CM=“pn@139.com” AUTH_USER="name" AUTH_PASSWD="passwd" ./weather-forecast.rkt
~~~

You can check this repo's github action file as well for how I am using it to send a daily report email to myself.



