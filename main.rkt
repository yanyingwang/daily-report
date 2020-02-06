#!/usr/bin/env racket
#lang at-exp racket/base

(require net/http-client
         racket/port
         racket/format
         smtp-lib
         json
         #;debug/repl
         )

(define-values (status headers in)
  (http-sendrecv "www.tianqiapi.com"
                 "/api?version=epidemic&appid=23035354&appsecret=8YvlPNrz"
                 #:ssl? #t))

#;(displayln status)
#;(displayln headers)
(or (equal? status #"HTTP/1.1 200 OK")
    (raise "error: api request error"))

(define res (string->jsexpr (port->string in)))
(define data (hash-ref res 'data))

(define area (hash-ref data 'area))
(define henan (findf (lambda (i) (equal? (hash-ref i 'provinceName) "河南"))
                     area))

(define cities (hash-ref henan 'cities))
(define zhengzhou (findf (lambda (i) (equal? (hash-ref i 'cityName) "郑州"))
                         cities))

(define content @~a{
                    全国已确诊：@(hash-ref data 'diagnosed)人，
                    全国疑似：@(hash-ref data 'suspect)人，
                    全国已治愈：@(hash-ref data 'cured)人，
                    全国已死亡：@(hash-ref data 'death)人。
                    河南已确诊：@(hash-ref henan 'confirmedCount)人，
                    河南已治愈：@(hash-ref henan 'curedCount)人，
                    河南已死亡：@(hash-ref henan 'deadCount)人。
                    郑州已确诊：@(hash-ref zhengzhou 'confirmedCount)人，
                    郑州已治愈：@(hash-ref zhengzhou 'curedCount)人，
                    郑州已死亡：@(hash-ref zhengzhou 'deadCount)人。
                    })

(define email (mail (getenv "SENDER") ; sender
                    `(,(getenv "RECIPIENT")) ; recipients
                    "新型肺炎今日报告" ; subject
                    content ; content
                    '() #;attachments))

(send-smtp-mail email
                #:host "smtp.qq.com"
                #:port 587
                #:auth-user (getenv "AUTH_USER")
                #:auth-passwd (getenv "AUTH_PASSWD"))
