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


(current-http-client/debug #t)
(define r3 (weather/15d/ai (cdr xz)))

(println "============bark-xr:")
(bark-xr "新郑市天气预报" r3)
(println "============nxq-weatherd-d:")
(println nxq-weatherd-d)

#;(let* ([r0 (weather/15d (cdr xz))]
       [r1 (http-response-body r0)]
       [r2 (cdr (hash-ref r1 'daily))]
       [r3 (weather/15d/ai-parse r2)]
       [msg r3])
  (bark-xr "新郑市天气预报" msg)
  (nxq-weatherd-d "新郑市天气预报" msg)
  )
