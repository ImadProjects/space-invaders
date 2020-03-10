#lang racket
(require racket/trace)

(struct actor (position msg))

(define me (actor '(1 2) '((move 3 8) (move -2 -4))))

(define (actor-location actor)
  (actor-position actor))

(define (actor-send new-actor new-msg)
  (struct-copy actor new-actor (msg (cons (actor-msg new-actor) new-msg))))

(define (message actor)
  (car (actor-msg actor)))

(define (message-x msg)
  (car (cdr msg)))

(define (message-y msg)
  (car (cdr (cdr msg))))

(define (update-position new-actor)
  (struct-copy actor new-actor (position (list
                                          (+ (car (actor-position new-actor)) (cadar (actor-msg new-actor)))
                                          (+ (cadr (actor-position new-actor)) (caddar (actor-msg new-actor)))))
               (msg (cdr (actor-msg new-actor)))))

(define (actor-update new-actor)
  (cond
    ((empty? (actor-msg new-actor)) new-actor)
    ((equal? 'move (caar (actor-msg new-actor))) (actor-update (update-position new-actor)))))
    
(trace actor-update)
(trace actor-location)