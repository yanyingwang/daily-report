#!/usr/bin/env racket
#lang at-exp racket/base

(require net/http-client
         racket/list
         racket/port
         racket/format
         racket/string
         smtp
         json
         debug/repl
         )


(current-smtp-host "smtp.qq.com")
(current-smtp-port 587)
(current-smtp-username (getenv "AUTH_USER"))
(current-smtp-password (getenv "AUTH_PASSWD"))


;;;; sina.cn api
(define-values (status headers in)
  (http-sendrecv "interface.sina.cn"
                 "/news/wap/fymap2020_data.d.json"
                 #:ssl? #t))

(or (equal? status #"HTTP/1.1 200 OK")
    (error 'http-sendrecv "api request error, status: ~a" status))

(define res (string->jsexpr (port->string in)))
(define data (hash-ref res 'data))
(define list (hash-ref data 'list))
(define otherlist (hash-ref data 'otherlist))

;;;;;;;
(define henan (findf (lambda (i) (equal? (hash-ref i 'name) "河南"))
                     list))
(define city (hash-ref henan 'city))
(define zhengzhou (findf (lambda (i) (equal? (hash-ref i 'name) "郑州市"))
                         city))


;;;;;;;
(define sorted-p (sort list (lambda (i1 i2) ; provinces of china
                              (> (string->number (hash-ref i1 'value))
                                 (string->number (hash-ref i2 'value))))))
(define sorted-c (sort otherlist (lambda (i1 i2) ; countries except china
                                   (> (string->number (hash-ref i1 'value))
                                      (string->number (hash-ref i2 'value))))))

;;;;;;;
(define daily-p (map (lambda (i) (hash 'name (hash-ref i 'name)
                                  'value (hash-ref (hash-ref i 'adddaily) 'conadd_n))) list))
(define daily-c (map (lambda (i) (hash 'name (hash-ref i 'name)
                                  'value (hash-ref i 'conadd))) otherlist))

(define sorted-daily-p (sort daily-p (lambda (i1 i2)
                                       (define v1 (hash-ref i1 'value))
                                       (define v2 (hash-ref i2 'value))
                                       (and (string? v1) (set! v1 -1))
                                       (and (string? v2) (set! v2 -1))
                                       (> v1 v2))))
(define sorted-daily-c (sort daily-c (lambda (i1 i2)
                                       (define v1 (hash-ref i1 'value))
                                       (define v2 (hash-ref i2 'value))
                                       (and (string=? v1 "-") (set! v1 "-1"))
                                       (and (string=? v2 "-") (set! v2 "-1"))
                                       (> (string->number v1)
                                          (string->number v2)))))

;; 新型肺炎今日概览报告
(define overall @~a{
                    『概览』
                    全国现有确诊：@(hash-ref data 'econNum)人，
                    全国累计确诊：@(hash-ref data 'gntotal)人，
                    全国现有疑似：@(hash-ref data 'sustotal)人，
                    全国现已治愈：@(hash-ref data 'curetotal)人，
                    全国现已死亡：@(hash-ref data 'deathtotal)人。
                    河南现有确诊：@(hash-ref henan 'econNum)人，
                    河南累计确诊：@(hash-ref henan 'value)人，
                    河南现已治愈：@(hash-ref henan 'cureNum)人，
                    河南已死亡：@(hash-ref henan 'deathNum)人。
                    郑州累积确诊：@(hash-ref zhengzhou 'conNum)人，
                    郑州现已治愈：@(hash-ref zhengzhou 'cureNum)人，
                    郑州现已死亡：@(hash-ref zhengzhou 'deathNum)人。
                    })

;; 新型肺炎今日总计排名报告
(define top5-con @~a{
                     『累积前五』
                     @(hash-ref (first sorted-p) 'name)：@(hash-ref (first sorted-p) 'value)人，
                     @(hash-ref (second sorted-p) 'name)：@(hash-ref (second sorted-p) 'value)人，
                     @(hash-ref (third sorted-p) 'name)：@(hash-ref (third sorted-p) 'value)人，
                     @(hash-ref (fourth sorted-p) 'name)：@(hash-ref (fourth sorted-p) 'value)人，
                     @(hash-ref (fifth sorted-p) 'name)：@(hash-ref (fifth sorted-p) 'value)人。
                     @(hash-ref (first sorted-c) 'name)：@(hash-ref (first sorted-c) 'value)人，
                     @(hash-ref (second sorted-c) 'name)：@(hash-ref (second sorted-c) 'value)人，
                     @(hash-ref (third sorted-c) 'name)：@(hash-ref (third sorted-c) 'value)人，
                     @(hash-ref (fourth sorted-c) 'name)：@(hash-ref (fourth sorted-c) 'value)人，
                     @(hash-ref (fifth sorted-c) 'name)：@(hash-ref (fifth sorted-c) 'value)人。
                     })


(define top5-con-today @~a{
                           『新增前五』
                           @(hash-ref (first sorted-daily-p) 'name)：@(hash-ref (first sorted-daily-p) 'value)人，
                           @(hash-ref (second sorted-daily-p) 'name)：@(hash-ref (second sorted-daily-p) 'value)人，
                           @(hash-ref (third sorted-daily-p) 'name)：@(hash-ref (third sorted-daily-p) 'value)人，
                           @(hash-ref (fourth sorted-daily-p) 'name)：@(hash-ref (fourth sorted-daily-p) 'value)人，
                           @(hash-ref (fifth sorted-daily-p) 'name)：@(hash-ref (fifth sorted-daily-p) 'value)人。
                           @(hash-ref (first sorted-daily-c) 'name)：@(hash-ref (first sorted-daily-c) 'value)人，
                           @(hash-ref (second sorted-daily-c) 'name)：@(hash-ref (second sorted-daily-c) 'value)人，
                           @(hash-ref (third sorted-daily-c) 'name)：@(hash-ref (third sorted-daily-c) 'value)人，
                           @(hash-ref (fourth sorted-daily-c) 'name)：@(hash-ref (fourth sorted-daily-c) 'value)人，
                           @(hash-ref (fifth sorted-daily-c) 'name)：@(hash-ref (fifth sorted-daily-c) 'value)人。
                           })

(current-smtp-debug-mode #t)

(send-smtp-mail (make-mail "新冠肺炎今日报告"
                           @~a{
                               @overall

                               @top5-con-today

                               @top5-con
                               }
                           #:from (getenv "SENDER")
                           #:to (string-split (getenv "RECIPIENT"))))
