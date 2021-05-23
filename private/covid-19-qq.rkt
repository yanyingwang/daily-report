#lang at-exp racket/base

(require covid-19/qq racket/list racket/format racket/provide)
(provide (matching-identifiers-out #rx"^(domestic|processed)\\/.*" (all-defined-out)))


(define henan (qq/get-region "河南"))
(define zhengzhou (qq/get-region "河南" "郑州"))
(define shanghai (qq/get-region "上海"))

(define domestic/top10
  (take (qq/sort+filter-by 'confirm 'today) 10))


(define processed/domestic/overall
  (cons "概览"
        (list @~a{全国今日新增确诊：@(hash-ref qq/data/china-add 'confirm)人，}
              @~a{全国今日治愈：@(hash-ref qq/data/china-add 'heal)人，}
              @~a{全国今日死亡：@(hash-ref qq/data/china-add 'dead)人。}
              @~a{河南今日新增确诊：@(qq/get-num* '河南)人，}
              @~a{其中郑州：@(qq/get-num* '河南 #:city '郑州)人。}
              @~a{上海今日新增确诊：@(qq/get-num* '上海)人， }
              @~a{其中境外输入：@(qq/get-num* '上海 #:city '境外输入)人。})))

(define processed/domestic/top10
  (cons "国内前十（新增确诊）"
        (for/list ([i domestic/top10])
          (define outbound-num (qq/get-num* (car i) #:city '境外输入))
          @~a{@(car i)：@(cdr i)（其中境外输入@(qq/get-num* (car i) #:city '境外输入)）人}
          #;(if (and (number? outbound-num)
                   (> outbound-num 0))
              @~a{@(car i)：@(cdr i)（其中境外输入@(qq/get-num* (car i) #:city '境外输入)）人}
              @~a{@(car i)：@(cdr i)人}))))
