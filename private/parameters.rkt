#lang racket/base

(require smtp qweather)
(provide (all-defined-out))

(define init-smtp-parameters
  (begin
    (current-smtp-host "smtp.qq.com")
    (current-smtp-port 587)
    (current-smtp-username (getenv "AUTH_USER"))
    (current-smtp-password (getenv "AUTH_PASSWD"))))

(define init-qweather-parameters
  (begin
    (current-qweather-key (getenv "QWEATHER_API_KEY"))
    (current-qweather-lang "zh")))
