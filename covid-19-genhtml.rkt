#!/usr/bin/env racket
#lang at-exp racket/base

(require racket/string racket/list racket/runtime-path racket/format
         covid-19/qq xml plot/no-gui gregor
         (file "private/covid-19-qq.rkt")
         (file "private/covid-19-sina.rkt")
         (file "private/tools.rkt"))
(provide xpage xpage/string)

;; colors
;; file:///Applications/Racket%20v8.0/doc/draw/color-database___.html
;; histogram
;; file:///Applications/Racket%20v8.0/doc/plot/renderer2d.html?q=histogram#(def._((lib._plot%2Fmain..rkt)._discrete-histogram))


(define-runtime-path index.html "public/index.html")
(define-runtime-path domestic.jpeg "public/domestic.jpeg")
(define-runtime-path foreign-conadd.jpeg "public/foreign-conadd.jpeg")
(define-runtime-path foreign-deathadd.jpeg "public/foreign-deathadd.jpeg")
(define-runtime-path foreign-connum.jpeg "public/foreign-connum.jpeg")
(define-runtime-path foreign-deathnum.jpeg "public/foreign-deathnum.jpeg")


(define plot/domestic/unconfirmed
  (->plot-format
   (for/list ([i domestic/top10])
     (cons (car i)
           (qq/get-num* (car i) #:city '地区待确认)))))

(define plot/domestic/outincome
  (->plot-format (for/list ([i domestic/top10])
                   (cons (car i)
                         (qq/get-num* (car i) #:city '境外输入)))))

(define (cal-local-today-confirmed-num province)
  (for/sum ([i (hash-ref (qq/get-region province) 'children)]
            #:when (and (not (string=? (hash-ref i 'name) "地区待确认"))
                        (not (string=? (hash-ref i 'name) "境外输入"))))
    (hash-ref (hash-ref i 'today) 'confirm)))

(define plot/domestic/local
  (->plot-format (for/list ([i domestic/top10])
                   (cons (car i)
                         (cal-local-today-confirmed-num (car i))))))


(plot-width 600)
(rectangle-line-style 'transparent)
;; (plot-font-size 8)
;; (plot-font-family 'system)
;; (define y-max (+ (vector-ref (second data/domestic) 1) 10))
(plot-file (list (discrete-histogram plot/domestic/unconfirmed
                                     #:color "navy"
                                     #:label "地区待确认")
                 (discrete-histogram plot/domestic/outincome
                                     #:color "yellow"
                                     #:label "境外输入")
                 (discrete-histogram plot/domestic/local
                                     #:color "red"
                                     #:label "本土"))
           domestic.jpeg
           #:x-label "省份名"
           #:y-label "人数"
           #:title "国内前十/今日新增确诊")


;; (require debug/repl)
;; (debug-repl)

(plot-file (discrete-histogram (->plot-format foreign/conadd/top10)
                               #:color "navy"
                               #:line-color "black")
           foreign-conadd.jpeg
           #:x-label "国家名"
           #:y-label "人数"
           #:title "国外前十/今日新增确诊")
(plot-file (discrete-histogram (->plot-format foreign/deathadd/top10)
                               #:color "navy"
                               #:line-color "black")
           foreign-deathadd.jpeg
           #:x-label "国家名"
           #:y-label "人数"
           #:title "国外前十/今日新增死亡")

(plot-file (discrete-histogram (->plot-format foreign/connum/top10)
                               #:color "navy"
                               #:line-color "black")
           foreign-connum.jpeg
           #:x-label "国家名"
           #:y-label "人数"
           #:title "国外/累计确诊")
(plot-file (discrete-histogram (->plot-format foreign/deathnum/top10)
                               #:color "navy"
                               #:line-color "black")
           foreign-deathnum.jpeg
           #:x-label "国家名"
           #:y-label "人数"
           #:title "国外/累计死亡")


(define xpage
  `(html
    (head
     (title @,~a{新冠肺炎报告 - @(~t (now #:tz "Asia/Shanghai") "yyyy-MM-dd HH:mm")})
     (meta ((name "viewport") (content "width=device-width, initial-scale=0.8")))
     (style
         "body { background-color: linen; } .main { width: auto; } .row { padding-top: 10px; } .text { padding-left: 30px; } h2 { margin-bottom: 6px; } p { margin-top: 6px; } .responsive { width: 100%; height: auto; }"
         ))
    (body
     (div ((class "main"))
          (div ((class "text"))
               (h1 "新冠肺炎报告")
               (p "作者：Yanying"
                  (br)
                  "数据来源：qq/sina"
                  (br)
                  @,~a{更新日期：@(~t (now #:tz "Asia/Shanghai") "yyyy-MM-dd HH:mm")}
                  (br)
                  (a ((href "https://github.com/yanyingwang/daily-report")) "source code")))
          (div ((class "text"))
               ,(div-wrap processed/domestic/overall)
               #;,(div-wrap processed/domestic/overall1))
               ,(div-wrap-with-img processed/domestic/top10 @~a{@(or (getenv "DOMAIN") "")./domestic.jpeg})
               ,(div-wrap-with-img processed/foreign/conadd/top10 @~a{@(or (getenv "DOMAIN") "")./foreign-conadd.jpeg})
               ,(div-wrap-with-img processed/foreign/deathadd/top10 @~a{@(or (getenv "DOMAIN") "")./foreign-deathadd.jpeg})
               ,(div-wrap-with-img processed/foreign/connum/top10 @~a{@(or (getenv "DOMAIN") "")./foreign-connum.jpeg})
               ,(div-wrap-with-img processed/foreign/deathnum/top10 @~a{@(or (getenv "DOMAIN") "")./foreign-deathnum.jpeg})
               ))))


;; (require debug/repl)
;; (debug-repl)


(define xpage/string (xexpr->string xpage))
(module+ main
  (with-output-to-file index.html #:exists 'replace
    (lambda () (display xpage/string)))
  )
