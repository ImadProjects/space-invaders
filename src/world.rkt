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


;;;;;;;;;;;;;;; Wolrd structure and functions ;;;;;;;;;

(struct world (actors) #:transparent)

(define (send-world worldN msg category)
  (letrec ([new-world (lambda (monde msg cat)
                           (cond
                             [(null? monde) '()]
                             [(equal? cat (actor-category (car monde)))
                              (cons (actor-send (car monde) msg)
                                    (new-world (cdr monde) msg cat))]
                             [else
                              (cons (car monde)
                                    (new-world (cdr monde)
                                               msg cat))]))])
    (struct-copy world worldN (actors (new-world
                                       (world-actors worldN) msg category)))))

(define (update-world worldN)
  (letrec ([update (lambda (world new-world)
                     (if (empty? world)
                         new-world
                         (update (cdr world)
                                 (append (actor-update (car world))
                                       new-world))))])
    (struct-copy world worldN (actors (update (world-actors worldN)
                                              '()
                                              )))))

(define (execute-msg world msg category)
  (if (null? msg)
      (update-world world)
  (update-world (send-world world msg category))  
  ))

;;;;;;;;;;;;;;;;; Time Travel ;;;;;;;;;;;;;;;;;;;

(define latest-worlds '())

(define (save-world w)
  (if (<= (length latest-worlds) 9)
      (set! latest-worlds
            (cons w latest-worlds))
      (set! latest-worlds
            (cons w (reverse (cdr (reverse latest-worlds))))
            )))

(define (world-travel n current-world)
  (letrec ([travel (lambda (n ancient-worlds current-world)
                     (cond
                       [(or (= n 0) (> n (length ancient-worlds))) current-world]
                       [(>= n 2) (travel (sub1 n) (cdr ancient-worlds) current-world)]
                       [else (car ancient-worlds)]))])
    (travel (time n) latest-worlds current-world)))
                   
(define (time n)
  (if (and (>= n 1) (< n 9))
      n
      0))
          
;;;;;;;;;;;;;;;;;;;;;;; Shoot ;;;;;;;;;;;;;;;;;

(define (shoot worldN)
  (cond
    [(null? worldN) '(0 0)]
    [(equal? "player" (actor-category (car (world-actors worldN))))
     (list (car (actor-location (car (world-actors worldN))))
           (add1 (cadr (actor-location (car (world-actors worldN))))))]
    [else
     (shoot (struct-copy world worldN (actors (cdr (world-actors worldN)) )))]))
      
;;;;;;;;;;;;;;;;;;;; Dead Actors ;;;;;;;;;;;;;;

(define (world-filter w filt)
  (filter (lambda (act) (equal? filt (actor-category act))) (world-actors w)))

(define (actor-alive? x w)
    (not (collisions? x (world-actors w))))

(define (world-except w act)
  (letrec ([except (lambda (w nw act)
                     (cond
                       [(null? w) nw]
                       [(equal? (car w) act) (except (cdr w) nw act)]
                       [else (except (cdr w) (cons (car w) nw) act)]
                       ))])
    (struct-copy world w (actors (except (world-actors w) '() act)))))

  
(define (world-alive w)
  (struct-copy world w (actors (filter
                                (lambda (act) (not (collisions? act (world-actors (world-except w act)))))
                                (world-actors w)))))


;;;;;;;;;;;;;;;; Generate enemies ;;;;;;;;;;;;;;;;
(define (generate tick)
  (if (not (zero? (remainder tick 5))) '()
  (letrec ([generateN (lambda (generated n)
                       (cond
                        [(zero? n)
                           generated]
                        [(zero? (remainder n 2)) (generateN generated (sub1 n))]
                        [else (generateN (cons (actor (list n 60) '() (fg 'green (raart:text "<<")) "enemy")
                                           generated)
                                     (sub1 n))] ))])
    (generateN '() 20))))
  
                     



;;;;;;;;;;;;;;;;;;;; Provide ;;;;;;;;;;;;;;;;;;;
(provide (struct-out world))
(provide send-world update-world execute-msg
         shoot save-world world-travel
         world-filter world-alive
         actor-alive?
         generate) 
