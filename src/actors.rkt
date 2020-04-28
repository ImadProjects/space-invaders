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

;;;;;;;;;;;;;;;;;; Actor structure and functions ;;;;;;;;;;;;

(struct actor (position mailbox name category)#:transparent)

(define (name-of-actor player)
  (actor-name player))

(define (actor-location player)
  (actor-position player))

(define (actor-send player new-msg)
  (struct-copy actor player (mailbox
                                (cons new-msg
                                      (actor-mailbox player)))))

(define (x-pos-top-mail player)
  (cadar (actor-mailbox player)))

(define (y-pos-top-mail player)
  (caddar (actor-mailbox player)))

(define (update-position player)
  (struct-copy actor player (position
                                (list
                                 (+
                                  (car (actor-position player))
                                  (x-pos-top-mail player))
                                 (+ (cadr (actor-position player))
                                    (y-pos-top-mail player))))
               (mailbox (cdr (actor-mailbox player)))))

(define (actor-update player)
  (letrec ([update (lambda (new-player created-players created-msg)
                     (cond
                       ;;;;; If there is no msg ;;;;;
                       [(empty? (actor-mailbox new-player))
                        (cons new-player created-players)]
                       ;;;;; If the msg is: '(create x y) ;;;;;
                       [(equal? 'create (caar (actor-mailbox new-player)))
                        (update (struct-copy actor new-player (mailbox (cdr               ; our player
                                                                        (actor-mailbox new-player)))) 
                                (cons (actor (list (x-pos-top-mail new-player)
                                                   (y-pos-top-mail new-player))
                                             '() ; 0 msg
                                             (fg 'blue (raart:text "*")) ; name
                                             "created" ;category
                                             ) created-players)
                                created-msg)]
                       
                       ;;;;; If the msg is '(move x y) ;;;;;
                       [(equal? 'move (caar (actor-mailbox new-player)))
                        (update (update-position new-player) created-players created-msg)]
                       
                       ;;;;; If the msg is '(message ..) ;;;;;
                       [(equal? 'message (caar (actor-mailbox new-player)))
                        (update (struct-copy actor new-player
                                             (mailbox (cdr (actor-mailbox new-player))))
                                created-players
                                (cons (cdar (actor-mailbox new-player))
                                      created-msg) )]))])
    (update player '() '())
    )
  )


;;;;;;;;;;; Colliding ;;;;;;;;;;;;;;;

(define (colliding? actor1 actor2)
  (equal? (actor-position actor1)
              (actor-position actor2)))

(define (collisions? x list-actors)
   (for/or ([i list-actors])
     (colliding? x i)))

;;;;;;;;;; Provide ;;;;;;;;;;;;;

(provide actor name-of-actor actor-location actor?
         actor-category y-pos-top-mail x-pos-top-mail
         actor-send actor-update update-position actor-mailbox
         colliding? collisions?
         )






