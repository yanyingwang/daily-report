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
(define zhengzhou (findf (lambda (i) (equal? (hash-ref i 'name) "郑州市"))
                         (hash-ref henan 'city)))


(define (sina/contries/filter-by column-name)
  (define sorted-contries
    (sort data/otherlist
          (lambda (i1 i2)
            (define v1 (hash-ref i1 'value))
            (define v2 (hash-ref i2 'value))
            (and (string=? v1 "-") (set! v1 "-1"))
            (and (string=? v2 "-") (set! v2 "-1"))
            (> (string->number v1)
               (string->number v2)))))
  (for/list ([i sorted-contries])
    (cons (hash-ref i 'name)
          (string->number (hash-ref i 'conNum)))))

(define sina/contries/connum
  (sina/contries/filter-by 'conNum))
(define sina/contries/conadd
  (sina/contries/filter-by 'conadd))
(define sina/contries/deathnum
  (sina/contries/filter-by 'deathNum))
(define sina/contries/deathadd
  (sina/contries/filter-by 'deathadd))



(define sina/domestic/overall
  (cons "概览1"
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

(define sina/foreign/top10/conadd
  (cons "国外新增前十（确诊）"
        (list  @~a{@(car (first sina/contries/conadd))：@(cdr (first sina/contries/conadd))人，}
               @~a{@(car (second sina/contries/conadd))：@(cdr (second sina/contries/conadd))人，}
               @~a{@(car (third sina/contries/conadd))：@(cdr (third sina/contries/conadd))人，}
               @~a{@(car (fourth sina/contries/conadd))：@(cdr (fourth sina/contries/conadd))人，}
               @~a{@(car (fifth sina/contries/conadd))：@(cdr (fifth sina/contries/conadd))人。}
               @~a{@(car (sixth sina/contries/conadd))：@(cdr (sixth sina/contries/conadd))人，}
               @~a{@(car (seventh sina/contries/conadd))：@(cdr (seventh sina/contries/conadd))人，}
               @~a{@(car (eighth sina/contries/conadd))：@(cdr (eighth sina/contries/conadd))人，}
               @~a{@(car (ninth sina/contries/conadd))：@(cdr (ninth sina/contries/conadd))人，}
               @~a{@(car (tenth sina/contries/conadd))：@(cdr (tenth sina/contries/conadd))人。}
               ))
  )

(define sina/foreign/top10/deathadd
  (cons "国外新增前十（死亡）"
        (list  @~a{@(car (first sina/contries/deathadd))：@(cdr (first sina/contries/deathadd))人，}
               @~a{@(car (second sina/contries/deathadd))：@(cdr (second sina/contries/deathadd))人，}
               @~a{@(car (third sina/contries/deathadd))：@(cdr (third sina/contries/deathadd))人，}
               @~a{@(car (fourth sina/contries/deathadd))：@(cdr (fourth sina/contries/deathadd))人，}
               @~a{@(car (fifth sina/contries/deathadd))：@(cdr (fifth sina/contries/deathadd))人。}
               @~a{@(car (sixth sina/contries/deathadd))：@(cdr (sixth sina/contries/deathadd))人，}
               @~a{@(car (seventh sina/contries/deathadd))：@(cdr (seventh sina/contries/deathadd))人，}
               @~a{@(car (eighth sina/contries/deathadd))：@(cdr (eighth sina/contries/deathadd))人，}
               @~a{@(car (ninth sina/contries/deathadd))：@(cdr (ninth sina/contries/deathadd))人，}
               @~a{@(car (tenth sina/contries/deathadd))：@(cdr (tenth sina/contries/deathadd))人。}
               ))
  )

(define sina/foreign/top10/connum
  (cons "国外累积前十（确诊）"
        (list  @~a{@(car (first sina/contries/connum))：@(cdr (first sina/contries/connum))人，}
               @~a{@(car (second sina/contries/connum))：@(cdr (second sina/contries/connum))人，}
               @~a{@(car (third sina/contries/connum))：@(cdr (third sina/contries/connum))人，}
               @~a{@(car (fourth sina/contries/connum))：@(cdr (fourth sina/contries/connum))人，}
               @~a{@(car (fifth sina/contries/connum))：@(cdr (fifth sina/contries/connum))人。}
               @~a{@(car (sixth sina/contries/connum))：@(cdr (sixth sina/contries/connum))人，}
               @~a{@(car (seventh sina/contries/connum))：@(cdr (seventh sina/contries/connum))人，}
               @~a{@(car (eighth sina/contries/connum))：@(cdr (eighth sina/contries/connum))人，}
               @~a{@(car (ninth sina/contries/connum))：@(cdr (ninth sina/contries/connum))人，}
               @~a{@(car (tenth sina/contries/connum))：@(cdr (tenth sina/contries/connum))人。}
               ))
  )

(define sina/foreign/top10/deathnum
  (cons "国外累积前十（死亡）"
        (list  @~a{@(car (first sina/contries/deathnum))：@(cdr (first sina/contries/deathnum))人，}
               @~a{@(car (second sina/contries/deathnum))：@(cdr (second sina/contries/deathnum))人，}
               @~a{@(car (third sina/contries/deathnum))：@(cdr (third sina/contries/deathnum))人，}
               @~a{@(car (fourth sina/contries/deathnum))：@(cdr (fourth sina/contries/deathnum))人，}
               @~a{@(car (fifth sina/contries/deathnum))：@(cdr (fifth sina/contries/deathnum))人。}
               @~a{@(car (sixth sina/contries/deathnum))：@(cdr (sixth sina/contries/deathnum))人，}
               @~a{@(car (seventh sina/contries/deathnum))：@(cdr (seventh sina/contries/deathnum))人，}
               @~a{@(car (eighth sina/contries/deathnum))：@(cdr (eighth sina/contries/deathnum))人，}
               @~a{@(car (ninth sina/contries/deathnum))：@(cdr (ninth sina/contries/deathnum))人，}
               @~a{@(car (tenth sina/contries/deathnum))：@(cdr (tenth sina/contries/deathnum))人。}
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
