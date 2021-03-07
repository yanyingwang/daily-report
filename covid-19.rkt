#!/usr/bin/env racket
#lang at-exp racket/base

(require racket/string smtp
         (file "private/parameters.rkt")
         (file "private/covid-19-qq.rkt")
         (file "private/covid-19-sina.rkt"))

(send-smtp-mail
 (make-mail "新冠肺炎报告"
            (string-join 
              (list qq/overall/china
                    qq/top10/china
                    sina/overall/china
                    sina/top5/foreign
                    sina/top5/today/foreign)
              "\n")
            #:from (getenv "SENDER")
            #:to (string-split (getenv "RECIPIENT"))))
