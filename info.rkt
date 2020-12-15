#lang info
(define collection "2019-nCov-report")
(define deps '("base" "at-exp-lib" "r6rs-lib" "gregor-lib" "https://github.com/yanyingwang/smtp" "https://github.com/yanyingwang/http-client.git"))
(define build-deps '("scribble-lib" "racket-doc" "rackunit-lib"))
(define scribblings '(("scribblings/2019-nCov-report.scrbl" ())))
(define pkg-desc "2019-nCoV reports")
(define version "0.1")
(define pkg-authors '("Yanying Wang"))
