#!/usr/bin/env racket
#lang at-exp racket/base

(require racket/string racket/list racket/runtime-path racket/format
         xml plot/no-gui gregor
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
(define-runtime-path foreign-connum.jpeg "public/foreign-connum.jpeg")
;; (define y-max (+ (vector-ref (second data/domestic) 1) 10))

;; (require debug/repl)
;; (debug-repl)

(define (->plot-format lst)
  (for/list ([l lst])
    (vector (car l) (cdr l))))

(plot-file (list (discrete-histogram (->plot-format (take qq/provinces/today/confirm 10))
                                     #:color "navy"
                                     #:line-color "navy"
                                     ;; #:y-max y-max
                                     #:label "全部")
                 (discrete-histogram (->plot-format
                                      (for/list ([i (take qq/provinces/today/confirm 10)])
                                        (if (qq/get-num (qq/get-province (car i) '境外输入) 'today 'confirm)
                                            (cons (car i)
                                                  (- (qq/get-num (qq/get-province (car i)) 'today 'confirm)
                                                     (qq/get-num (qq/get-province (car i) '境外输入) 'today 'confirm)))
                                            (cons (car i) #f))))
                                     #:color "red"
                                     #:line-color "red"
                                     ;; #:y-max y-max
                                     #:label "本土")
                 (discrete-histogram (->plot-format
                                      (for/list ([i (take qq/provinces/today/confirm 10)])
                                        (cons (car i)
                                              (qq/get-num (qq/get-province (car i) '境外输入) 'today 'confirm))))
                                     #:color "yellow"
                                     #:line-color "yellow"
                                     ;; #:y-max y-max
                                     #:label "境外输入"))
           domestic.jpeg
           #:x-label "省份名"
           #:y-label "确诊人数"
           #:title "统计报表（国内今日新增）")

(plot-file (discrete-histogram (->plot-format (take sina/contries/conadd 10))
                               #:color "navy"
                               #:line-color "black")
           foreign-conadd.jpeg
           #:x-label "国家名"
           #:y-label "确诊人数"
           #:title "统计报表（国外今日新增确诊）")

(plot-file (discrete-histogram (->plot-format (take sina/contries/connum 10))
                               #:color "navy"
                               #:line-color "black")
           foreign-connum.jpeg
           #:x-label "国家名"
           #:y-label "确诊人数"
           #:title "统计报表（国外累计确诊）")


(define xpage
  `(html
    (head
     (meta ((name "viewport") (content "width=device-width, initial-scale=1")))
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
                  (a ((href "https://github.com/yanyingwang/daily-report")) "code source")))
          (div ((class "text"))
               ,(div-wrap qq/domestic/overall)
               ,(div-wrap sina/domestic/overall))
          ,(div-wrap-with-img qq/domestic/top10 "./domestic.jpeg")
          ,(div-wrap-with-img sina/foreign/top10/conadd "./foreign-conadd.jpeg")
          ,(div-wrap-with-img sina/foreign/top10/connum "./foreign-connum.jpeg")
          ))))


(and (file-exists? index.html)
     (delete-file index.html))

(with-output-to-file index.html
  (lambda () (printf (xexpr->string xpage))))
