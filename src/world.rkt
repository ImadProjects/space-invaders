#lang racket
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
(require "actors.rkt")

(struct world (actors) #:transparent)

(define (send-to-world msg wrd)
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
	      (update-world (struct-copy world w (actors (cdr (world-actors w)))) (world (append (car (actor-update (car (world-actors w)))) (world-actors nw))))))
;(update-world  monde new-world)



(define (remove-dead-actors w)
  (define (actors_alive? x)
    (not (collisions? x (world-actors w))))
  (define p (world  
         (filter actors_alive?  (world-actors w))))
         p)

(define latest-worlds '())

(define (save-world w)
  (if (<= (length latest-worlds) 9)
        (set! latest-worlds (cons w latest-worlds))
	(set! latest-worlds (cons w (reverse (cdr (reverse latest-worlds)))))))

(define (world-travel n ancient-worlds current-world)
  (cond
      [(or (= n 0) (> n (length ancient-worlds))) current-world]
      [(>= n 2) (world-travel (sub1 n) (cdr ancient-worlds) current-world)]
      [else (car ancient-worlds)]))

(provide (struct-out world))

(provide update-world send-to-world remove-dead-actors latest-worlds save-world world-travel)

(define act (actor '(1 2) '() (fg 'red (raart:text ">>>")) "enemy"))
(define missile (actor '(1 2) '() (fg 'red (raart:text ">>>")) "projectile"))
(define monde (world (list act missile) ))
;(remove-dead-actors monde)
;(send_to_world '(move 1 1)  monde)