#lang racket/base

(require racket/list)
(provide (all-defined-out))


(define (div-wrap h1 p-list)
  `(div ((class "sub"))
        (h1 ((style "margin-bottom: 6px;")) ,h1)
        (p ((style "margin-top: 6px;")) ,@(add-between p-list '(br)))))
