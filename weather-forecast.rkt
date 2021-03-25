#!/usr/bin/env racket
#lang at-exp racket/base

(require racket/string racket/format
         http-client qweather smtp
         (file "private/parameters.rkt"))


(define lid "101180106") ;;henan xinzheng
;; (define lid "101020100") ;;shanghai
(define result/3d
  (http-response-body (weather/3d lid)))
(define data/3d
  (hash-ref result/3d 'daily))

(define data/3d/filtered
  (for/hash ([d data/3d])
    (values @~a{@(substring (hash-ref d 'fxDate) 5 10)天气}
            @~a{白天@(hash-ref d 'textDay)，夜间@(hash-ref d 'textNight)，气温@(hash-ref d 'tempMin)-@(hash-ref d 'tempMax)度。})))


(for ([(title content) (in-hash data/3d/filtered)])
  (send-smtp-mail
   (make-mail title content
              #:from (getenv "SENDER")
              #:to (string-split (getenv "RECIPIENT_CM"))))
  (sleep 5))

