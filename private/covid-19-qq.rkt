#lang at-exp racket/base

(require covid-19/qq racket/list racket/string racket/format racket/provide)
(provide (matching-identifiers-out #rx"^(domestic|processed)\\/.*" (all-defined-out)))


(define henan (qq/get-region "河南"))
(define zhengzhou (qq/get-region "河南" "郑州"))
(define shanghai (qq/get-region "上海"))

(define domestic/top10
  (take (qq/sort+filter-by 'confirm 'today) 10))


(define processed/domestic/overall
  (cons "概览"
        (list @~a{全国今日新增确诊：@(hash-ref (qq/data/china-add) 'confirm)人，}
              @~a{全国今日治愈：@(hash-ref (qq/data/china-add) 'heal)人，}
              @~a{全国今日死亡：@(hash-ref (qq/data/china-add) 'dead)人。}
              @~a{河南今日新增确诊：@(qq/get-num* '河南)人，无症状@(qq/get-num* '河南 'wzz_add 'today)人。}
              @~a{其中郑州：@(qq/get-num* '河南 #:city '郑州)人。}
              @~a{上海今日新增确诊：@(qq/get-num* '上海)人，无症状@(qq/get-num* '上海 'wzz_add 'today)人，}
              @~a{其中境外输入：@(qq/get-num* '上海 #:city '境外输入)人。})))

(define processed/domestic/top10
  (cons "国内前十（新增确诊）"
        (for/list ([i domestic/top10])
          (define confirmed-inner-regions
            (for/list ([ii (hash-ref (qq/get-region (car i)) 'children)]
                       #:when (> (hash-ref (hash-ref ii 'today) 'confirm) 0))
              (cons (hash-ref ii 'name)
                    (hash-ref (hash-ref ii 'today) 'confirm))))
          (define extra-str
            (if (null? confirmed-inner-regions)
                ""
                (string-join (for/list ([r confirmed-inner-regions])
                               @~a{@(car r)@(cdr r)人})
                             #:before-first "（其中"
                             #:after-last "）"
                             "，")))
          @~a{@(car i)：确诊@(cdr i)人@|extra-str|，无症状@(qq/get-num* (car i) 'wzz_add 'today)人；})))
