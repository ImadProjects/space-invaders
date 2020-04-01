#lang racket
(require racket/contract)
(require "main.rkt")
(require "world.rkt")
(require "actors.rkt")
(define msgs (list '(move 1 2)))

(require racket/match
         racket/format
         racket/list
         lux
         raart)
(require
  (prefix-in ct: charterm)
  (prefix-in lux: lux)
  (prefix-in raart: raart))

(define rows 24)
(define cols 80)
(define world-rows (- rows 3))
(define world-cols cols)


(struct display (run)
        #:methods lux:gen:word
        [(define (word-fps w)      ;; FPS desired rate
           10.0)
         (define (word-label s ft) ;; Window label of the application
           "JUST ASCII IT!")
         (define (word-event w e)  ;; Event Handler
           (match e
             ["q" #f]  ;; Quit the application
             [_   w]   ;; Otherwise do nothing
         ))
         (define (word-output w)      ;; What to display for the application
           (match-define (display run) w)
       
           (crop 0 cols 0 rows
                 (vappend
                  #:halign 'left
                  (text (~a "Hello! Enjoy it! Press q to quit."))
                  (for/fold ([c (blank world-cols world-rows)])
                            ([actor (in-list (world-actors (runtime-world run)))])
                    (place-at c
                              (car (actor-location actor))
                              (cadr (actor-location actor))
                              (name-of-actor actor ))))))
         (define (word-tick w)        ;; Update function after one tick of time
           (match-define (display run ) w)

           (define msg (list '(move 0 1)))
           (define run1 (runtime (game run msg 0) 1 4))
           (display run1))
         ])
             
           
           
(provide (struct-out display))

;;;;;;;;;;;;;;;;;;;;;;;


(define me (actor '(1 1) '((move 3 8) (move -2 -4)) (fg 'red (raart:text ">"))))
(define ma (actor '(2 1) '((move 3 8) (move -2 -4)) (fg 'blue (raart:text ">>"))))
(define mo (actor '(3 1) '((move 3 8) (move -2 -4)) (fg 'green (raart:text ">>>"))))
(define mi (actor '(4 1) '((move 3 8) (move -2 -4)) (fg 'white (raart:text ">>>>"))))
(define monde (world (list me ma mo mi) ))
(define rn (runtime monde 1 4))

;; Starter function
(define (start-application)
  (lux:call-with-chaos
   (raart:make-raart)
   (lambda () (lux:fiat-lux (display rn ))))
  (void))

(start-application)
