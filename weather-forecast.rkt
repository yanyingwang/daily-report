#!/usr/bin/env racket
#lang at-exp racket/base

(require racket/string racket/format racket/list racket/dict xml
         http-client qweather smtp
         (file "private/parameters.rkt")
         (only-in (file "private/helpers.rkt")
                  lids simplify-weather-text)
         (file "weather-forecast.genhtml.rkt"))

(define lid
  (dict-ref lids "新郑市"))
(define result/nd
  (http-response-body (weather/7d lid)))
(define data/nd
  (take (hash-ref result/nd 'daily) 5))

(define data/nd/filtered
  (for/list ([d data/nd])
    (cons @~a{@(substring (hash-ref d 'fxDate) 5 7)/@(substring (hash-ref d 'fxDate) 8 10)天气}
          @~a{@(simplify-weather-text (hash-ref d 'textDay) (hash-ref d 'textNight))，@(hash-ref d 'tempMin)~@(hash-ref d 'tempMax)度，@(hash-ref d 'windDirDay)@(string-replace (hash-ref d 'windScaleDay) "-" "~")级。})))


(for ([(title content) (in-dict data/nd/filtered)])
  (send-smtp-mail
   (make-mail title content
              #:from (getenv "SENDER")
              #:to (list (getenv "EMAIL3") (getenv "EMAIL4"))))
  (sleep 20))

(send-smtp-mail
 (make-mail "新郑市天气预报"
            (xexpr->string (gen-xexpr "新郑市"))
            #:body-content-type "text/html"
            #:from (getenv "SENDER")
            #:to (list (getenv "EMAIL1") (getenv "EMAIL2"))))
