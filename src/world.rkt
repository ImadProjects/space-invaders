#lang racket
(require "actors.rkt")

(struct world (actors) #:transparent)

(define (send_to_world msg wrd)
  (letrec([newworld(lambda(msg l)
           (cond
             [(null? l) '()]
             [else (cons (actor-send (car l) msg)
                   (newworld msg (cdr l)))]))])
   (world (newworld msg (world-actors wrd)))))


;(actor-send me '(move 1 1) )
;(send_to_world '(move 1 1)  monde) ; je compare le résultat avec la fonction actor-send

(define (update-world w nw)
  (if (empty? (world-actors w))
        nw
	      (update-world (struct-copy world w (actors (cdr (world-actors w)))) (world (append (actor-update (car (world-actors w))) (world-actors nw))))))
;(update-world  monde new-world);



(define (remove-dead-actors w)
  (define (actors_alive? x)
    (not (collisions? x (world-actors w))))
  (define p (world  
         (filter actors_alive?  (world-actors w))))
         p)
(provide update-world send_to_world world)


(define act (actor '(1 2) '()))
(define missile (actor '(1 2) '()))
(define monde (world (list act missile) ))
;(remove-dead-actors monde)