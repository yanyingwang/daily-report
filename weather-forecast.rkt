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

(define data/formated-list
  (for/list ([d data/3d])
    (list @~a{@(substring (hash-ref d 'fxDate) 5 10)天气}
          @~a{白天@(hash-ref d 'textDay)，夜间@(hash-ref d 'textNight)，气温@(hash-ref d 'tempMin)-@(hash-ref d 'tempMax)度。})))

(for ([title-and-content data/formated-list])
  (send-smtp-mail
   (make-mail (car title-and-content) (cadr title-and-content)
              #:from (getenv "SENDER")
              #:to (string-split (getenv "RECIPIENT_CM"))))
  (sleep 5))
