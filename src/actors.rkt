#lang racket

(require racket/match
         racket/format
         racket/list
         racket/trace
         lux
         raart)

(require
  (prefix-in ct: charterm)
  (prefix-in lux: lux)
  (prefix-in raart: raart))

;;;;;;;;;;;;;;;;;; Actor structure and functions ;;;;;;;;;;;;

(struct actor (position mailbox name category)#:transparent)   ;Actor's structure

(define (name-of-actor player)                                 ;Return actor's name
  (actor-name player))

(define (actor-location player)                                ;Return actor's location
  (actor-position player))

(define (actor-send player new-msg)                            ;Send a msg to th actor
  (struct-copy actor player (mailbox
                                (cons new-msg
                                      (actor-mailbox player)))))

(define (x-pos-top-mail player)                                ;Return the first position in
  (cadar (actor-mailbox player)))                              ;the actor's mailbox

(define (y-pos-top-mail player)
  (caddar (actor-mailbox player)))

(define (update-position player)                               ;Update actor's position by
  (struct-copy actor player (position                          ;executing the first message
                                (list                          ; in its mailbox
                                 (+                            
                                  (car (actor-position player))
                                  (x-pos-top-mail player))
                                 (+ (cadr (actor-position player))
                                    (y-pos-top-mail player))))
               (mailbox (cdr (actor-mailbox player)))))

(define (actor-update player)                                  ;Execute every message in
                                                               ;actor's mailbox
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

(define (colliding? actor1 actor2)                             ;Check if the two actors
  (equal? (actor-position actor1)                              ;are in the same position (collision)
              (actor-position actor2)))

(define (collisions? x list-actors)                            ;Check if the actor has a
   (for/or ([i list-actors])                                   ;collision with another actor
     (colliding? x i)))

;;;;;;;; Terminal dimensions ;;;;;;;;                          

(define x1 0)
(define x2 26)
(define y1 0)
(define y2 100)

;;;;;;;;;;;; Provide ;;;;;;;;;;;;;;;;

(provide actor name-of-actor actor-location actor?
         actor-category y-pos-top-mail x-pos-top-mail
         actor-send actor-update update-position actor-mailbox
         colliding? collisions?
         )

(provide x1 x2 y1 y2)




