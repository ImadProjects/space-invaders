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

(struct actor (position mailbox name category)#:transparent)

(define me (actor '(1 2) '((move 3 8) (create 5 5 "1") (move -2 -4)) (fg 'red (raart:text ">>>") ) "player"))

(define (name-of-actor actor)
  (actor-name actor))

(define (actor-location actor)
  (actor-position actor))
  
(define (actor-send new-actor new-msg)
  (struct-copy actor new-actor (mailbox (cons new-msg (actor-mailbox new-actor)))))

(define (x-position-top-mail actor)
  (cadar (actor-mailbox actor)))

(define (y-position-top-mail actor)
  (caddar (actor-mailbox actor)))

(define (update-position new-actor)
  (struct-copy actor new-actor (position (list
                                            (+ (car (actor-position new-actor)) (x-position-top-mail new-actor))
					                                              (+ (cadr (actor-position new-actor)) (y-position-top-mail new-actor))))
										                     (mailbox (cdr (actor-mailbox new-actor)))))

(define (actor-update new-actor)
  (new-actor-update new-actor '() '()))

(define (new-actor-update new-actor created-actors created-messages)
  (cond
      [(empty? (actor-mailbox new-actor)) (cons (cons new-actor created-actors) created-messages)]
      [(equal? 'create (caar (actor-mailbox new-actor)))
       (new-actor-update (struct-copy actor new-actor (mailbox (cdr (actor-mailbox new-actor))))
                         (cons (actor (list (x-position-top-mail new-actor) (y-position-top-mail new-actor))
                                      '()
                                      (fg 'blue (raart:text "*")) "created") created-actors) created-messages)]
        [(equal? 'move-enemy (caar (actor-mailbox new-actor)))
         (if (equal? (actor-category new-actor) "enemy")
             (new-actor-update (update-position new-actor) created-actors created-messages)
             (new-actor-update (struct-copy actor new-actor (mailbox (cdr (actor-mailbox new-actor)))) created-actors created-messages))]
        [(equal? 'move (caar (actor-mailbox new-actor)))
         (if (equal? (actor-category new-actor) "player")
             (new-actor-update (update-position new-actor) created-actors created-messages)
             (new-actor-update (struct-copy actor new-actor (mailbox (cdr (actor-mailbox new-actor)))) created-actors created-messages))]
        [(equal? 'move-projectile (caar (actor-mailbox new-actor)))
         (if (equal? (actor-category new-actor) "projectile")
             (new-actor-update (update-position new-actor) created-actors created-messages)
             (new-actor-update (struct-copy actor new-actor (mailbox (cdr (actor-mailbox new-actor)))) created-actors created-messages))]
        [(equal? 'message (caar (actor-mailbox new-actor)))
         (new-actor-update (struct-copy actor new-actor (mailbox (cdr (actor-mailbox new-actor))))
                           created-actors (cons (cdar (actor-mailbox new-actor)) created-messages)) ]
	[else (new-actor-update (actor (actor-position new-actor) (cdr (actor-mailbox new-actor))
                                       (actor-name new-actor) (actor-category new-actor)) created-actors created-messages)]))
									
;(trace actor-update)
;(trace actor-location)

(define mailbox? list?)
(define message? list?)
(define location? list?)
(define vactor? actor?)


;Normalement nos acteurs occuperons un espace repéré par les coordonnées cartésiennes
;des points extremes on doit penser alors à ajouter cela dans la structure 
;actors mais pour l'instant on va les repérer qu'avec une seule coordonnée.
;Dans ce cas, la fonction colliding est simple.
(define (colliding? actor1 actor2)
  (if (equal? (actor-position actor1) (actor-position actor2))
  #t
  #f))
(define (collisions? x list-actors)
   (for/or ([i list-actors]) (colliding? x i)))

(provide actor name-of-actor actor-location collisions? actor-category y-position-top-mail x-position-top-mail actor-send actor-update update-position actor-mailbox vactor? location? mailbox? message? new-actor-update colliding? collisions?)



(define mc (actor '(5 4) '((move 3 8) (create 5 5 "1") (move -2 -4)) (fg 'red (raart:text ">>>") ) "player"))

;(colliding? me me)
;(collisions? me (list mc mc))
;(collisions? me '())

;(colliding? me mc)

;(any-collision? (list me mc))
;(define rené (actor '(1 2) '((create 5 5 "1") (move 3 8) (message create 1 1)) "rené"))
;(actor-update rené)
