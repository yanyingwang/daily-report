#lang info
(define collection "daily-report")
(define deps
  '("base"
    "at-exp-lib"
    "gregor-lib"
    "https://github.com/yanyingwang/smtp.git"
    "https://github.com/yanyingwang/http-client.git"
    "https://github.com/yanyingwang/qweather.git"))
(define build-deps '("scribble-lib" "racket-doc" "rackunit-lib"))
;; (define scribblings '(("scribblings/2019-nCov-report.scrbl" ()) ))
(define pkg-desc "Daily reports of covid19, weather forcast.")
(define version "0.2")
(define pkg-authors '("Yanying Wang"))
