#lang at-exp racket/base

(require racket/list racket/port racket/format racket/string racket/provide
         http-client json
         (file "parameters.rkt")
         (file "tools.rkt"))
(provide (matching-identifiers-out #rx"^qq\\/.*" (all-defined-out)))


;;; helper functions:
(define (get-province provinces province-name)
  (findf (lambda (i) (equal? (hash-ref i 'name) province-name))
         provinces))

(define (get-city province city-name)
  (findf (lambda (i) (equal? (hash-ref i 'name) city-name))
         (hash-ref province 'children)))

(define (get-outbound-income province)
  (get-city province "境外输入"))

(define (qq/get-outbound-income-count province)
  (define outbound-income (get-outbound-income province))
  (if outbound-income
      (hash-ref (hash-ref outbound-income 'today) 'confirm)
      #f))
(define (qq/get-local-count province)
  (define outbound-income (get-outbound-income province))
  (if outbound-income
      (- (hash-ref (hash-ref province 'today) 'confirm)
         (hash-ref (hash-ref outbound-income 'today) 'confirm))
      #f))



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
(define qq/provinces sorted-provinces)

(define henan (get-province provinces "河南"))
(define zhengzhou (get-city henan "郑州"))
(define shanghai (get-province provinces "上海"))



(define qq/overall/china
  (div-wrap "概览"
            (list @~a{全国今日新增确诊：@(hash-ref china-add 'confirm)人，}
                  @~a{全国今日治愈：@(hash-ref china-add 'heal)人，}
                  @~a{全国今日死亡：@(hash-ref china-add 'dead)人。}
                  @~a{河南今日新增确诊：@(hash-ref (hash-ref henan 'today) 'confirm)人，}
                  @~a{其中郑州：@(hash-ref (hash-ref zhengzhou 'today) 'confirm)人。}
                  @~a{上海今日新增确诊：@(hash-ref (hash-ref shanghai 'today) 'confirm)人， }
                  @~a{其中境外输入：@(hash-ref (hash-ref (get-outbound-income shanghai) 'today) 'confirm)人。}
                  ))
  )


(define qq/top10/china
  (div-wrap "国内新增前十"
            (list @~a{@(hash-ref (first sorted-provinces) 'name)：@(hash-ref (hash-ref (first sorted-provinces) 'today) 'confirm)（其中本土病例@(qq/get-local-count (first sorted-provinces))）人，}
                  @~a{@(hash-ref (second sorted-provinces) 'name)：@(hash-ref (hash-ref (second sorted-provinces) 'today) 'confirm)（其中本土病例@(qq/get-local-count (second sorted-provinces))）人，}
                  @~a{@(hash-ref (third sorted-provinces) 'name)：@(hash-ref (hash-ref (third sorted-provinces) 'today) 'confirm)（其中本土病例@(qq/get-local-count (third sorted-provinces))）人，}
                  @~a{@(hash-ref (fourth sorted-provinces) 'name)：@(hash-ref (hash-ref (fourth sorted-provinces) 'today) 'confirm)（其中本土病例@(qq/get-local-count (fourth sorted-provinces))）人，}
                  @~a{@(hash-ref (fifth sorted-provinces) 'name)：@(hash-ref (hash-ref (fifth sorted-provinces) 'today) 'confirm)（其中本土病例@(qq/get-local-count (fifth sorted-provinces))）人。}
                  @~a{@(hash-ref (sixth sorted-provinces) 'name)：@(hash-ref (hash-ref (sixth sorted-provinces) 'today) 'confirm)（其中本土病例@(qq/get-local-count (sixth sorted-provinces))）人，}
                  @~a{@(hash-ref (seventh sorted-provinces) 'name)：@(hash-ref (hash-ref (seventh sorted-provinces) 'today) 'confirm)（其中本土病例@(qq/get-local-count (seventh sorted-provinces))）人，}
                  @~a{@(hash-ref (eighth sorted-provinces) 'name)：@(hash-ref (hash-ref (eighth sorted-provinces) 'today) 'confirm)（其中本土病例@(qq/get-local-count (eighth sorted-provinces))）人，}
                  @~a{@(hash-ref (ninth sorted-provinces) 'name)：@(hash-ref (hash-ref (ninth sorted-provinces) 'today) 'confirm)（其中本土病例@(qq/get-local-count (ninth sorted-provinces))）人，}
                  @~a{@(hash-ref (tenth sorted-provinces) 'name)：@(hash-ref (hash-ref (tenth sorted-provinces) 'today) 'confirm)（其中本土病例@(qq/get-local-count (tenth sorted-provinces))）人。}
                  ))
  )
