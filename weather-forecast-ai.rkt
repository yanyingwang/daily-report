#!/usr/bin/env racket
#lang at-exp racket/base

(require racket/string racket/format racket/list
         http-client qweather smtp
         (file "private/parameters.rkt"))

(define lid
  ;; "101230401" ;莆田
  ;; "101020100" ;上海
  "101180106" ;郑州
  ;; "101070101" ;沈阳
  )

(define content
  (weather/24h/severe-weather-ai lid))

(unless (string-contains? content "24小时内无雨，请放心出行")
  (send-smtp-mail
   (make-mail "下雨提醒" content
              #:from (getenv "SENDER")
              #:to (string-split
                    (string-join
                     (list (getenv "PHONE_RECIPIENTS")
                           (getenv "EMAIL_RECIPIENTS")))))))
