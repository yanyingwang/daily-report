#lang racket/base

(require http-client racket/format smtp)
(provide bark-xr mail-139
         nxq-weatherd-ai nxq-weatherd-w nxq-weatherd-d)


(define weather-icon
  "https://raw.githubusercontent.com/yanyingwang/weather_daddy/master/favicon.png")
(define xr-api
  (http-connection (getenv "API_DAY_IPHXR")
                   (hasheq)
                   (hasheq 'icon weather-icon)))
(define (bark-xr title content)
  (http-get xr-api
            #:path (~a title  "/" content))
  )

(define ntfy-api
  (http-connection (getenv "API_NTFY")
                   (hasheq)
                   (hasheq 'icon weather-icon)))

(define (nxq-weatherd-ai title message)
  (http-get ntfy-api
            #:path "nxq-weatherd-ai/publish"
            #:data (hasheq 'message message
                           'title title)))
(define (nxq-weatherd-w title message)
  (http-get ntfy-api
            #:path "nxq-weatherd-w/publish"
            #:data (hasheq 'message message
                           'title title)))
(define (nxq-weatherd-d title message)
  (http-get ntfy-api
            #:path "nxq-weatherd-d/publish"
            #:data (hasheq 'message message
                           'title title)))

(define (mail-139 t m)
  (sleep 10)
  (send-smtp-mail
   (make-mail t m
              #:from (getenv "SENDER")
              #:to  (list (getenv "EMAIL_MY_139") (getenv "EMAIL_BA_139"))))
  )