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

(define ai-content
  (weather/24h/severe-weather-ai lid))

(unless (string-contains? ai-content "24小时内无雨，请放心出行")
  (send-smtp-mail
   (make-mail "24小时内有雨！" ai-content
              #:from (getenv "SENDER")
              #:to  (string-split (getenv "RECIPIENTS")))))


(define warning-contents
  (hash-ref (http-response-body (warning/now lid)) 'warning))

(unless (empty? warning-contents)
  (for ([i warning-contents])
    (when (string=? (hash-ref i 'status) "active")
      (sleep 10)
      (send-smtp-mail
       (make-mail (hash-ref i 'title)
                  [hash-ref i 'text]
                  #:from (getenv "SENDER")
                  #:to  (string-split (getenv "RECIPIENTS")))))))
