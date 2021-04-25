#lang racket/base

(require racket/list)
(provide (all-defined-out))


(define (div-wrap h1 p-list)
  `(div (h1 ,h1)
        (p ,@(add-between p-list '(br)))))
