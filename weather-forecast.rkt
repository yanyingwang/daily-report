#!/usr/bin/env racket
#lang at-exp racket/base

(require racket/string racket/format
         http-client qweather smtp xml
         (file "private/parameters.rkt")
         (file "weather-forecast.genhtml.rkt")
         (file "private/senders.rkt")
         (only-in (file "private/helpers.rkt") simplify-weather-text xz sh bj)
         )

;; (send-smtp-mail
;;  (make-mail "新郑市天气预报"
;;             (xexpr->string (gen-xexpr "新郑市"))
;;             #:body-content-type "text/html"
;;             #:from (getenv "SENDER")
;;             #:to (list (getenv "EMAIL_MY_QQ") (getenv "EMAIL_BA_QQ"))))

;-------


(let ([m (weather/15d/severe-weather-ai xz)])
  (bark-xr "新郑市天气预报" m)
  (nxq-weatherd-d "新郑市天气预报" m)
  )
