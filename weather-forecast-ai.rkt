#!/usr/bin/env racket
#lang racket/base

(require racket/string racket/format http-client smtp qweather
         (file "private/parameters.rkt")
         (file "private/senders.rkt")
         (only-in (file "private/helpers.rkt") xz sh bjfs))

(define (ai-rain lid)
  (define message (weather/24h/severe-weather-ai (cdr lid)))
  (define title0
    (cond
      [(string-contains? message "24小时内无降水天气。") "24小时内无降水"]
      [(string-contains? message "雪") "24小时内有雪！"]
      [(string-contains? message "雨") "24小时内有雨！"]
      [(string-contains? message "雨夹雪") "24小时内有雨夹雪！"]
      [(string-contains? message "冰雹") "24小时内有冰雹！"]
      [(string-contains? message "冻雨") "24小时内有冻雨！"]
      [else "24小时内有降水！"]))
  (define title
    (string-append (car lid) title0))
  (if (string=? title0 "24小时内无降水") #f
      (list title message)))

(define (ai-warnings lid)
  (define contents
    (hash-ref (http-response-body (warning/now (cdr lid))) 'warning))
  (for/list ([i contents]
             #:when (or (string=? (hash-ref i 'status) "active")
                        (string=? (hash-ref i 'status) "update")))
    (list (string-append  (car lid) "今日有" (hash-ref i 'typeName) "！")
          (hash-ref i 'title)
          (hash-ref i 'text))))


(let ([res (ai-rain xz)])
  (when res
    (let ([t (car res)]
          [m (cadr res)])
      (nxq-weatherd-ai t m)
      (mail-139 t m)
      )
    )
  )

(for ([i (ai-warnings xz)])
  (let ([t0 (car i)]
        [t (cadr i)]
        [m (caddr i)])
    (nxq-weatherd-w t m)
    (mail-139 t0 t)
    )
  )


(let ([res (ai-rain bjfs)])
  (when res
    (let ([t (car res)]
          [m (cadr res)])
      (bark-xr t m)
      )
    )
  )

