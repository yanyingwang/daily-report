#!/usr/bin/env racket
#lang at-exp racket/base

(require racket/string racket/format racket/list
         http-client qweather smtp
         (file "private/parameters.rkt")
         (file "private/weather-forecast-genhtml.rkt"))


(define lid "101180106") ;;henan xinzheng
;; (define lid "101020100") ;;shanghai
(define result/nd
  (http-response-body (weather/7d lid)))
(define data/nd
  (take (hash-ref result/nd 'daily) 5))

(define data/nd/filtered
  (for/hash ([d data/nd])
    (values @~a{@(substring (hash-ref d 'fxDate) 5 7)/@(substring (hash-ref d 'fxDate) 8 10)天气}
            @~a{@(hash-ref d 'textDay)转@(hash-ref d 'textNight)，@(hash-ref d 'tempMin)~@(hash-ref d 'tempMax)度，@(hash-ref d 'windDirDay)@(string-replace (hash-ref d 'windScaleDay) "-" "~")级。})))


(for ([(title content) (in-hash data/nd/filtered)])
  (send-smtp-mail
   (make-mail title content
              #:from (getenv "SENDER")
              #:to (list (getenv "EMAIL3") (getenv "EMAIL4"))))
  (sleep 20))

(send-smtp-mail
 (make-mail "新郑市天气预报" (hash-ref xpages '新郑市)
            #:from (getenv "SENDER")
            #:to (list (getenv "EMAIL1") (getenv "EMAIL2"))))
