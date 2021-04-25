#!/usr/bin/env racket
#lang at-exp racket/base

(require racket/string smtp xml
         (file "private/parameters.rkt")
         (file "private/covid-19-qq.rkt")
         (file "private/covid-19-sina.rkt"))

(current-smtp-body-content-type "text/html")

(send-smtp-mail
 (make-mail "新冠肺炎报告"
            (xexpr->string
             `(div ((class "main"))
                   ,qq/overall/china
                   ,sina/overall/china
                   ,qq/top10/china
                   ,sina/top5/today/foreign
                   ,sina/top5/foreign))
            #:from (getenv "SENDER")
            #:to (string-split (getenv "RECIPIENT"))))
