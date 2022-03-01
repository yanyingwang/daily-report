#!/usr/bin/env racket
#lang at-exp racket/base

(require racket/string racket/format racket/list racket/dict
         http-client qweather smtp
         (file "private/parameters.rkt")
         (only-in (file "private/helpers.rkt") lids))

(define lid
  (assoc "新郑市" lids))
;; (for/last ([i lids]
;;              #:when (string=? (car i) "新郑市"))
;;     i)

(define ai-content
  (weather/24h/severe-weather-ai (cdr lid)))
(unless (string-contains? ai-content "24小时内无降水天气。")
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
  (for ([i warning-contents]
        #:when (string=? (hash-ref i 'status) "active"))
    (displayln i)
    (sleep 10)
    (send-smtp-mail
     (make-mail @~a{今日有@(hash-ref i 'typeName)！}
                (hash-ref i 'title)
                #:from (getenv "SENDER")
                #:to  (list (getenv "EMAIL_MY_139") (getenv "EMAIL_BA_139"))))
    (sleep 10)
    (send-smtp-mail
     (make-mail (hash-ref i 'title)
                (hash-ref i 'text)
                #:from (getenv "SENDER")
                #:to   (list (getenv "EMAIL_MY_QQ") (getenv "EMAIL_BA_QQ"))))))
