#!/usr/bin/env racket
#lang at-exp racket/base

(require racket/string racket/format racket/list
         http-client qweather smtp
         (file "private/parameters.rkt"))

(define lid
  ;; (cons "101230401" "莆田市")
  ;; (cons "101020100" "上海市")
  (cons "101180106" "新郑市")
  ;; (cons "101180101" "郑州市")
  ;; (cons "101070101" "沈阳市")
  )

(define ai-content
  (weather/24h/severe-weather-ai (car lid)))
(unless (string-contains? ai-content "24小时内无异常，请放心出行")
  (send-smtp-mail
   (make-mail (if (string-contains? ai-content "雪")
                  (string-append (cdr lid) "24小时内有雪！")
                  (string-append (cdr lid) "24小时内有雨！"))
              ai-content
              #:from (getenv "SENDER")
              #:to  (string-split (getenv "RECIPIENTS")))))


(define warning-contents
  (hash-ref (http-response-body (warning/now (car lid))) 'warning))
(unless (empty? warning-contents)
  (for ([i warning-contents])
    (when (string=? (hash-ref i 'status) "active")
      (sleep 10)
      (send-smtp-mail
       (make-mail (hash-ref i 'title)
                  [hash-ref i 'text]
                  #:from (getenv "SENDER")
                  #:to  (string-split (getenv "RECIPIENTS")))))))
