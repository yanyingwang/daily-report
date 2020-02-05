#!/usr/bin/env racket
#lang racket/base

(module+ test
  (require rackunit))

;; Notice
;; To install (from within the package directory):
;;   $ raco pkg install
;; To install (once uploaded to pkgs.racket-lang.org):
;;   $ raco pkg install <<name>>
;; To uninstall:
;;   $ raco pkg remove <<name>>
;; To view documentation:
;;   $ raco docs <<name>>
;;
;; For your convenience, we have included LICENSE-MIT and LICENSE-APACHE files.
;; If you would prefer to use a different license, replace those files with the
;; desired license.
;;
;; Some users like to add a `private/` directory, place auxiliary files there,
;; and require them in `main.rkt`.
;;
;; See the current version of the racket style guide here:
;; http://docs.racket-lang.org/style/index.html

;; Code here


(require request
         net/http-client
         html-parsing
         xml
         xml/path
         racket/file)






#;(let-values (((status headers in) (http-sendrecv "arademaker.github.io"
                                                   "/about.html")))
  (html->xexp in))



(define-values (status headers in)
  (http-sendrecv "m.medsci.cn"
                 "/wh.asp"
                 ;;#:ssl? #t
                 ;;#:version "1.1"
                 ;;#:method "GET"
                 ;;#:data "Hello"
                 ))

(displayln status)
(displayln headers)
(displayln (port->string in))



(define news-qq-com
  (make-domain-requester "news.qq.com" (make-https-requester http-requester)))

(define result (html->xexp (http-response-body (get news-qq-com "/zt2020/page/feiyan.htm"))))

#;(display-to-file (se-path*/list '(p span) result) "/Users/yanying/abc.txt")
(display-to-file  (http-response-body (get news-qq-com "/zt2020/page/feiyan.htm")) "/Users/yanying/abc.html")

#;(class "clearfix placeItem placeArea")

#;(html->xexp "<div class='clearfix placeItem placeArea'>
<h2 class='blue'>河南</h2>
<div class='add ac_add' >89</div>
<div class='confirm'>764</div>
<div class='heal'>49</div>
<div class='dead'>2</div>
</div>")



(module+ test
  ;; Any code in this `test` submodule runs when this file is run using DrRacket
  ;; or with `raco test`. The code here does not run when this file is
  ;; required by another module.

  (check-equal? (+ 2 2) 4))

(module+ main
  ;; (Optional) main submodule. Put code here if you need it to be executed when
  ;; this file is run using DrRacket or the `racket` executable.  The code here
  ;; does not run when this file is required by another module. Documentation:
  ;; http://docs.racket-lang.org/guide/Module_Syntax.html#%28part._main-and-test%29

  (require racket/cmdline)
  (define who (box "world"))
  (command-line
   #:program "my-program"
   #:once-each
   [("-n" "--name") name "Who to say hello to" (set-box! who name)]
   #:args ()
   (printf "hello ~a~n" (unbox who))))
