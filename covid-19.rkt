#!/usr/bin/env racket
#lang at-exp racket/base

(require http-client
         racket/list
         racket/port
         racket/format
         racket/string
         smtp
         json
         ;; debug/repl
         )


(current-smtp-host "smtp.qq.com")
(current-smtp-port 587)
(current-smtp-username (getenv "AUTH_USER"))
(current-smtp-password (getenv "AUTH_PASSWD"))

(define res
  (http-get (http-connection "https://view.inews.qq.com" (hasheq) (hasheq))
            #:path "/g2/getOnsInfo?name=disease_h5"))

(define data (string->jsexpr (hash-ref (http-response-body res) 'data)))

(define china-total (hash-ref data 'chinaTotal))
(define china-add (hash-ref data 'chinaAdd))
(define provinces (hash-ref (car (hash-ref data 'areaTree)) 'children))

(define henan (findf (lambda (i) (equal? (hash-ref i 'name) "河南"))
                     provinces))
(define cities-of-henan (hash-ref henan 'children))
(define zhengzhou (findf (lambda (i) (equal? (hash-ref i 'name) "郑州"))
                         cities-of-henan))

(define shanghai (findf (lambda (i) (equal? (hash-ref i 'name) "上海"))
                     provinces))
(define areas-of-shanghai (hash-ref shanghai 'children))
(define jingwai-of-shanghai (findf (lambda (i) (equal? (hash-ref i 'name) "境外输入"))
                         areas-of-shanghai))



;;;;;;;
(define sorted-provinces ;; by-daily-added
  (sort provinces (lambda (i1 i2)
                    (> (hash-ref (hash-ref i1 'today) 'confirm)
                       (hash-ref (hash-ref i2 'today) 'confirm)))))


(define overall
  @~a{
      『概览』
      全国今日新增确诊：@(hash-ref china-add 'confirm)人，
      全国今日治愈：@(hash-ref china-add 'heal)人，
      全国今日死亡：@(hash-ref china-add 'dead)人。
      -- @(hash-ref (hash-ref henan 'today) 'tip)
      河南今日新增确诊：@(hash-ref (hash-ref henan 'today) 'confirm)人。
      郑州今日新增确诊：@(hash-ref (hash-ref zhengzhou 'today) 'confirm)人。
      -- @(hash-ref (hash-ref shanghai 'today) 'tip)
      上海今日新增确诊：@(hash-ref (hash-ref shanghai 'today) 'confirm)人（其中境外输入@(hash-ref (hash-ref jingwai-of-shanghai 'today) 'confirm)人）。
      })

(define top5
  @~a{
      『国内新增前五』
      @(hash-ref (first sorted-provinces) 'name)：@(hash-ref (hash-ref (first sorted-provinces) 'today) 'confirm)人，
      @(hash-ref (second sorted-provinces) 'name)：@(hash-ref (hash-ref (second sorted-provinces) 'today) 'confirm)人，
      @(hash-ref (third sorted-provinces) 'name)：@(hash-ref (hash-ref (third sorted-provinces) 'today) 'confirm)人，
      @(hash-ref (fourth sorted-provinces) 'name)：@(hash-ref (hash-ref (fourth sorted-provinces) 'today) 'confirm)人，
      @(hash-ref (fifth sorted-provinces) 'name)：@(hash-ref (hash-ref (fifth sorted-provinces) 'today) 'confirm)人。
      })


(send-smtp-mail
 (make-mail "新冠肺炎今日报告"
            @~a{
                @overall

                @top5
                }
            #:from (getenv "SENDER")
            #:to (string-split (getenv "RECIPIENT"))))
