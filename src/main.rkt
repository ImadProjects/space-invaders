#lang racket
(require "actors.rkt" "world.rkt")
(require racket/trace)
(require racket/match
         racket/format
         racket/list
         lux
         raart)
(require
  (prefix-in ct: charterm)
  (prefix-in lux: lux)
  (prefix-in raart: raart))

(struct runtime (world tick duree) #:transparent)


(define (game runtime1 msgs debut) ;boucle de jeu
  (save-world (runtime-world runtime1))
  (cond
      [(empty? msgs) (runtime-world runtime1) ]
      [(equal? debut (runtime-duree runtime1)) (runtime-world runtime1)]
	      [else (begin (define newruntime (struct-copy runtime runtime1
                           (world (update-world (send-to-world (car msgs)
                                                               (runtime-world runtime1))
                                                               		      (world '()) ))))
	                (game newruntime (cdr msgs) (+ debut (runtime-tick newruntime))))]))

(define new-world (world '()))


(define me (actor '(1 2) '((move 3 8) (move -2 -4)) (fg 'red (raart:text ">>>")) "player"))
(define monde (world (list me) ))
(define rn (runtime monde 1 4))

;(game rn '((move 3 8)) 0)
(game rn '((move 3 8) (move 1 1)) 0)

(provide (struct-out runtime) game)

(define (down run)
  (null? run)
  '()
  (struct-copy runtime run (world (send-to-world '(move 1 0) (runtime-world run)))))

(define (up run)
  (null? run)
  '()
  (struct-copy runtime run (world (send-to-world '(move -1 0) (runtime-world run)))))

(define (time run)
  (if (and (>= run 1) (< run 9))
      run
      0))

(define (time-travel n run)
  (null? run)
  '()
  (struct-copy runtime run (world (world-travel n latest-worlds (runtime-world run))) (tick 1) (duree 1)))


(provide up down time time-travel)
