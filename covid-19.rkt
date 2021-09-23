#!/usr/bin/env racket
#lang at-exp racket/base

;; (require  racket/string racket/list racket/runtime-path
;;           smtp xml plot/no-gui
;;           (file "private/parameters.rkt")
;;           (file "private/tools.rkt")
;;           (file "private/covid-19-qq.rkt")
;;           (file "private/covid-19-sina.rkt"))


;; (send-smtp-mail
;;  (make-mail "新冠肺炎报告"
;;             (xexpr->string
;;              `(div ((class "main"))
;;                    (a ((href "https://yanying.wang/daily-report/index.html")) "点此查看图文模式")
;;                    ,(div-wrap processed/domestic/overall)
;;                    ,(div-wrap processed/domestic/overall1)
;;                    ,(div-wrap processed/domestic/top10)
;;                    ,(div-wrap processed/foreign/conadd/top10)
;;                    ,(div-wrap processed/foreign/deathadd/top10)
;;                    ,(div-wrap processed/foreign/connum/top10)
;;                    ,(div-wrap processed/foreign/deathnum/top10)])
;;             #:body-content-type "text/html"
;;             #:from (getenv "SENDER")
;;             #:to (string-split (getenv "RECIPIENT"))))


(require  racket/string racket/list smtp
          (file "private/parameters.rkt")
          (file "covid-19-genhtml.rkt"))

(send-smtp-mail
 (make-mail "新冠肺炎报告"
            xpage/string
            #:body-content-type "text/html"
            #:from (getenv "SENDER")
            #:to (string-split (getenv "RECIPIENTS"))))
