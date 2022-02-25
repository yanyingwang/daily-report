#!/usr/bin/env racket
#lang at-exp racket/base

(require racket/string racket/format racket/list racket/dict
         http-client qweather smtp
         (file "private/parameters.rkt"))

(define lid
  (for/last ([i lids]
             #:when (string=? (car i) "新郑市"))
    i))


(define ai-content
  (weather/24h/severe-weather-ai (cdr lid)))
(unless (string-contains? ai-content "24小时内无异常天气，请放心出行。")
  (send-smtp-mail
   (make-mail (if (string-contains? ai-content "雪")
                  (string-append (car lid) "24小时内有雪！")
                  (string-append (car lid) "24小时内有雨！"))
              ai-content
              #:from (getenv "SENDER")
              #:to  (string-split (getenv "RECIPIENTS")))))

(define warning-contents
  (hash-ref (http-response-body (warning/now (cdr lid))) 'warning))
(unless (empty? warning-contents)
  (for ([i warning-contents])
    (when (string=? (hash-ref i 'status) "active")
      (sleep 10)
      (send-smtp-mail
       (make-mail (hash-ref i 'title)
                  [hash-ref i 'text]
                  #:from (getenv "SENDER")
                  #:to  (string-split (getenv "RECIPIENTS")))))))
