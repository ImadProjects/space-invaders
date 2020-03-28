#lang racket

(require racket/trace)

(struct actor (position mailbox)#:transparent)

(define me (actor '(1 2) '((move 3 8) (move -2 -4))))

(define (actor-location actor)
  (actor-position actor))

(define (actor-send new-actor new-msg)
  (struct-copy actor new-actor (mailbox (cons new-msg (actor-mailbox new-actor)))))

(define (update-position new-actor)
  (struct-copy actor new-actor (position (list
                                            (+ (car (actor-position new-actor)) (cadar (actor-mailbox new-actor)))
					                                              (+ (cadr (actor-position new-actor)) (caddar (actor-mailbox new-actor)))))
										                     (mailbox (cdr (actor-mailbox new-actor)))))

(define (actor-update new-actor)
  (new-actor-update new-actor '()))

(define (new-actor-update new-actor created-actors)
  (cond
      [(empty? (actor-mailbox new-actor)) (cons new-actor created-actors)]
      [(equal? 'create (caar (actor-mailbox new-actor)))
	       (new-actor-update (struct-copy actor new-actor (mailbox (cdr (actor-mailbox new-actor))))
	                              (cons (actor (list (cadar (actor-mailbox new-actor)) (caddar (actor-mailbox new-actor))) '()) created-actors))]
        [(equal? 'move (caar (actor-mailbox new-actor)))
					       (new-actor-update (update-position new-actor) created-actors)]
        [(equal? 'message (caar (actor-mailbox new-actor)))
						        (begin (actor-send (caddr (actor-mailbox new-actor)) (cadddr (actor-mailbox new-actor new-actor)))
						            (new-actor-update (actor (actor-position new-actor) (actor-mailbox new-actor)) created-actors))]
	[else (new-actor-update (actor (actor-position new-actor) (actor-mailbox new-actor)) created-actors)]))
									
;(trace actor-update)
;(trace actor-location)

(define mailbox? list?)
(define message? list?)
(define location? list?)
(define vactor? actor?)
(provide actor actor-location actor-send actor-update update-position actor-mailbox vactor? location? mailbox? message? new-actor-update)


(struct world (actors) #:transparent)

(struct runtime (tick world) #:transparent)

(define (send world1 message)
      (for ([i (world-actors world1)])
      (struct-copy world world1 (actors
                                    (cons (world-actors world1)
                                          (actor-send i message))))))
(define monde (world (list me) ))
(send monde '(move 1 1))


;(actor-send me '(move 1 1) )

(define (update-world w)
  (define is (world-actors w))
  (struct-copy world w [actors (map actor-update  is)]))


;(update-world  monde )

#|
(define (runtime world1 message)
  (if (null? message)
      world
      ((actor-send (car (world-actors world1) message))
       (actor-update (car (world-actors world1)))
      (struct-copy world world1 (actors
                                    (cons (world-actors (runtime ( world1 message)))
                                          (actor-update (car (world-actors world1)))))))))

                                          |#