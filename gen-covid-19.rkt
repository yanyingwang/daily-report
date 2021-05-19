#!/usr/bin/env racket
#lang racket/base

(require racket/string racket/list racket/runtime-path
         xml plot/no-gui
         (file "private/covid-19-qq.rkt")
         (file "private/covid-19-sina.rkt"))

;; colors
;; file:///Applications/Racket%20v8.0/doc/draw/color-database___.html

;; histogram
;; file:///Applications/Racket%20v8.0/doc/plot/renderer2d.html?q=histogram#(def._((lib._plot%2Fmain..rkt)._discrete-histogram))


(plot-width 600)
(define-runtime-path index.html "public/index.html")
(define-runtime-path domestic.jpeg "public/domestic.jpeg")
(define-runtime-path foreign-today.jpeg "public/foreign-today.jpeg")
(define-runtime-path foreign-aggregate.jpeg "public/foreign-aggreate.jpeg")


(define data/domestic
  (for/list ([p (take qq/provinces 10)])
    (vector  (hash-ref p 'name)
             (hash-ref (hash-ref p 'today) 'confirm))))
(define data/domestic/local
  (for/list ([p (take qq/provinces 10)])
    (vector (hash-ref p 'name)
            (qq/get-local-count p))))
(define data/domestic/abroad
  (for/list ([p (take qq/provinces 10)])
    (vector (hash-ref p 'name)
            (qq/get-outbound-income-count p))))

(define data/foreign/today
  (for/list ([i (take sina/contries/today 10)])
    (vector (hash-ref i 'name)
            (string->number (hash-ref i 'value)))))
(define data/foreign/aggregate
  (for/list ([i (take sina/contries 10)])
    (vector (hash-ref i 'name)
            (string->number (hash-ref i 'value)))))


(plot-file (list (discrete-histogram data/domestic
                                     #:color "navy"
                                     #:line-color "navy"
                                     #:label "全部")
                 (discrete-histogram data/domestic/local
                                     #:color "red"
                                     #:line-color "red"
                                     #:label "本土")
                 (discrete-histogram data/domestic/abroad
                                     #:color "yellow"
                                     #:line-color "yellow"
                                     #:label "境外输入"))
           domestic.jpeg
           #:x-label "省份名"
           #:y-label "确诊人数"
           #:title "统计报表（国内今日新增）")


(plot-file (discrete-histogram data/foreign/today
                               #:color "navy"
                               #:line-color "black")
           foreign-today.jpeg
           #:x-label "国家名"
           #:y-label "确诊人数"
           #:title "统计报表（国外今日）")


(plot-file (discrete-histogram data/foreign/aggregate
                               #:color "navy"
                               #:line-color "black")
           foreign-aggregate.jpeg
           #:x-label "国家名"
           #:y-label "确诊人数"
           #:title "统计报表（国外累计）")




(define xpage
  `(html
    (body
     (div ((class "main"))
          (h1 "this is a test")
          (img ((src "./domestic.jpeg")))))))


(require debug/repl)
(debug-repl)


;; (xexpr->string xpage)
(with-output-to-file index.html
    (lambda () (printf (xexpr->string xpage))))
