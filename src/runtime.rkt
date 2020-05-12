#lang racket
(require racket/contract)
;(require "world.rkt")
;(require "actors.rkt")
(require "contract.rkt")

(require racket/match
         racket/format
         racket/list
         lux
         raart)
(require
  (prefix-in ct: charterm)
  (prefix-in lux: lux)
  (prefix-in raart: raart))

;; Get the terminal dimensions
(define-values (term-cols term-rows)
  (ct:with-charterm (ct:charterm-screen-size)))

(define rows 60)
(define cols y2)
(define world-rows x2)
(define world-cols y2)

(define gameover (actor '(12 55) '() (fg 'red (raart:text "GAME OVER")) "projectile"))

(define over (world (list gameover) ))

(struct runtime (world0 tick health) 
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
             ["r" (struct-copy runtime w (world0 monde))]
             ["p" (struct-copy runtime w (world0 (world-travel 15 (runtime-world0 w))))]
             
             [" "        (struct-copy runtime w (world0 (execute-msg (runtime-world0 w) (cons 'create (shoot (runtime-world0 w))) "player")))]
             [_  w]   ;; Otherwise do nothing
         ))
         (define (word-output w)      ;; What to display for the application
           (match-define (runtime world0 tick health) w)
           
           (crop y1 (+ 5 y2) x1 (+ 10 x2)
                 (vappend
                  #:halign 'left
                  (text (~a "Hello! Enjoy it! Press q to quit."))
                  
                  (raart:frame (for/fold ([c (raart:blank  world-cols world-rows)])
                                         ([actor (in-list (world-actors world0))])
                                 (raart:crop y1 y2 x1 (+ 3 x2)
                                             (raart:place-at c
                                                             (car (actor-location actor))
                                                             (cadr (actor-location actor))
                                                             (name-of-actor actor)))))
                  (happend (text (~a "Health: " (runtime-health w)  " Score: " (runtime-tick w))))
                  )))        
         (define (word-tick w)        ;; Update function after one tick of time
           (match-define (runtime world0 tick health) w)
           (save-world (runtime-world0 w))
           (define mo (execute-msg (world-alive (runtime-world0 w)) '(move 0 0) "enemy"))
           (define mon (struct-copy world mo (actors (append (world-actors mo) (generate (runtime-tick w) )))))
           (define mond (execute-msg mon '(move 0 1) "created"))
           (define monde (execute-msg mond '(move 0 -1) "enemy"))
            (if (player-dead? (runtime-world0 w))
                 (runtime over (runtime-tick w) health)
                 (runtime monde (add1 (runtime-tick w)) health)))])
          
             
           
      

;;;;;;;;;;;;;;;;;;;;;;;


(define me (actor '(1 0) '() (fg 'red (raart:text ">")) "player"))
(define monde (world (list me) ))


;; Starter function
(define (start-application)
  (lux:call-with-chaos
   (raart:make-raart)
   (lambda () (lux:fiat-lux (runtime monde 0 1))))
  (void))

(start-application)
;             (MyDisplay-pos w)
     ;        (cadr (actor-location (car (world-actors (runtime-world (MyDisplay-run w) )))))