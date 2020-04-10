#lang racket
(require racket/contract)
(require "main.rkt")
(require "world.rkt")
(require "actors.rkt")


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


(struct MyDisplay (run)
        #:methods lux:gen:word
        [(define (word-fps w)      ;; FPS desired rate
           10.0)
         (define (word-label s ft) ;; Window label of the application
           "JUST ASCII IT!")
         (define (word-event w e)  ;; Event Handler
           (match e
             ["q" #f]  ;; Quit the application
             ["0" (struct-copy MyDisplay w (run (down (MyDisplay-run w)))) ]
             ["2" (struct-copy MyDisplay w (run (up (MyDisplay-run w))))]
	     ["&" (struct-copy MyDisplay w (run (time-travel (time 1) (MyDisplay-run w))))]
             ["é" (struct-copy MyDisplay w (run (time-travel (time 2) (MyDisplay-run w))))]
             ["'" (struct-copy MyDisplay w (run (time-travel (time 3) (MyDisplay-run w))))]
             ["8" (struct-copy MyDisplay w (run (time-travel (time 4) (MyDisplay-run w))))] 
             [_   w]   ;; Otherwise do nothing
         ))
         (define (word-output w)      ;; What to display for the application
           (match-define (MyDisplay run) w)
       
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
           (match-define (MyDisplay run ) w)
           (remove-dead-actors (runtime-world run))
           (define msg (list '(move 0 1)))
           (define run1 (runtime (game run msg 0) 1 (runtime-duree run)))
           (MyDisplay run1))
         ])
             
           
           
(provide (struct-out MyDisplay))

;;;;;;;;;;;;;;;;;;;;;;;


(define me (actor '(1 1) '() (fg 'red (raart:text ">")) "player"))
(define ma (actor '(2 1) '() (fg 'blue (raart:text ">>")) "player"))
(define mo (actor '(3 1) '() (fg 'green (raart:text ">>>")) "player"))
(define mi (actor '(4 1) '() (fg 'white (raart:text ">>>>")) "player"))
(define monde (world (list me) ))
(define rn (runtime monde 1 1))

;; Starter function
(define (start-application)
  (lux:call-with-chaos
   (raart:make-raart)
   (lambda () (lux:fiat-lux (MyDisplay rn ))))
  (void))

(start-application)
