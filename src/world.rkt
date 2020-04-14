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
(require "actors.rkt" )

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
        (remove-dead-actors nw)
	      (update-world (struct-copy world w (actors (cdr (world-actors w)))) (world (append (car (actor-update (car (world-actors w)))) (world-actors nw))))))
;(update-world  monde new-world)



(define (remove-dead-actors w)
  (define (actors_alive? x)
    (not (collisions? x (world-projectiles w))))
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


(define (actor-alive? x w)
    (not (collisions? x (world-actors w))))

(define (enemy? act)
  (if (equal? "enemy" (actor-category act))
      #t
      #f))

(define (player? act)
  (if (equal? "player" (actor-category act))
      #t
      #f))

(define (missile? act)
  (if (equal? "projectile" (actor-category act))
      #t
      #f))

(define (world-enemies w)
  (filter enemy? (world-actors w)))

 (define (world-player w)
  (filter player? (world-actors w))) 

(define (world-projectiles w)
  (filter missile? (world-actors w)))



(define (any-collision? w)
  (define enemies (world (world-enemies w)))
  (define projectiles (world (world-projectiles w)))
  (for/or ([i (world-actors projectiles)])
    (collisions? i (world-actors enemies)))) 

  



(provide (struct-out world))

(provide world-enemies update-world send-to-world remove-dead-actors latest-worlds save-world world-travel world-player)

(define act (actor '(3 2) '() (fg 'red (raart:text ">>>")) "enemy"))
(define ac (actor '(3 2) '() (fg 'red (raart:text ">>>")) "player"))

(define missile (actor '(4 2) '() (fg 'red (raart:text ">>>")) "projectile"))
(define monde (world (list missile ac act  ) ))
;(actor-alive? act monde)
;(display (remove-dead-actors monde))
;(send-to-world '(move 1 1)  monde)
(define nw (world '()))
;(update-world monde nw)
;(world-enemies monde)
;(enemy? missile)
;(world-enemies monde)
  (define player (world (world-player monde)))
  (define projectiles (world (world-projectiles monde)))
 (display player)
 ; (display projectiles)
;(any-collision? monde)
;(collisions? missile (world-actors enemies) )

(define latest-runtimes '())

(define (save-runtimes r)
  (if (<= (length latest-worlds) 10)
        (set! latest-runtimes (cons r latest-runtimes))
	      (set! latest-runtimes (cons r (reverse (cdr (reverse latest-runtimes)))))))

(define (time-travel-runtime n ancient-runtimes current-runtime)
  (cond
      [(or (= n 0) (> n (length ancient-runtimes))) current-runtime]
          [(>= n 2) (time-travel (sub1 n) (cdr ancient-runtimes) current-runtime)]
	      [else (car ancient-runtimes)]))

(provide latest-runtimes save-runtime time-travel-runtime)