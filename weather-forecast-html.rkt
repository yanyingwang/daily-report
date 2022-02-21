#!/usr/bin/env racket
#lang at-exp racket/base

(require racket/string racket/format racket/list racket/runtime-path
         http-client qweather smtp gregor xml
         (file "private/parameters.rkt"))
(provide xpage xpage/string)

(define-runtime-path wf-xinzheng.html "public/wf-xinzheng.html")

(define lid "101180106") ;;henan xinzheng
;; (define lid "101020100") ;;shanghai

(define result
  (http-response-body (weather/15d lid)))
(define data
  (hash-ref result 'daily))
(define data/filtered
  (for/list ([d data])
    (list @~a{@(hash-ref d 'fxDate)：}
          @~a{@(hash-ref d 'textDay)转@(hash-ref d 'textNight)，}
          @~a{@(hash-ref d 'tempMin)~@(hash-ref d 'tempMax)度，}
          @~a{@(hash-ref d 'windDirDay)转@(hash-ref d 'windDirNight)@(string-replace (hash-ref d 'windScaleDay) "-" "~")到@(string-replace (hash-ref d 'windScaleNight) "-" "~")级，}
          @~a{日出于@(hash-ref d 'sunrise)落于@(hash-ref d 'sunset)，}
          @~a{@(hash-ref d 'moonPhase)出于@(hash-ref d 'moonrise)落于@(hash-ref d 'moonset)。})
    )
  )


(define xpage
  `(html
    (head
     (title @,~a{新郑市天气预报 - @(~t (now #:tz "Asia/Shanghai") "yyyy-MM-dd HH:mm")})
     (meta ((name "viewport") (content "width=device-width, initial-scale=0.8")))
     (style
         "body { background-color: linen; } .main { width: auto; padding-left: 10px; padding-right: 10px; } .row { padding-top: 10px; } .text { padding-left: 30px; } h2 { margin-bottom: 6px; } p { margin-top: 6px; } .responsive { width: 100%; height: auto; }"
         ))
    (body
     (div ((class "main"))
          (div ((class "text"))
               (h1 "新郑市天气预报")
               (p "作者：Yanying"
                  (br)
                  "数据来源：Qweather"
                  (br)
                  @,~a{更新日期：@(~t (now #:tz "Asia/Shanghai") "yyyy-MM-dd HH:mm")}
                  (br)
                  (a ((href "https://www.yanying.wang/daily-report")) "原连接")
                  (entity 'nbsp)
                  (a ((href "https://github.com/yanyingwang/daily-report")) "源代码")
))
          (div ((class "text"))
               (ul
                ,@(for/list ([i data/filtered])
                   (list 'li (string-join i ""))))
               )
          ))))


;; (require debug/repl)
;; (debug-repl)

(define xpage/string (xexpr->string xpage))
(define (output-to-file)
  (with-output-to-file wf-xinzheng.html #:exists 'replace
    (lambda () (display xpage/string))))

(module+ main
  (with-handlers
      ([exn:fail:contract?
        (lambda (v)
          ((error-display-handler) (exn-message v) v))])
    (output-to-file)))
