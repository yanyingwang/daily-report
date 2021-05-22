#!/usr/bin/env racket
#lang at-exp racket/base

(require racket/string racket/list racket/runtime-path racket/format
         covid-19/qq xml plot/no-gui gregor
         (file "private/covid-19-qq.rkt")
         (file "private/covid-19-sina.rkt")
         (file "private/tools.rkt"))

;; colors
;; file:///Applications/Racket%20v8.0/doc/draw/color-database___.html
;; histogram
;; file:///Applications/Racket%20v8.0/doc/plot/renderer2d.html?q=histogram#(def._((lib._plot%2Fmain..rkt)._discrete-histogram))


(plot-width 600)
;; (plot-font-size 8)
;; (plot-font-family 'system)
(define-runtime-path index.html "public/index.html")
(define-runtime-path domestic.jpeg "public/domestic.jpeg")
(define-runtime-path foreign-conadd.jpeg "public/foreign-conadd.jpeg")
(define-runtime-path foreign-deathadd.jpeg "public/foreign-deathadd.jpeg")
(define-runtime-path foreign-connum.jpeg "public/foreign-connum.jpeg")
(define-runtime-path foreign-deathnum.jpeg "public/foreign-deathnum.jpeg")


;; (require debug/repl)
;; (debug-repl)

;; (define y-max (+ (vector-ref (second data/domestic) 1) 10))
(plot-file (list (discrete-histogram (->plot-format domestic/top10)
                                     #:color "navy"
                                     #:line-color "navy"
                                     ;; #:y-max y-max
                                     #:label "全部")
                 (discrete-histogram (->plot-format
                                      (for/list ([i domestic/top10])
                                        (cons (car i)
                                              (- (cdr i)
                                                 (or (qq/get-num* (car i) #:city '境外输入) 0)))))
                                     #:color "red"
                                     #:line-color "red"
                                     ;; #:y-max y-max
                                     #:label "本土")
                 (discrete-histogram (->plot-format
                                      (for/list ([i domestic/top10])
                                        (cons (car i)
                                              (qq/get-num* (car i) #:city '境外输入))))
                                     #:color "yellow"
                                     #:line-color "yellow"
                                     ;; #:y-max y-max
                                     #:label "境外输入"))
           domestic.jpeg
           #:x-label "省份名"
           #:y-label "人数"
           #:title "统计报表（国内前十/今日新增确诊）")

(plot-file (discrete-histogram (->plot-format foreign/conadd/top10)
                               #:color "navy"
                               #:line-color "black")
           foreign-conadd.jpeg
           #:x-label "国家名"
           #:y-label "人数"
           #:title "统计报表（国外前十/今日新增确诊）")
(plot-file (discrete-histogram (->plot-format foreign/deathadd/top10)
                               #:color "navy"
                               #:line-color "black")
           foreign-deathadd.jpeg
           #:x-label "国家名"
           #:y-label "人数"
           #:title "统计报表（国外前十/今日新增死亡）")

(plot-file (discrete-histogram (->plot-format foreign/connum/top10)
                               #:color "navy"
                               #:line-color "black")
           foreign-connum.jpeg
           #:x-label "国家名"
           #:y-label "人数"
           #:title "统计报表（国外/累计确诊）")
(plot-file (discrete-histogram (->plot-format foreign/deathnum/top10)
                               #:color "navy"
                               #:line-color "black")
           foreign-deathnum.jpeg
           #:x-label "国家名"
           #:y-label "人数"
           #:title "统计报表（国外/累计死亡）")


(define xpage
  `(html
    (head
     (meta ((name "viewport") (content "width=device-width, initial-scale=0.8")))
     (style
         "body { background-color: linen; } .main { width: auto; } .row { padding-top: 10px; } .text { padding-left: 30px; } h2 { margin-bottom: 6px; } p { margin-top: 6px; } .responsive { width: 100%; height: auto; }"))
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


(and (file-exists? index.html)
     (delete-file index.html))

(with-output-to-file index.html
  (lambda () (printf (xexpr->string xpage))))
