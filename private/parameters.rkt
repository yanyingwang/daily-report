#lang racket/base

(require smtp qweather)
(provide (all-defined-out))

(current-smtp-host "smtp.qq.com")
(current-smtp-port 587)
(current-smtp-username (getenv "AUTH_USER"))
(current-smtp-password (getenv "AUTH_PASSWD"))

(current-qweather-key (getenv "QWEATHER_API_KEY"))
(current-qweather-lang "zh")


