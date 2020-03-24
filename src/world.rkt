#lang racket
(require "Shoot.rkt")

(struct world (tick list-actor))

(define (send world message)
  (if (= (car message) (car (world-actor)))
      (actor-send (car (world-actor)) (cdr message))
      (send () message)))
  
  
  
(define (send-message world message)
  (letrec ([send (lambda (actors msg))
                 (if (null? actors)
                     '()
                     (cons (actor-send (car actors) msg)
                           (send (cdr actors) msg)))])
    (world () (send (world-actor world) message))))


