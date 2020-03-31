#lang racket
(require "actors.rkt" "world.rkt")

(struct runtime (world tick duree) #:transparent)


(define (game runtime1 msgs debut) ;boucle de jeu
  (cond
      [(empty? msgs) (runtime-world runtime1) ]
          [(equal? debut (runtime-duree runtime1)) (runtime-world runtime1)]
	      [else (begin (define newruntime (struct-copy runtime runtime1 (world (update-world (send_to_world (car msgs) (runtime-world runtime1)) (world '()) ))))
	                (game newruntime (cdr msgs) (+ debut (runtime-tick newruntime))))]))

(define new-world (world '()))


(define me (actor '(1 2) '((move 3 8) (move -2 -4))))
(define monde (world (list me) ))
(define rn (runtime monde 1 4))

;(game rn '((move 3 8)) 0)
(game rn '((move 3 8) (move 1 1)) 0)