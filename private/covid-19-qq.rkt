#lang at-exp racket/base

(require racket/list racket/port racket/format racket/string racket/provide
         http-client json
         (file "parameters.rkt")
         (file "tools.rkt"))
(provide (matching-identifiers-out #rx"^qq\\/.*" (all-defined-out)))


(define res
  (http-get "https://view.inews.qq.com"
            #:path "/g2/getOnsInfo"
            #:data (hasheq 'name "disease_h5")))
(define data
  (string->jsexpr (hash-ref (http-response-body res) 'data)))
(define china-total (hash-ref data 'chinaTotal))
(define china-add (hash-ref data 'chinaAdd))
(define all-provinces (hash-ref (car (hash-ref data 'areaTree)) 'children))


;;;;;;; helpers
(define (qq/get-num node type1 type2)
  (if node
      (hash-ref (hash-ref node type1) type2)
      #f))

(define (qq/get-num* prov-name
                     #:city [city-name #f]
                     [type1 'confirm]
                     [type2 'today])
  (define province (qq/get-province prov-name city-name))
  (if province
      (hash-ref (hash-ref province type2) type1)
      #f))

(define (qq/filter-by type1 type2) ;; type1 <= { 'today 'total } type2 <= { 'confirm 'dead }
  (define sorted-provinces
    (sort all-provinces
          (lambda (i1 i2)
            (> (hash-ref (hash-ref i1 type1) type2)
               (hash-ref (hash-ref i2 type1) type2)))))
  (for/list ([i sorted-provinces])
    (cons (hash-ref i 'name)
          (hash-ref (hash-ref i 'today) 'confirm)))
  )

(define (qq/get-province name [city-name #f])
  (and (symbol? name)
       (set! name (symbol->string name)))
  (and (symbol? city-name)
       (set! city-name (symbol->string city-name)))
  (define province (findf (lambda (i)
                            (equal? (hash-ref i 'name) name))
                          all-provinces))
  (if city-name
      (findf (lambda (i)
           (equal? (hash-ref i 'name) city-name))
             (hash-ref province 'children))
      province)
  )



(define qq/provinces/today/confirm
  (qq/filter-by 'today 'confirm))
;; (define qq/provinces all-provinces)
(define henan (qq/get-province "河南"))
(define zhengzhou (qq/get-province "河南" "郑州"))
(define shanghai (qq/get-province "上海"))


(define qq/domestic/overall
  (cons "概览"
        (list @~a{全国今日新增确诊：@(hash-ref china-add 'confirm)人，}
              @~a{全国今日治愈：@(hash-ref china-add 'heal)人，}
              @~a{全国今日死亡：@(hash-ref china-add 'dead)人。}
              @~a{河南今日新增确诊：@(qq/get-num (qq/get-province '河南) 'today 'confirm)人，}
              @~a{其中郑州：@(qq/get-num (qq/get-province '河南 '郑州) 'today 'confirm)人。}
              @~a{上海今日新增确诊：@(qq/get-num (qq/get-province '上海) 'today 'confirm)人， }
              @~a{其中境外输入：@(qq/get-num (qq/get-province '上海 '境外输入) 'today 'confirm)人。}
              ))
  )

(define qq/domestic/top10
  (cons "国内新增前十（确诊）"
        (list @~a{@(car (first qq/provinces/today/confirm))：@(cdr (first qq/provinces/today/confirm))（其中境外输入@(qq/get-num (qq/get-province (car (first qq/provinces/today/confirm)) "境外输入") 'today 'confirm)）人，}
              @~a{@(car (second qq/provinces/today/confirm))：@(cdr (second qq/provinces/today/confirm))（其中境外输入@(qq/get-num (qq/get-province (car (second qq/provinces/today/confirm)) "境外输入") 'today 'confirm)）人，}
              @~a{@(car (third qq/provinces/today/confirm))：@(cdr (third qq/provinces/today/confirm))（其中境外输入@(qq/get-num (qq/get-province (car (third qq/provinces/today/confirm)) "境外输入") 'today 'confirm)）人，}
              @~a{@(car (fourth qq/provinces/today/confirm))：@(cdr (fourth qq/provinces/today/confirm))（其中境外输入@(qq/get-num (qq/get-province (car (fourth qq/provinces/today/confirm)) "境外输入") 'today 'confirm)）人，}
              @~a{@(car (fifth qq/provinces/today/confirm))：@(cdr (fifth qq/provinces/today/confirm))（其中境外输入@(qq/get-num (qq/get-province (car (fifth qq/provinces/today/confirm)) "境外输入") 'today 'confirm)）人。}
              @~a{@(car (sixth qq/provinces/today/confirm))：@(cdr (sixth qq/provinces/today/confirm))（其中境外输入@(qq/get-num (qq/get-province (car (sixth qq/provinces/today/confirm)) "境外输入") 'today 'confirm)）人，}
              @~a{@(car (seventh qq/provinces/today/confirm))：@(cdr (seventh qq/provinces/today/confirm))（其中境外输入@(qq/get-num (qq/get-province (car (seventh qq/provinces/today/confirm)) "境外输入") 'today 'confirm)）人，}
              @~a{@(car (eighth qq/provinces/today/confirm))：@(cdr (eighth qq/provinces/today/confirm))（其中境外输入@(qq/get-num (qq/get-province (car (eighth qq/provinces/today/confirm)) "境外输入") 'today 'confirm)）人，}
              @~a{@(car (ninth qq/provinces/today/confirm))：@(cdr (ninth qq/provinces/today/confirm))（其中境外输入@(qq/get-num (qq/get-province (car (ninth qq/provinces/today/confirm)) "境外输入") 'today 'confirm)）人，}
              @~a{@(car (tenth qq/provinces/today/confirm))：@(cdr (tenth qq/provinces/today/confirm))（其中境外输入@(qq/get-num (qq/get-province (car (tenth qq/provinces/today/confirm)) "境外输入") 'today 'confirm)）人。}
              ))
  )
