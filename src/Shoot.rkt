#lang racket
(require racket/trace)

(struct actor (position mailbox))

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
  (cond
    ((empty? (actor-mailbox new-actor)) new-actor)
    ((equal? 'move (caar (actor-mailbox new-actor))) (actor-update (update-position new-actor)))))
    
(trace actor-update)
(trace actor-location)

(define vactor? actor?)
(provide actor actor-location actor-send actor-update update-position actor-mailbox vactor?)