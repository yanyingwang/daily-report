#lang at-exp racket/base

(require covid-19/sina racket/list racket/format racket/provide)
(provide (matching-identifiers-out #rx"^(foreign|processed)\\/.*" (all-defined-out)))


(define henan (findf (lambda (i) (equal? (hash-ref i 'name) "河南"))
                     sina/data/list))
(define zhengzhou (findf (lambda (i) (equal? (hash-ref i 'name) "郑州市"))
                         (hash-ref henan 'city)))
(define processed/domestic/overall1
  (cons "概览1"
        (list @~a{全国现有确诊：@(hash-ref sina/data 'econNum)人，}
              @~a{全国累计确诊：@(hash-ref sina/data 'gntotal)人，}
              @~a{全国现有疑似：@(hash-ref sina/data 'sustotal)人，}
              @~a{全国总已治愈：@(hash-ref sina/data 'curetotal)人，}
              @~a{全国总已死亡：@(hash-ref sina/data 'deathtotal)人。}
              @~a{河南现有确诊：@(hash-ref henan 'econNum)人，}
              @~a{河南累计确诊：@(hash-ref henan 'value)人，}
              @~a{河南总已治愈：@(hash-ref henan 'cureNum)人，}
              @~a{河南总已死亡：@(hash-ref henan 'deathNum)人。}
              @~a{郑州累积确诊：@(hash-ref zhengzhou 'conNum)人，}
              @~a{郑州总已治愈：@(hash-ref zhengzhou 'cureNum)人，}
              @~a{郑州总已死亡：@(hash-ref zhengzhou 'deathNum)人。})))


(define foreign/conadd/top10
  (take (sina/contries/sort+filter-by 'conadd) 10))
(define foreign/deathadd/top10
  (take (sina/contries/sort+filter-by 'deathadd) 10))
(define foreign/connum/top10
  (take (sina/contries/sort+filter-by 'conNum) 10))
(define foreign/deathnum/top10
  (take (sina/contries/sort+filter-by 'deathNum) 10))
(define processed/foreign/conadd/top10
  (cons "国外前十（新增确诊）"
        (for/list ([i foreign/conadd/top10])
          @~a{@(car i)：@(cdr i)人})))
(define processed/foreign/deathadd/top10
  (cons "国外前十（新增死亡）"
        (for/list ([i foreign/deathadd/top10])
          @~a{@(car i)：@(cdr i)人})))
(define processed/foreign/connum/top10
  (cons "国外前十（累积确诊）"
        (for/list ([i foreign/connum/top10])
          @~a{@(car i)：@(cdr i)人})))
(define processed/foreign/deathnum/top10
  (cons "国外前十（累积死亡）"
        (for/list ([i foreign/deathnum/top10])
          @~a{@(car i)：@(cdr i)人})))
