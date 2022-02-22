#!/usr/bin/env racket
#lang at-exp racket/base

(require racket/string racket/format racket/list racket/runtime-path
         http-client qweather smtp gregor xml
         (file "private/parameters.rkt"))
(provide xpages)

(define lids
  (hash
   '沈阳市 "101070101"
   '北京市 "101010100"
   '郑州市 "101180101"
   '新郑市 "101180106"
   '西安市 "101110101"
   '成都市 "101270101"
   '重庆市 "101040100"
   '武汉市 "101200101"
   '长沙市 "101250101"
   '上海市 "101020100"
   '杭州市 "101210101"
   '广州市 "101280101"
   '深圳市 "101280601"
   '香港市 "101320101"
   '澳门市 "101330101"
   '福州市 "101230101"
   '台北市 "101340101"
   ))


(define (gen-weather-single-text text1 text2)
  (if (string=? text1 text2)
      text1
      @~a{@|text1|转@text2}))

(define (gen-xpage name lid)
  (define result
    (http-response-body (weather/15d lid)))
  (define data
    (hash-ref result 'daily))
  (define data/today
    (car (hash-ref result 'daily)))
  (define data/rest
    (drop (hash-ref result 'daily) 1))
  (define data/today/processed
    (list
     @~a{今天@(gen-weather-single-text (hash-ref data/today 'textDay) (hash-ref data/today 'textNight))，气温@(hash-ref data/today 'tempMin)~@(hash-ref data/today 'tempMax)度，@(hash-ref data/today 'windDirDay)@(string-replace (hash-ref data/today 'windScaleDay) "-" "~")级；}
     @~a{日出于@(hash-ref data/today 'sunrise)，落于@(hash-ref data/today 'sunset)；}
     @~a{夜晚的一弯@(hash-ref data/today 'moonPhase)，出于@(hash-ref data/today 'moonrise)，落于@(hash-ref data/today 'moonset)。}))
  (define data/rest/processed
    (for/list ([d data/rest])
      (list @~a{@(substring (hash-ref d 'fxDate) 5 7)/@(substring (hash-ref d 'fxDate) 8 10)：}
            @~a{@(hash-ref d 'textDay)转@(hash-ref d 'textNight)，}
            @~a{@(hash-ref d 'tempMin)~@(hash-ref d 'tempMax)度，}
            @~a{@(hash-ref data/today 'windDirDay)@(string-replace (hash-ref data/today 'windScaleDay) "-" "~")级。})))

  `(html
    (head
     (title @,~a{@|name|天气预报 - @(~t (now #:tz "Asia/Shanghai") "yyyy-MM-dd HH:mm")})
     (meta ((name "viewport") (content "width=device-width, initial-scale=0.8")))
     (style
         "body { background-color: linen; } .main { width: auto; padding-left: 10px; padding-right: 10px; } .row { padding-top: 10px; } .subtext { font-size: 90%; } h2 { margin-bottom: 6px; } p { margin-top: 6px; } ul { padding-left: 20px; } .responsive { width: 100%; height: auto; }"
       ))
    (body
     (div ((class "main"))
          (div ((class "subtext"))
               (h1 @,~a{@|name|天气预报})
               (p "作者：Yanying"
                  (br)
                  "数据来源：Qweather"
                  (br)
                  @,~a{更新日期：@(~t (now #:tz "Asia/Shanghai") "yyyy-MM-dd HH:mm")}
                  (br)
                  (a ((href @,~a{https://www.yanying.wang/daily-report/@|name|.html} )) "原连接")
                  (entity 'nbsp)
                  (a ((href "https://github.com/yanyingwang/daily-report")) "源代码")
                  ))
          (div ((class "row"))
               ,@(add-between
                  (for/list ([i data/today/processed])
                    (list* 'strong
                           (for/list ([ii (string-split i "")])
                             (if (or (string=? ii "雨")
                                     (string=? ii "雪"))
                                 `(span ((style "color:red")) ,ii)
                                 ii))))
                  '(br)))
          (div
           (ul
            ,@(for/list ([i data/rest/processed])
                (list* 'li
                       (for/list ([i (string-split (string-join i "") "")])
                         (if (or (string=? i "雨")
                                 (string=? i "雪"))
                             `(span ((style "color:red")) ,i)
                             i)))))))))
  )


;; (require debug/repl)
;; (debug-repl)
(define (xpages)
  (for/hash ([(city lid) (in-hash lids)])
    (values city (gen-xpage city lid))))

(module+ main
  (define-runtime-path public "public")
  (for ([(city xexpr) (in-hash (xpages))])
    (define city.html @~a{@|public|/@|city|.html})
    (with-output-to-file city.html #:exists 'replace
      (lambda () (display (xexpr->string xexpr))))))
