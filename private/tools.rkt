#lang racket/base

(require racket/list racket/file racket/path net/base64)
(provide (all-defined-out))


(define (div-wrap h+ps)
  `(div ((class "sub"))
        (h2 ((style "margin-bottom: 6px;")) ,(car h+ps))
        (p ((style "margin-top: 6px;")) ,@(add-between (cdr h+ps) '(br)))))

(define (div-wrap/+img h+ps img-file)
  `(div ((class "row"))
        (div ((class "text"))
         (h2 ((id "indent-10")) ,(car h+ps)))
        (div ((class "chart"))
             (img ((src ,(html-base64-en img-file)) (alt "Chart") (class "responsive"))))
        (div ((class "text"))
             (p  ,@(add-between (cdr h+ps) '(br))))))

(define (html-base64-en f)
  (format "data:image/~a;base64, ~a"
          (subbytes (path-get-extension f) 1)
          (base64-encode (file->bytes f))))

(define (->plot-format lst)
  (for/list ([l lst])
    (vector (car l) (cdr l))))

;; (require racket/trace)
;; (trace ->plot-format)