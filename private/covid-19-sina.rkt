#lang at-exp racket/base

(require racket/list racket/port racket/format racket/string racket/provide
         http-client json
         (file "parameters.rkt")
         (file "tools.rkt"))
(provide (matching-identifiers-out #rx"^sina\\/.*" (all-defined-out)))


;;;; sina.cn api
(define res
  (http-get "https://interface.sina.cn"
            #:path "news/wap/fymap2020_data.d.json"))

(define data (hash-ref (http-response-body res) 'data))
(define data/list (hash-ref data 'list))
(define data/otherlist (hash-ref data 'otherlist))

;;;;;;;
(define henan (findf (lambda (i) (equal? (hash-ref i 'name) "河南"))
                     data/list))
(define city (hash-ref henan 'city))
(define zhengzhou (findf (lambda (i) (equal? (hash-ref i 'name) "郑州市"))
                         city))


(define sorted-c (sort data/otherlist (lambda (i1 i2) ; countries except china
                                   (> (string->number (hash-ref i1 'value))
                                      (string->number (hash-ref i2 'value))))))
(define daily-c (map (lambda (i) (hash 'name (hash-ref i 'name)
                                  'value (hash-ref i 'conadd))) data/otherlist))
(define sorted-daily-c (sort daily-c (lambda (i1 i2)
                                       (define v1 (hash-ref i1 'value))
                                       (define v2 (hash-ref i2 'value))
                                       (and (string=? v1 "-") (set! v1 "-1"))
                                       (and (string=? v2 "-") (set! v2 "-1"))
                                       (> (string->number v1)
                                          (string->number v2)))))
(define sina/contries sorted-c)
(define sina/contries/today sorted-daily-c)


;; 新型肺炎今日概览报告
(define sina/overall/china
  (div-wrap "概览1"
            (list @~a{全国现有确诊：@(hash-ref data 'econNum)人，}
                  @~a{全国累计确诊：@(hash-ref data 'gntotal)人，}
                  @~a{全国现有疑似：@(hash-ref data 'sustotal)人，}
                  @~a{全国总已治愈：@(hash-ref data 'curetotal)人，}
                  @~a{全国总已死亡：@(hash-ref data 'deathtotal)人。}
                  @~a{河南现有确诊：@(hash-ref henan 'econNum)人，}
                  @~a{河南累计确诊：@(hash-ref henan 'value)人，}
                  @~a{河南总已治愈：@(hash-ref henan 'cureNum)人，}
                  @~a{河南总已死亡：@(hash-ref henan 'deathNum)人。}
                  @~a{郑州累积确诊：@(hash-ref zhengzhou 'conNum)人，}
                  @~a{郑州总已治愈：@(hash-ref zhengzhou 'cureNum)人，}
                  @~a{郑州总已死亡：@(hash-ref zhengzhou 'deathNum)人。}
                  ))
  )

;; 新型肺炎今日总计排名报告
(define sina/top5/foreign
  (div-wrap "国外累积前十"
            (list  @~a{@(hash-ref (first sorted-c) 'name)：@(hash-ref (first sorted-c) 'value)人，}
                   @~a{@(hash-ref (second sorted-c) 'name)：@(hash-ref (second sorted-c) 'value)人，}
                   @~a{@(hash-ref (third sorted-c) 'name)：@(hash-ref (third sorted-c) 'value)人，}
                   @~a{@(hash-ref (fourth sorted-c) 'name)：@(hash-ref (fourth sorted-c) 'value)人，}
                   @~a{@(hash-ref (fifth sorted-c) 'name)：@(hash-ref (fifth sorted-c) 'value)人。}
                   @~a{@(hash-ref (sixth sorted-c) 'name)：@(hash-ref (sixth sorted-c) 'value)人，}
                   @~a{@(hash-ref (seventh sorted-c) 'name)：@(hash-ref (seventh sorted-c) 'value)人，}
                   @~a{@(hash-ref (eighth sorted-c) 'name)：@(hash-ref (eighth sorted-c) 'value)人，}
                   @~a{@(hash-ref (ninth sorted-c) 'name)：@(hash-ref (ninth sorted-c) 'value)人，}
                   @~a{@(hash-ref (tenth sorted-c) 'name)：@(hash-ref (tenth sorted-c) 'value)人。}
                   ))
  )

(define sina/top5/today/foreign
  (div-wrap "国外新增前十"
            (list  @~a{@(hash-ref (first sorted-daily-c) 'name)：@(hash-ref (first sorted-daily-c) 'value)人，}
                   @~a{@(hash-ref (second sorted-daily-c) 'name)：@(hash-ref (second sorted-daily-c) 'value)人，}
                   @~a{@(hash-ref (third sorted-daily-c) 'name)：@(hash-ref (third sorted-daily-c) 'value)人，}
                   @~a{@(hash-ref (fourth sorted-daily-c) 'name)：@(hash-ref (fourth sorted-daily-c) 'value)人，}
                   @~a{@(hash-ref (fifth sorted-daily-c) 'name)：@(hash-ref (fifth sorted-daily-c) 'value)人。}
                   @~a{@(hash-ref (sixth sorted-daily-c) 'name)：@(hash-ref (sixth sorted-daily-c) 'value)人，}
                   @~a{@(hash-ref (seventh sorted-daily-c) 'name)：@(hash-ref (seventh sorted-daily-c) 'value)人，}
                   @~a{@(hash-ref (eighth sorted-daily-c) 'name)：@(hash-ref (eighth sorted-daily-c) 'value)人，}
                   @~a{@(hash-ref (ninth sorted-daily-c) 'name)：@(hash-ref (ninth sorted-daily-c) 'value)人，}
                   @~a{@(hash-ref (tenth sorted-daily-c) 'name)：@(hash-ref (tenth sorted-daily-c) 'value)人。}
                   ))
  )








;;;;;;;
#;(define sorted-p (sort data/list (lambda (i1 i2) ; provinces of china
                              (> (string->number (hash-ref i1 'value))
                                 (string->number (hash-ref i2 'value))))))
#;(define daily-p (map (lambda (i) (hash 'name (hash-ref i 'name)
                                   'value (hash-ref (hash-ref i 'adddaily) 'conadd_n))) data/list))
#;(define sorted-daily-p (sort daily-p (lambda (i1 i2)
                                       (define v1 (hash-ref i1 'value))
                                       (define v2 (hash-ref i2 'value))
                                       (and (string? v1) (set! v1 -1))
                                       (and (string? v2) (set! v2 -1))
                                       (> v1 v2))))

#;(define sina/top5/china
  (div-wrap "国内累积前十"
            (list @~a{@(hash-ref (first sorted-p) 'name)：@(hash-ref (first sorted-p) 'value)人，}
                  @~a{@(hash-ref (second sorted-p) 'name)：@(hash-ref (second sorted-p) 'value)人，}
                  @~a{@(hash-ref (third sorted-p) 'name)：@(hash-ref (third sorted-p) 'value)人，}
                  @~a{@(hash-ref (fourth sorted-p) 'name)：@(hash-ref (fourth sorted-p) 'value)人，}
                  @~a{@(hash-ref (fifth sorted-p) 'name)：@(hash-ref (fifth sorted-p) 'value)人。}
                  @~a{@(hash-ref (sixth sorted-p) 'name)：@(hash-ref (sixth sorted-p) 'value)人，}
                  @~a{@(hash-ref (seventh sorted-p) 'name)：@(hash-ref (seventh sorted-p) 'value)人，}
                  @~a{@(hash-ref (eighth sorted-p) 'name)：@(hash-ref (eighth sorted-p) 'value)人，}
                  @~a{@(hash-ref (ninth sorted-p) 'name)：@(hash-ref (ninth sorted-p) 'value)人，}
                  @~a{@(hash-ref (tenth sorted-p) 'name)：@(hash-ref (tenth sorted-p) 'value)人。}
                  ))
  )

#;(define sina/top5/today/china
  (div-wrap "国内新增前十"
            (list @~a{@(hash-ref (first sorted-daily-p) 'name)：@(hash-ref (first sorted-daily-p) 'value)人，}
                  @~a{@(hash-ref (second sorted-daily-p) 'name)：@(hash-ref (second sorted-daily-p) 'value)人，}
                  @~a{@(hash-ref (third sorted-daily-p) 'name)：@(hash-ref (third sorted-daily-p) 'value)人，}
                  @~a{@(hash-ref (fourth sorted-daily-p) 'name)：@(hash-ref (fourth sorted-daily-p) 'value)人，}
                  @~a{@(hash-ref (fifth sorted-daily-p) 'name)：@(hash-ref (fifth sorted-daily-p) 'value)人。}
                  @~a{@(hash-ref (sixth sorted-daily-p) 'name)：@(hash-ref (sixth sorted-daily-p) 'value)人，}
                  @~a{@(hash-ref (seventh sorted-daily-p) 'name)：@(hash-ref (seventh sorted-daily-p) 'value)人，}
                  @~a{@(hash-ref (eighth sorted-daily-p) 'name)：@(hash-ref (eighth sorted-daily-p) 'value)人，}
                  @~a{@(hash-ref (ninth sorted-daily-p) 'name)：@(hash-ref (ninth sorted-daily-p) 'value)人，}
                  @~a{@(hash-ref (tenth sorted-daily-p) 'name)：@(hash-ref (tenth sorted-daily-p) 'value)人。}
                  ))
  )
