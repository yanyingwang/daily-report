#!/usr/bin/env racket
#lang at-exp racket/base

(require racket/string racket/format racket/list racket/dict xml
         (only-in (file "private/helpers.rkt") public lids))

(define xpage
  `(html
    (head
     (title "daily report - index.html")
     (meta ((name "viewport") (content "width=device-width, initial-scale=1")))
     (style
         "body { background-color: linen; } .main { width: auto; padding-left: 10px; padding-right: 10px; } .row { padding-top: 10px; } .ssubtext { font-size: 80%; } .subtext { font-size: 90%; } h2 { margin-bottom: 6px; } p { margin-top: 6px; } ul { padding-left: 20px; } .responsive { width: 100%; height: auto; }"
       ))
    (body
     (div ((class "main"))
          (div (h1  "Daily Report")
               (p ((class "ssubtext"))
                  "作者：Yanying"
                  (br)
                  "数据来源：Sina/QQ/Qweather"
                  (br)
                  (a ((href "https://www.yanying.wang/daily-report")) "原连接")
                  (entity 'nbsp)
                  (a ((href "https://github.com/yanyingwang/daily-report")) "源代码")
                  ))
          (div ((class "row"))
               (p (a ((href "covid-19.html")) "<COVID-19病例统计>"))
               (p (strong "城市天气预报：")
                  (br)
                  (strong (a ((class "subtext" ) (href "新郑市.html")) "河南省郑州市新郑"))
                  (br)
                  @,(let loop ([lst (drop-right (dict-keys lids) 1)]
                               [result '(table ((style "width:80%")) )])
                      (if (< (length lst) 4)
                          (append result `((tr ,@(for/list ([i lst])
                                                   `(td ((style "width:20%")) (a ((class "subtext" )(href @,~a{@|i|.html})) ,i))))))
                          (loop (drop lst 4)
                                (append result `((tr ,@(for/list ([i (take lst 4)])
                                                         `(td ((style "width:20%")) (a ((class "subtext") (href @,~a{@|i|.html})) ,i)))))))))

                  )))))
  )

(module+ main
  (with-output-to-file  @~a{@|public|/index.html} #:exists 'replace
    (lambda () (display (xexpr->string xpage)))))
