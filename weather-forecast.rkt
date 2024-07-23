#!/usr/bin/env racket
#lang racket/base

(require racket/string racket/format http-client qweather
         (file "private/parameters.rkt")
         ;; (file "weather-forecast.genhtml.rkt") xml smtp
         (file "private/senders.rkt")
         (only-in (file "private/helpers.rkt") xz sh bj)
         )

;; (send-smtp-mail
;;  (make-mail "新郑市天气预报"
;;             (xexpr->string (gen-xexpr "新郑市"))
;;             #:body-content-type "text/html"
;;             #:from (getenv "SENDER")
;;             #:to (list (getenv "EMAIL_MY_QQ") (getenv "EMAIL_BA_QQ"))))

;-------

;(current-http-client/debug #t)

(let ([t "新郑市天气预报"]
      [m (weather/15d/ai (cdr xz))])
  (bark-xr t m)
  (nxq-weatherd-d t m))

(let ([t "北京市天气预报"]
      [m (weather/15d/ai (cdr bj))])
  (bark-xr t m))

