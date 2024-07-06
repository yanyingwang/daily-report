#!/usr/bin/env racket
#lang at-exp racket/base

(require racket/string racket/format
         http-client qweather smtp xml
         (file "private/parameters.rkt")
         (file "weather-forecast.genhtml.rkt")
         (file "private/senders.rkt")
         (only-in (file "private/helpers.rkt") simplify-weather-text xz sh bj)
         )

(send-smtp-mail
 (make-mail "新郑市天气预报"
            (xexpr->string (gen-xexpr "新郑市"))
            #:body-content-type "text/html"
            #:from (getenv "SENDER")
            #:to (list (getenv "EMAIL_MY_QQ") (getenv "EMAIL_BA_QQ"))))

;-------

(define rt0 (http-response-body (weather/15d (cdr xz))))
(define rt1 (hash-ref rt0 'daily))
(define day1 (car rt1))
(define day2 (cadr rt1))
(define day3 (caddr rt1))

(define day1/x
  @~a{今天@(simplify-weather-text (hash-ref day1 'textDay) (hash-ref day1 'textNight))，气温@(hash-ref day1 'tempMin)~@(hash-ref day1 'tempMax)度，@(hash-ref day1 'windDirDay)@(string-replace (hash-ref day1 'windScaleDay) "-" "~")级。})
(define day1/s
  @~a{日出于@(hash-ref day1 'sunrise)，落于@(hash-ref day1 'sunset)。})
(define day1/m
  @~a{夜晚的一弯@(hash-ref day1 'moonPhase)，出于@(hash-ref day1 'moonrise)，落于@(hash-ref day1 'moonset)。})
(define day2+3/x
  @~a{明天@(simplify-weather-text (hash-ref day2 'textDay) (hash-ref day2 'textNight))，后天@(simplify-weather-text (hash-ref day3 'textDay) (hash-ref day3 'textNight))。})
(define day14/x
  (weather/15d/severe-weather-ai (cdr xz)))

(define message
  (string-append day1/x day1/s day1/m day2+3/x day14/x))
(bark-xr "新郑市天气预报" message)
(nxq-weatherd-w "新郑市天气预报" message)
