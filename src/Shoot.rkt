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



;-----------question2 il faut qu'on la mettre dans le fichier qui correspond
(struct world (actors) #:transparent)
(struct runtime (world tick duree))

(define (send_to_world msg wrd)
  (letrec([newworld(lambda(msg l)
           (cond
             [(null? l) '()]
             [else (cons (actor-send (car l) msg)
                   (newworld msg (cdr l)))]))])
   (world (newworld msg (world-actors wrd)))))
(define monde (world (list me) ))



(actor-send me '(move 1 1) )
(send_to_world '(move 1 1)  monde) ; je compare le résultat avec la fonction actor-send
(define (update-world w)
  (define is (world-actors w))
  (struct-copy world w [actors (map actor-update  is)]))


(update-world  monde ); faire jouer les acteurs 

;-------------------------------------------------------------------------
