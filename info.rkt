#lang info
(define collection "report-covid-19")
(define deps '("base" "at-exp-lib" "r6rs-lib" "gregor-lib"))
(define build-deps '("scribble-lib" "racket-doc" "rackunit-lib"))
(define scribblings '(("scribblings/2019-nCov-report.scrbl" ())))
(define pkg-desc "2019-nCon SMS reports")
(define version "0.1")
(define pkg-authors '("Yanying Wang"))
