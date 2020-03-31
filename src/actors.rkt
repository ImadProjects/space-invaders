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


;Normalement nos acteurs occuperons un espace repéré par les coordonnées cartésiennes des points extremes on doit penser alors à ajouter cela dans la structure 
;actors mais pour l'instant on va les repérer qu'avec une seule coordonnée.  Dans ce cas, la fonction colliding est simple.
(define (colliding? actor1 actor2)
  (if (equal? (actor-position actor1) (actor-position actor2))
  #t
  #f))
(define (collisions? x list_actors)
   (for/or ([i list_actors]) (colliding? x i)))

(provide actor actor-location actor-send actor-update update-position actor-mailbox vactor? location? mailbox? message? new-actor-update colliding? collisions?)

;(colliding? me me)
;(collisions? me (list me me))
;(collisions? me '())
