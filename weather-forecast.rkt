#!/usr/bin/env racket
#lang at-exp racket/base

(require racket/string racket/format http-client qweather smtp)

(current-smtp-host "smtp.qq.com")
(current-smtp-port 587)
(current-smtp-username (getenv "AUTH_USER"))
(current-smtp-password (getenv "AUTH_PASSWD"))

(current-qweather-key (getenv "QWEATHER_API_KEY"))
(current-qweather-lang "zh")

(define lid "101180106") ;;xinzheng
;; (define lid "101020100") ;;shanhhai
(define result/3d
  (http-response-body (weather/3d lid)))
(define data/3d
  (hash-ref result/3d 'daily))

(define sms/title "三日天气")
(define sms/content
  (string-join
   (for/list ([d data/3d])
     @~a{@(hash-ref d 'fxDate)：白天@(hash-ref d 'textDay)，夜间@(hash-ref d 'textNight)，气温@(hash-ref d 'tempMin)-@(hash-ref d 'tempMax)度。})
   "\n"))


(send-smtp-mail
 (make-mail sms/title sms/content
            #:from (getenv "SENDER")
            #:to (string-split (getenv "RECIPIENT_CM"))))
