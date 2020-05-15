#lang racket
(require racket/contract)
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


(define gameover (actor '(13 45) '() (fg 'red (raart:text "GAME OVER")) "projectile"))
(define over (world (list gameover) ))

(struct runtime (world0 tick health InOut) 
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
             
             ["n" (struct-copy runtime w (InOut 1))]
             [" "        (struct-copy runtime w (world0 (execute-msg (runtime-world0 w) (cons 'create (shoot (runtime-world0 w))) "player")))]
             [_  w]   ;; Otherwise do nothing
         ))
         
         (define (word-output w)      ;; What to display for the application
           (match-define (runtime world0 tick health InOut) w)
                     (crop y1 (+ 5 y2) x1 (+ 10 x2)
                           (cond
                             [(= 1 InOut)
                              (vappend
                               #:halign 'left
                               (text (~a "Hello! Enjoy it! Press q to quit."))
                               
                               (raart:frame (for/fold ([c (raart:blank  y2 x2)])
                                                      ([actor (in-list (world-actors world0))])
                                              (raart:crop y1 y2 x1 (+ 3 x2)
                                                           (raart:place-at c
                                                                           (car (actor-location actor))
                                                                           (cadr (actor-location actor))
                                                                           (name-of-actor actor)))))
                               (happend (text (~a "Health: " (runtime-health w)  " Score: " (runtime-tick w))))
                               )]
                             [(= 0 InOut)
                              (raart:vappend*
                               #:halign 'center
                               (map raart:text logo-lines))]
                             [(= 2 InOut)
                              (vappend
                               #:halign 'center
                               (raart:vappend*
                                #:halign 'center
                                (map raart:text logo-lines2))
                               (text (~a "                     Your score is:  " (runtime-tick w))))
                              ]
                             )))
         
         (define (word-tick w)        ;; Update function after one tick of time
           (match-define (runtime world0 tick health InOut) w)
           (define monde (game (runtime-world0 w) (runtime-tick w)))
            (if (player-dead? monde)
                 (runtime monde (runtime-tick w) (runtime-health w) 2)
                 (runtime monde (add1 (runtime-tick w)) health (runtime-InOut w))))])
          
             
           
      

;;;;;;;;;;;;;;;;;;;;;;;


(define me (actor '(1 0) '() (fg 'red (raart:text ">")) "player"))
(define monde (world (list me) ))


;; Starter function
(define (start-application)
  (lux:call-with-chaos
   (raart:make-raart)
   (lambda () (lux:fiat-lux (runtime monde 0 1 0))))
  (void))

(start-application)
(provide start-application)