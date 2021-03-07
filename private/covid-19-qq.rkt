#lang at-exp racket/base

(require racket/list racket/port racket/format racket/string racket/provide
         http-client json
         (file "parameters.rkt"))
(provide (matching-identifiers-out #rx"^qq\\/.*" (all-defined-out)))

(define res
  (http-get "https://view.inews.qq.com"
            #:path "/g2/getOnsInfo"
            #:data (hasheq 'name "disease_h5")))
(define data
  (string->jsexpr (hash-ref (http-response-body res) 'data)))

(define china-total (hash-ref data 'chinaTotal))
(define china-add (hash-ref data 'chinaAdd))

(define provinces (hash-ref (car (hash-ref data 'areaTree)) 'children))
(define sorted-provinces ;; by-daily-added
  (sort provinces (lambda (i1 i2)
                    (> (hash-ref (hash-ref i1 'today) 'confirm)
                       (hash-ref (hash-ref i2 'today) 'confirm)))))

(define henan (findf (lambda (i) (equal? (hash-ref i 'name) "河南"))
                     provinces))
(define cities-of-henan (hash-ref henan 'children))
(define zhengzhou (findf (lambda (i) (equal? (hash-ref i 'name) "郑州"))
                         cities-of-henan))

(define shanghai (findf (lambda (i) (equal? (hash-ref i 'name) "上海"))
                     provinces))
(define areas-of-shanghai (hash-ref shanghai 'children))
(define sh-aboard (findf (lambda (i) (equal? (hash-ref i 'name) "境外输入"))
                         areas-of-shanghai))




(define qq/overall/china
  @~a{
      <概览>
      全国今日新增确诊：@(hash-ref china-add 'confirm)人，
      全国今日治愈：@(hash-ref china-add 'heal)人，
      全国今日死亡：@(hash-ref china-add 'dead)人。
      河南今日新增确诊：@(hash-ref (hash-ref henan 'today) 'confirm)人，其中郑州：@(hash-ref (hash-ref zhengzhou 'today) 'confirm)人。
      上海今日新增确诊：@(hash-ref (hash-ref shanghai 'today) 'confirm)人， 其中境外输入：@(hash-ref (hash-ref sh-aboard 'today) 'confirm)人。
      })

(define qq/top10/china
  @~a{
      <国内新增前十>
      @(hash-ref (first sorted-provinces) 'name)：@(hash-ref (hash-ref (first sorted-provinces) 'today) 'confirm)人，
      @(hash-ref (second sorted-provinces) 'name)：@(hash-ref (hash-ref (second sorted-provinces) 'today) 'confirm)人，
      @(hash-ref (third sorted-provinces) 'name)：@(hash-ref (hash-ref (third sorted-provinces) 'today) 'confirm)人，
      @(hash-ref (fourth sorted-provinces) 'name)：@(hash-ref (hash-ref (fourth sorted-provinces) 'today) 'confirm)人，
      @(hash-ref (fifth sorted-provinces) 'name)：@(hash-ref (hash-ref (fifth sorted-provinces) 'today) 'confirm)人，
      @(hash-ref (sixth sorted-provinces) 'name)：@(hash-ref (hash-ref (sixth sorted-provinces) 'today) 'confirm)人。
      @(hash-ref (seventh sorted-provinces) 'name)：@(hash-ref (hash-ref (seventh sorted-provinces) 'today) 'confirm)人。
      @(hash-ref (eighth sorted-provinces) 'name)：@(hash-ref (hash-ref (eighth sorted-provinces) 'today) 'confirm)人。
      @(hash-ref (ninth sorted-provinces) 'name)：@(hash-ref (hash-ref (ninth sorted-provinces) 'today) 'confirm)人。
      @(hash-ref (tenth sorted-provinces) 'name)：@(hash-ref (hash-ref (tenth sorted-provinces) 'today) 'confirm)人。
      })

