#!/usr/bin/env racket
#lang at-exp racket/base

(require racket/string racket/format racket/list racket/dict racket/runtime-path
         http-client qweather smtp gregor xml
         (file "private/parameters.rkt")
         (file "index.genhtml.rkt"))
(provide xpages)


(define (simplify-weather-text text1 text2)
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
     @~a{今天@(simplify-weather-text (hash-ref data/today 'textDay) (hash-ref data/today 'textNight))，气温@(hash-ref data/today 'tempMin)~@(hash-ref data/today 'tempMax)度，@(hash-ref data/today 'windDirDay)@(string-replace (hash-ref data/today 'windScaleDay) "-" "~")级；}
     @~a{日出于@(hash-ref data/today 'sunrise)，落于@(hash-ref data/today 'sunset)；}
     @~a{夜晚的一弯@(hash-ref data/today 'moonPhase)，出于@(hash-ref data/today 'moonrise)，落于@(hash-ref data/today 'moonset)。}))
  (define data/rest/processed
    (for/list ([d data/rest])
      (list @~a{@(substring (hash-ref d 'fxDate) 5 7)/@(substring (hash-ref d 'fxDate) 8 10)：}
            (simplify-weather-text (hash-ref d 'textDay) (hash-ref d 'textNight))，
            @~a{@(hash-ref d 'tempMin)~@(hash-ref d 'tempMax)度，}
            @~a{@(hash-ref data/today 'windDirDay)@(string-replace (hash-ref data/today 'windScaleDay) "-" "~")级。})))

  `(html
    (head
     (title @,~a{@|name|天气预报 - @(~t (now #:tz "Asia/Shanghai") "yyyy-MM-dd HH:mm")})
     (meta ((name "viewport") (content "width=device-width, initial-scale=0.9")))
     (style
         "body { background-color: linen; } .main { width: auto; padding-left: 10px; padding-right: 10px; } .row { padding-top: 10px; } .sssubtext { font-size: 80%; } .ssubtext { font-size: 90%; } .subtext { font-size: 95%; } h2 { margin-bottom: 6px; } p { margin-top: 6px; } ul { padding-left: 10px; } .responsive { width: 100%; height: auto; }"
       ))
    (body
     (div ((class "main"))
          (div
           (h1 @,~a{@|name|天气预报})
           (p ((class "ssubtext"))
              "作者：Yanying"
              (br)
              "数据来源：Qweather"
              (br)
              @,~a{更新日期：@(~t (now #:tz "Asia/Shanghai") "yyyy-MM-dd HH:mm")}
              (br)
              (a ((href "https://www.yanying.wang/daily-report")) "原连接")
              (entity 'nbsp)
              (a ((href "https://github.com/yanyingwang/daily-report")) "源代码")
              ))
          (div ((class "row"))
               (p
                ,(for/fold ([acc '(strong)] #:result (reverse acc))
                           ([i (string-split (string-join data/today/processed "") "")])
                   (case i
                     [("；") (list* '(br) i acc)]
                     [("雨" "雪") (list* `(span ((style "color:DarkOliveGreen")) ,i) acc)]
                     [else (list* i acc)]
                     )))
               (p ((class "sssubtext"))
                  ,(for/fold ([acc '(u)] #:result (reverse acc))
                           ([i (string-split (weather/24h/severe-weather-ai lid) "")])
                   (case i
                     [("；") (list* '(br) i acc)]
                     [("雨" "雪") (list* `(span ((style "color:DarkOliveGreen")) ,i) acc)]
                     [else (list* i acc)]
                     )))
               (p ((class "sssubtext"))
                  ,@(for/fold ([acc '()])
                              ([i (hash-ref (http-response-body (warning/now lid)) 'warning)])
                      (list* (hash-ref i 'title) '(br) (hash-ref i 'text) '(br) acc)
                      ))
               )

          (div ((class "row"))
               @,(for/fold ([acc '()] #:result (append '(ul ((class "subtext"))) (reverse acc)))
                           ([i data/rest/processed])
                   (cons
                    (for/fold ([acc '()] #:result (append '(li) (reverse acc)))
                              ([i (string-split (string-join i "") "")])
                      (cons
                       (if (or (string=? i "雨")
                               (string=? i "雪"))
                           `(span ((style "color:MidnightBlue")) ,i)
                           i)
                       acc))
                    acc)
                   )))))
  )


;; (require debug/repl)
;; (debug-repl)
(define (xpages)
  (for/hash ([(city lid) (in-dict lids)])
    (values city (gen-xpage city lid))))

(module+ main
  (define-runtime-path public "public")
  (for ([(city xexpr) (in-hash (xpages))])
    (define city.html @~a{@|public|/@|city|.html})
    (with-output-to-file city.html #:exists 'replace
      (lambda () (display (xexpr->string xexpr))))))
