#!/usr/bin/env racket
#lang at-exp racket/base

{require  racket/string racket/list racket/runtime-path
          smtp xml plot/no-gui
          (file "private/parameters.rkt")
          (file "private/tools.rkt")
          (file "private/covid-19-qq.rkt")
          (file "private/covid-19-sina.rkt")}


(send-smtp-mail
 (make-mail "新冠肺炎报告"
            (xexpr->string
             `(div ((class "main"))
                   (a ((href "https://yanying.wang/daily-report/index.html")) "点此查看图文模式")
                   ,(div-wrap qq/domestic/overall)
                   ,(div-wrap sina/domestic/overall)
                   ,(div-wrap qq/domestic/top10)
                   ,(div-wrap sina/foreign/top10)
                   ,(div-wrap sina/foreign/top10-agg)))
            #:body-content-type "text/html"
            #:from (getenv "SENDER")
            #:to (string-split (getenv "RECIPIENT"))))
