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


(struct MyDisplay (run pos) ;pos: position du curseur ou du dernier missile tiré ? à revoir 
        #:methods lux:gen:word
        [(define (word-fps w)      ;; FPS desired rate
           10.0)
         (define (word-label s ft) ;; Window label of the application
           "JUST ASCII IT!")
         (define (word-event w e)  ;; Event Handler
           (match e
             ["q" #f]  ;; Quit the application
             ["<down>" (struct-copy MyDisplay w (run (down (MyDisplay-run w))) (pos 1))]
             ["<up>" (struct-copy MyDisplay w (run (up (MyDisplay-run w))) (pos 1))]

              ["<left>" (struct-copy MyDisplay w (run (left (MyDisplay-run w)))  )]
                ["<right>" (struct-copy MyDisplay w (run (right (MyDisplay-run w))))]

	     ["&" (struct-copy MyDisplay w (run (time-travel (time 1) (MyDisplay-run w))))]
             ["é" (struct-copy MyDisplay w (run (time-travel (time 2) (MyDisplay-run w))))]

             [" " (struct-copy MyDisplay w (run (shoot (MyDisplay-run w) (MyDisplay-pos w))) (pos (+ 3 (MyDisplay-pos w))))
           ]

             ["'" (struct-copy MyDisplay w (run (time-travel (time 3) (MyDisplay-run w))))]
             ["8" (struct-copy MyDisplay w (run (time-travel (time 8) (MyDisplay-run w))))] 
             [_   w]   ;; Otherwise do nothing
         ))
         (define (word-output w)      ;; What to display for the application
           (match-define (MyDisplay run pos) w)
       
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
           (match-define (MyDisplay run pos) w)
           (define msg (list '(move-enemy 0 -1) '(move 0 1)))
           (define run1 (runtime (game run msg 0) 1 (runtime-duree run)))
           (MyDisplay run1 (MyDisplay-pos w)))
         ])
             
           
           
(provide (struct-out MyDisplay))

;;;;;;;;;;;;;;;;;;;;;;;


(define me (actor '(4 10) '() (fg 'red (raart:text ">")) "player"))
(define ma (actor '(2 75) '() (fg 'blue (raart:text "<<")) "enemy"))
(define mo (actor '(3 75) '() (fg 'green (raart:text "<<<")) "enemy"))
(define mi (actor '(4 75) '() (fg 'white (raart:text "<<<")) "enemy"))
(define m1 (actor '(5 75) '() (fg 'white (raart:text "<<<")) "enemy"))
(define m2 (actor '(6 75) '() (fg 'white (raart:text "<<<")) "enemy"))
(define m3 (actor '(7 75) '() (fg 'white (raart:text "<<<")) "enemy"))
(define m4 (actor '(8 75) '() (fg 'white (raart:text "<<<")) "enemy"))
(define monde (world (list me ma mo mi m1 m2 m3 m4) ))
(define rn (runtime monde 1 1))

;; Starter function
(define (start-application)
  (lux:call-with-chaos
   (raart:make-raart)
   (lambda () (lux:fiat-lux (MyDisplay rn 1))))
  (void))

(start-application)
;             (MyDisplay-pos w)
     ;        (cadr (actor-location (car (world-actors (runtime-world (MyDisplay-run w) )))))