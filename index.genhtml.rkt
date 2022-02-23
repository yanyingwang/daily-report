#!/usr/bin/env racket
#lang at-exp racket/base

(require racket/string racket/format racket/list racket/dict racket/runtime-path xml)
(provide lids)

;; (define a (list "新郑" "北京" "哈尔滨" "长春" "沈阳" "天津" "呼和浩特" "乌鲁木齐" "银川" "西宁" "兰州" "西安" "拉萨" "成都" "重庆" "贵阳" "昆明" "太原" "石家庄" "济南" "郑州" "合肥" "南京" "上海" "武汉" "长沙" "南昌" "杭州" "福州" "台北" "南宁" "海口" "广州" "香港" "澳门" "深圳" "厦门" "宁波" "青岛" "大连" "桂林" "汕头" "连云港" "秦皇岛" "延安" "赣州" "三亚" "高雄" "钓鱼岛"))
;; (for/list ([i a]) (cons i (hash-ref (first (hash-ref (http-response-body (city/lookup i)) 'location)) 'id)))
(define lids
  '(("北京" . "101010100")
    ("哈尔滨" . "101050101")
    ("长春" . "101060101")
    ("沈阳" . "101070101")
    ("天津" . "101030100")
    ("呼和浩特" . "101080101")
    ("乌鲁木齐" . "101130101")
    ("银川" . "101170101")
    ("西宁" . "101150101")
    ("兰州" . "101160101")
    ("西安" . "101110101")
    ("拉萨" . "101140101")
    ("成都" . "101270101")
    ("重庆" . "101040100")
    ("贵阳" . "101260101")
    ("昆明" . "101290101")
    ("太原" . "101100101")
    ("石家庄" . "101090101")
    ("济南" . "101120101")
    ("郑州" . "101180101")
    ("合肥" . "101220101")
    ("南京" . "101190101")
    ("上海" . "101020100")
    ("武汉" . "101200101")
    ("长沙" . "101250101")
    ("南昌" . "101240101")
    ("杭州" . "101210101")
    ("福州" . "101230101")
    ("台北" . "101340101")
    ("南宁" . "101300101")
    ("海口" . "101310101")
    ("广州" . "101280101")
    ("香港" . "101320101")
    ("澳门" . "101330101")
    ("深圳" . "101280601")
    ("厦门" . "101230201")
    ("宁波" . "101210401")
    ("青岛" . "101120201")
    ("大连" . "101070201")
    ("桂林" . "101300501")
    ("汕头" . "101280501")
    ("连云港" . "101191001")
    ("秦皇岛" . "101091101")
    ("延安" . "101110300")
    ("赣州" . "101240701")
    ("三亚" . "101310201")
    ("高雄" . "101340201")
    ("钓鱼岛" . "101231001")
    ("新郑市" . "101180106")
    ))


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
               (p (strong (a ((href "covid-19.html")) "COVID-19病例统计:")))
               (p (strong "城市天气预报：")
                  (br)
                  @,(let loop ([lst (dict-keys lids)]
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
  (define-runtime-path index.html "public/index.html")
  (with-output-to-file index.html #:exists 'replace
    (lambda () (display (xexpr->string xpage)))))
