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

(struct world (actors) #:transparent)                               ;World's structure

(define (send-world worldN msg category)                            ;Send a message to specific category
  (letrec ([new-world (lambda (monde msg cat)
                           (cond
                             
                             [(null? monde) '()]   ;If there is no actor
                             
                             [(equal? cat (actor-category (car monde)))
                              (cons (actor-send (car monde) msg)
                                    (new-world (cdr monde) msg cat))]
                             
                             [else
                              (cons (car monde)
                                    (new-world (cdr monde)
                                               msg cat))]))])
    
    (struct-copy world worldN (actors (new-world
                                       (world-actors worldN) msg category)))))

(define (update-world worldN)                                     ;Updating the world by updating
  (letrec ([update (lambda (world new-world)                      ;every actor in this world
                     (if (empty? world)
                         new-world
                         (update (cdr world)
                                 (append (actor-update (car world))
                                       new-world))))])
    
    (struct-copy world worldN (actors (update (world-actors worldN)
                                              '()
                                              )))))



;;;;;;;;;;;;;;;;; Time Travel ;;;;;;;;;;;;;;;;;;;

(define latest-worlds '())                                       ; A static constante where 
                                                                 ; we save our world

(define (save-world w)                                           ;Save world
  (if (<= (length latest-worlds) 20)
      (set! latest-worlds
            (cons w latest-worlds))
      (set! latest-worlds
            (cons w (reverse (cdr (reverse latest-worlds))))
            )))

(define (world-travel n current-world)                          ;Traveling to the world number
                                                                ;n in latest-world
  (letrec ([travel (lambda (n ancient-worlds current-world)     
                     (cond
                       [(or (= n 0) (> n (length ancient-worlds))) current-world]
                       [(>= n 2) (travel (sub1 n) (cdr ancient-worlds) current-world)]
                       [else (car ancient-worlds)]))])
    
    (travel (time n) latest-worlds current-world)))

                   
(define (time n)                                               ;Make sure that n is less or
  (if (and (>= n 1) (< n 20))                                  ;equal to the length of latest-world
      n
      0))

;;;;;;;;;;;;;;;;;;;;;;; Shoot ;;;;;;;;;;;;;;;;;

(define (shoot worldN)                                        ;Create a projectile from the
                                                              ;last position of the player
  (cond                                                        
    [(null? worldN) '(0 0)]
    [(equal? "player" (actor-category (car (world-actors worldN))))
     (list (car (actor-location (car (world-actors worldN))))
           (add1 (cadr (actor-location (car (world-actors worldN))))))]
    [else
     (shoot (struct-copy world worldN (actors (cdr (world-actors worldN)) )))]))


;;;;;;;;;;;;;;;;;;;; Out of Raart ;;;;;;;;;;;;;

(define (out-raart? player)                                  ;Make sure that every actor
  (or (< (car (actor-location player)) x1)                   ;is in game's frame
      (> (car (actor-location player)) x2)
      (< (cadr (actor-location player)) y1)
      (> (cadr (actor-location player)) y2)
      ))

;;;;;;;;;;;;;;;;;;;; Dead Actors ;;;;;;;;;;;;;;

(define (world-filter w filt)                                ;Search for an actor using a filter
  (filter (lambda (act) (equal? filt (actor-category act))) (world-actors w)))

(define (actor-alive? x w)                                   ;Check if the actor is alive
    (not (collisions? x (world-actors w))))

(define (world-except w act)                                 ;Return a world without this actor
  (letrec ([except (lambda (w nw act)
                     (cond
                       [(null? w) nw]
                       [(equal? (car w) act) (except (cdr w) nw act)]
                       [else (except (cdr w) (cons (car w) nw) act)]
                       ))])
    (struct-copy world w (actors (except (world-actors w) '() act)))))

  
(define (world-alive w)                                      ;Return the alive actors
  (struct-copy world w (actors (filter
                                (lambda (act) (and (not (collisions? act (world-actors (world-except w act))))
                                                  (not (out-raart? act))))
                                (world-actors w)))))


;;;;;;;;;;;;;;;; Generate enemies ;;;;;;;;;;;;;;;;

(define (generate-walls tick)                                ;In this part we generate enemies
  (if (equal? (modulo tick 4) 0)
      (list (actor (list x1 y2) '() (fg 'red (raart:text "#")) "enemy")
            (actor (list (add1 x1) y2) '() (fg 'red (raart:text "#")) "enemy")
            (actor (list (+ 2 x1) y2) '() (fg 'red (raart:text "#")) "enemy")
            (actor (list (+ (+ (random 3) 2) x1) y2) '() (fg 'red (raart:text "#")) "enemy")

            (actor (list x2 y2) '() (fg 'red (raart:text "#")) "enemy")
            (actor (list (sub1 x2) y2) '() (fg 'red (raart:text "#")) "enemy")
            (actor (list (- x2 2) y2) '() (fg 'red (raart:text "#")) "enemy")
            (actor (list (- x2 (+ (random 3) 2)) y2) '() (fg 'red (raart:text "#")) "enemy"))            
      '()
      ))


(define (generate-projectil tick)
(if (equal? (modulo tick 6) 0)
         (list (actor (list (+ (+ 5 x1) (random 5))  y2) '() (fg 'green (raart:text "<")) "enemy")
               (actor (list (+ (+ 10 x1) (random 5))  y2) '() (fg 'green (raart:text "<")) "enemy")
               (actor (list (+ (+ 15 x1) (random 4))  y2) '() (fg 'green (raart:text "<")) "enemy")
               (actor (list (+ (+ 19 x1) (random 2))  y2) '() (fg 'green (raart:text "<")) "enemy")
               )
          '()))


(define (generate tick)
(foldl cons (generate-walls tick) (generate-projectil tick)))


;;;;;;;;;;;;;;;;;;;;; Game ;;;;;;;;;;;;;;;;;;;::

(define (execute-msg world msg category)                     ;Execute the message in the world
  (if (null? msg)
      (update-world world)
  (world-alive (update-world (send-world world msg category)))  
  ))

(define (execute-msgs world msgs)                            ;Execute a list of message in 
  (if (null? msgs)                                           ;the world
      (update-world world)
      (execute-msgs (execute-msg world (caar msgs) (cadar msgs))
                   (cdr msgs))))


(define (game wd tick)                                                 ;The game: -save the current world
  (save-world world)                                                   ;          -remove the dead actors
    (define monde (struct-copy world                                   ;          -generate enemis
                               (world-alive wd)                        ;          move the actors
                             (actors (append (world-actors (world-alive wd))
                                             (generate tick)))))
  (execute-msgs monde
                (list (list '(move 0 1) "created") (list '(move 0 -1) "enemy") )))
  

;;;;;;;;;;;;;;;end of the game ;;;;;;;;;;;;;;;;

(define (player-dead? w)                                    ;Check if the player is dead
(if (null? (world-filter w "player"))
      #t
      #f))

;;;;;;;;;;;;;;;;;;;; Provide ;;;;;;;;;;;;;;;;;;;
(provide (struct-out world))
(provide send-world update-world execute-msg
         shoot save-world world-travel
         world-filter world-alive
         actor-alive?
         generate
         player-dead?
         game) 
        
  