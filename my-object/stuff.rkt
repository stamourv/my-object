#lang racket/base

(provide (all-defined-out))

(require syntax/parse/define
         racket/splicing
         (for-syntax racket/base
                     syntax/parse
                     unstable/syntax
                     ))

(define-simple-macro (defrename [id1:id id2:id] ...)
  (begin (define-syntax id1 (make-rename-transformer #'id2)) ...))

(define-simple-macro (define-syntax-parser id opt-or-clause ...)
  (define-syntax id (syntax-parser opt-or-clause ...)))

(define-simple-macro (def-var-like-trans id:id stx-expr:expr)
  (define-syntax id (make-variable-like-transformer stx-expr)))

(begin-for-syntax
  (define-syntax-class maybe-inner/outer
    [pattern [outer-id:id inner-id:id]]
    [pattern inner-id:id #:with outer-id #'inner-id]))
(define-simple-macro
  (defs-renamed (:maybe-inner/outer ...)
    def:expr ...)
  #:with (tmp-id ...) (generate-temporaries #'(inner-id ...))
  (begin
    (splicing-local
        [def ...]
      (defrename [tmp-id inner-id] ...))
    (defrename [outer-id tmp-id] ...)))
