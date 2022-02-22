#!/usr/bin/env racket
#lang at-exp racket/base

(require racket/string racket/format racket/list racket/dict racket/runtime-path xml)
(provide lids)

(define lids
  (list
   (cons "沈阳市" "101070101")
   (cons "北京市" "101010100")
   (cons "郑州市" "101180101")
   (cons "新郑市" "101180106")
   (cons "西安市" "101110101")
   (cons "成都市" "101270101")
   (cons "重庆市" "101040100")
   (cons "武汉市" "101200101")
   (cons "长沙市" "101250101")
   (cons "上海市" "101020100")
   (cons "杭州市" "101210101")
   (cons "广州市" "101280101")
   (cons "深圳市" "101280601")
   (cons "香港市" "101320101")
   (cons "澳门市" "101330101")
   (cons "福州市" "101230101")
   (cons "台北市" "101340101")
   ))

(define xpage
  `(html
    (head
     (title "daily report - index.html")
     (meta ((name "viewport") (content "width=device-width, initial-scale=0.8")))
     (style
         "body { background-color: linen; } .main { width: auto; padding-left: 10px; padding-right: 10px; } .row { padding-top: 10px; } .subtext { font-size: 90%; } h2 { margin-bottom: 6px; } p { margin-top: 6px; } ul { padding-left: 20px; } .responsive { width: 100%; height: auto; }"
       ))
    (body
     (div ((class "main"))
          (div ((class "subtext"))
               (h1  "Daily Report")
               (p "作者：Yanying"
                  (br)
                  "数据来源：Sina/QQ/Qweather"
                  (br)
                  (a ((href "https://github.com/yanyingwang/daily-report")) "源代码")
                  ))
          (div ((class "row"))
               (ul
                (li (strong ) (a ((href "covid-19.html")) "COVID-19病例统计"))
                (li (strong "城市天气预报：")
                    @,(let loop ([lst (dict-keys lids)]
                                 [result '(table )])
                        (if (< (length lst) 3)
                            (append result `((tr ,@(for/list ([i lst])
                                                     `(td (a ((href @,~a{@|i|.html})) ,i))))))
                            (loop (drop lst 3)
                                  (append result `((tr ,@(for/list ([i (take lst 3)])
                                             `(td (a ((href @,~a{@|i|.html})) ,i)))))))))

                    ))))))
  )

(module+ main
  (define-runtime-path index.html "public/index.html")
  (with-output-to-file index.html #:exists 'replace
    (lambda () (display (xexpr->string xpage)))))
