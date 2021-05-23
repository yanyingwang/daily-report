#lang racket/base

(require racket/list)
(provide (all-defined-out))


(define (div-wrap h+ps)
  `(div ((class "sub"))
        (h2 ((style "margin-bottom: 6px;")) ,(car h+ps))
        (p ((style "margin-top: 6px;")) ,@(add-between (cdr h+ps) '(br)))))

(define (div-wrap-with-img h+ps img)
  `(div ((class "row"))
        (div ((class "text"))
         (h2 ((id "indent-10")) ,(car h+ps)))
        (div ((class "chart"))
             (img ((src ,img) (alt "Nature") (class "responsive"))))
        (div ((class "text"))
             (p  ,@(add-between (cdr h+ps) '(br))))))

(define (->plot-format lst)
  (for/list ([l lst])
    (vector (car l) (cdr l))))

;; (require racket/trace)
;; (trace ->plot-format)