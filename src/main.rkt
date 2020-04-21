#lang racket
(require racket/contract)
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



(struct runtime (world0) ;pos: position du curseur ou du dernier missile tiré ? à revoir 
        #:methods lux:gen:word
        [(define (word-fps w)      ;; FPS desired rate
           10.0)
         (define (word-label s ft) ;; Window label of the application
           "JUST ASCII IT!")
         (define (word-event w e)  ;; Event Handler
           (match e
             ["q" #f]  ;; Quit the application
             ["<down>"   (struct-copy runtime w (world0 (execute-msg (runtime-world0 w) '(move 1 0) "player")))]
             ["<up>"     (struct-copy runtime w (world0 (execute-msg (runtime-world0 w) '(move -1 0) "player")))]
             ["<right>"  (struct-copy runtime w (world0 (execute-msg (runtime-world0 w) '(move 0 1) "player")))]
             ["<left>"   (struct-copy runtime w (world0 (execute-msg (runtime-world0 w) '(move 0 -1) "player")))]
             
             ["8" (struct-copy runtime w (world0 (world-travel 8 (runtime-world0 w))))]
             
             [" "        (struct-copy runtime w (world0 (execute-msg (runtime-world0 w) (cons 'create (shoot (runtime-world0 w))) "player")))]
             [_  w]   ;; Otherwise do nothing
         ))
         (define (word-output w)      ;; What to display for the application
           (match-define (runtime world0) w)
           
           (crop 0 cols 0 rows
                 (vappend
                  #:halign 'left
                  (text (~a "Hello! Enjoy it! Press q to quit."))
                  (for/fold ([c (blank world-cols world-rows)])
                            ([actor (in-list (world-actors world0))])
                    (place-at c
                              (car (actor-location actor))
                              (cadr (actor-location actor))
                              (name-of-actor actor )))))  )        
         (define (word-tick w)        ;; Update function after one tick of time
           (match-define (runtime world0) w)
           (save-world (runtime-world0 w))
           (define mon (execute-msg (world-alive (runtime-world0 w)) '(move 0 0) "enemy"))
           (define mond (execute-msg mon '(move 0 1) "created"))
           (runtime mond))])
         
             
           
      

;;;;;;;;;;;;;;;;;;;;;;;


(define me (actor '(3 3) '() (fg 'red (raart:text ">")) "player"))
(define ma (actor '(1 40) '() (fg 'blue (raart:text "<<")) "enemy"))
(define mo (actor '(2 50) '() (fg 'green (raart:text "<<<")) "enemy"))
(define mi (actor '(3 60) '() (fg 'white (raart:text "<<<")) "enemy"))
(define monde (world (list me ma mo mi ) ))

;; Starter function
(define (start-application)
  (lux:call-with-chaos
   (raart:make-raart)
   (lambda () (lux:fiat-lux (runtime monde ))))
  (void))

(start-application)
;             (MyDisplay-pos w)
     ;        (cadr (actor-location (car (world-actors (runtime-world (MyDisplay-run w) )))))