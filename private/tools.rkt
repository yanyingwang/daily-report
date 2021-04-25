#lang racket/base

(require racket/list)
(provide (all-defined-out))


(define (div-wrap h ps)
  `(div ((class "sub"))
        (h2 ((style "margin-bottom: 6px;")) ,h)
        (p ((style "margin-top: 6px;")) ,@(add-between ps '(br)))))
