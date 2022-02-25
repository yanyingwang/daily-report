#!/usr/bin/env racket
#lang at-exp racket/base


(require  racket/string racket/list smtp
          (only-in (file "private/parameters.rkt") init-smtp-parameters)
          (file "covid-19.genhtml.rkt"))

(send-smtp-mail
 (make-mail "新冠肺炎报告"
            xpage/string
            #:body-content-type "text/html"
            #:from (getenv "SENDER")
            #:to (string-split (getenv "RECIPIENTS"))))
