#lang racket
(require "runtime.rkt")
(require "contract.rkt")
(require "logo.rkt")
(require racket/match
         racket/format
         racket/list
         lux
         raart)
(require
  (prefix-in ct: charterm)
  (prefix-in lux: lux)
  (prefix-in raart: raart))


(struct world (tick)
        #:methods lux:gen:word
        [(define (word-fps w)      ;; FPS desired rate
           10.0)
         (define (word-label s ft) ;; Window label of the application
           "JUST ASCII IT!")
         (define (word-event w e)  ;; Event Handler
           (match e
             ["q" #f]  ;; Quit the application
             [" " (start-application)]
             [_   w]   ;; Otherwise do nothing
         ))
         
         (define (word-output w)      ;; What to display for the application
                 (raart:vappend*
                  #:halign 'center
                  (map raart:text logo-lines)))
         
         (define (word-tick w)        ;; Update function after one tick of time
           (match-define (world tick) w)
           (world (+ 1 tick)))
         ])

;; Starter function
(define (start-game)
  (lux:call-with-chaos
   (raart:make-raart)
   (lambda () (lux:fiat-lux (world 0))))
  (void))

(start-game)
