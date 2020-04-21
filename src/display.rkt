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

(define-values (term-cols term-rows)
  (ct:with-charterm (ct:charterm-screen-size)))


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

	     ["&" (struct-copy MyDisplay w (run (time-travel-runtime (time 5) latest-runtimes (MyDisplay-run w))))]
             ["é" (struct-copy MyDisplay w (run (time-travel (time 2) latest-worlds (MyDisplay-run w))))]

             [" " (struct-copy MyDisplay w (run (shoot (MyDisplay-run w) (MyDisplay-pos w))) (pos (+ 0 (MyDisplay-pos w))))
           ]

             ["'" (struct-copy MyDisplay w (run (time-travel (time 3) latest-worlds (MyDisplay-run w))))]
             ["8" (struct-copy MyDisplay w (run (time-travel (time 8) latest-worlds (MyDisplay-run w))))] 
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
                              (name-of-actor actor )))))  )        
         (define (word-tick w)        ;; Update function after one tick of time
           (match-define (MyDisplay run pos) w)
           (define msg1 (list '(move-projectile 0 1) '(move 0 1) '(move 1 1) '(move 2 2)))
           (define msg2 (list '(move-enemy 0 75) '(move 0 1)))
           (define run1 (runtime (game run msg1 0) 1 (runtime-duree run))) ;Pour les acteurs qui ne sont pas morts on les fait revenir de l'autre coté
           (define run2 (runtime (game run msg2 0) 1 (runtime-duree run)))

           (if (in-window? (MyDisplay-run w))
               (MyDisplay run1 (MyDisplay-pos w))
               (MyDisplay run2 (MyDisplay-pos w))))
         ])
             
           
           
(provide (struct-out MyDisplay))

;;;;;;;;;;;;;;;;;;;;;;;


(define me (actor '(4 10) '() (fg 'red (raart:text ">")) "player"))
(define ma (actor '(4 19) '() (fg 'blue (raart:text "*")) "projectile"))
(define mo (actor '(3 75) '() (fg 'green (raart:text "<<<")) "enemy"))
(define mi (actor '(4 55) '() (fg 'white (raart:text "<<<")) "enemy"))
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