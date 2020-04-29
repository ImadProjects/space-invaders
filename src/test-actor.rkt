#lang racket

(require rackunit)
(require rackunit/text-ui)
(require "contract.rkt")
(require racket/match
         racket/format
         racket/list
         lux
         raart)
(require racket/trace)
(require
  (prefix-in ct: charterm)
  (prefix-in lux: lux)
  (prefix-in raart: raart))

(define all-tests
  (test-suite
   "Tests for an actor implementation"

   (test-case
    "checks an actor's location"
    (let* ([actor-test (actor '(0 0) '() "test" "test")])
      (check-equal? (actor-location actor-test) '(0 0))))
   
   (test-case
    "updates an actor's mailbox"
    (let* ([actor-test (actor '(0 0) '() "test" "test")])
      (check-equal? (actor-mailbox (actor-send actor-test '(mooooove 100 100))) '((mooooove 100 100)))))

   (test-case
    "updates an actor with an empty mailbox"
   (let* ([actor-test (actor '(0 0) '() "test" "test")]
           [actor-expected (actor '(0 0) '() "test" "test")]) 
            (and (check-equal? (actor-location (car (actor-update actor-test))) '(0 0)))
                 (check-equal? (actor-mailbox (car (actor-update actor-test))) '())))

   (test-case
    "updates an actor with a creation message in its mailbox"
    (let* ([actor-test (actor '(0 0) '((create 1 2) (create 2 3)) "test" "test")]
           [list-expected '((actor '(0 0) '() "p" "test") (actor '(2 3) '() "p" "test") '(actor '(1 2) '() "test" "test"))])
           (and (check-equal? (actor-location (car (actor-update actor-test))) '(0 0))
                (check-equal? (actor-location (cadr (actor-update actor-test))) '(2 3))
                (check-equal? (actor-location (caddr (actor-update actor-test))) '(1 2)))))
   (test-case
     "ensures send-world sends to world"
     (let * ([world-test (world (list (actor '(1 2) '() "test" "player") (actor '(2 3) '() "test" "enemy")))]
           [world-expected (world (list (actor '(1 2) '((move 1 1)) "test" "player") (actor '(2 3) '() "test" "enemy")))])
           (check-equal? (send-world world-test '(move 1 1) "player") world-expected)))
                         
   (test-case
    "updates the actors in the world"
    (let * ([world-test (world (list (actor '(0 1) '((move 2 3)) "test" "player") (actor '(4 5) '((move 6 7)) "test" "player")))]
            [world-expected (world (list (actor '(2 4) '() "francis" "player") (actor '(10 12) '() "francois" "player")))])
      (and (check-equal? (actor-location (car (world-actors (update-world world-test)))) '(10 12))
           (check-equal? (actor-location (cadr (world-actors (update-world world-test)))) '(2 4))
           (check-equal? (actor-mailbox (car (world-actors (update-world world-test)))) '())
           (check-equal? (actor-mailbox (cadr (world-actors (update-world world-test)))) '()))))
   
   ;(test-case
    ;"checks that an actor with a messaging message messages the message"
    ;(let * ([actor-test (actor '(0 0) '((message (move 1 1))) "test" "player")]
     ;       [expected '(move 1 1)])
      ;(check-equal? (actor-update actor-test) expected)))
   
   (test-case
    "verifies that the actors which should collide collide"
    (let * ([actors (list (actor '(0 1) '() "test" "player")
                          (actor '(1 1) '() "test" "player")
                          (actor '(1 0) '() "test" "player"))]
            [actor-test (actor '(1 1) '() "test" "player")]
            [expected '(#f #t #f)])
      (check-equal? (map (lambda(x) (colliding? actor-test x))  actors) expected)))
   
      (test-case
    " colliding? detects collisions"
    (let * ([actors-not-colliding (list (actor '(0 1) '() "test" "player")
                                        (actor '(1 1) '() "test" "player")
                                        (actor '(1 0) '() "test" "player"))]
            [actor-test (actor '(1 1) '() "test" "player")])
      (and (check-equal? (collisions? actor-test
                                     (list (actor '(0 1) '() "test" "player")
                                     (actor '(0 0) '() "test" "player")
                                     (actor '(1 0) '() "test" "player"))) #f)
           (check-equal? (collisions? actor-test
                                     (list (actor '(0 1) '() "test" "player")
                                     (actor '(1 1) '() "test" "player")
                                     (actor '(1 0) '() "test" "player"))) #t))))
      
 (test-case
    "Tests for the time travel feature"
    (let * ([current (world (list (actor '(0 1) '((move 0 0)) "current" "player")))]
            [expected (world (list (actor '(0 1) '((move 0 5)) "expected" "player")))])
      (letrec ([generate (lambda (w n)
                         (if (= n 0)
                             w
                             (generate (cons (world (list (actor '(0 1) '((move 0 0)) "old" "player"))) w) (- n 1))))])
        (and (save-world (world (list (actor '(0 1) '((move 0 5)) "expected" "player"))))
             (save-world (world (list (actor '(0 1) '((move 0 0)) "old" "player"))))
             (save-world (world (list (actor '(0 1) '((move 0 0)) "old" "player"))))
             (check-equal? (world-travel 3 current) expected)))))

 (test-case
     "shoot finds the player in the world and returns the coordinates of the location in front of him"
     (let * ([current (world (list (actor '(0 10) '() "bad_guy" "enemy") (actor '(0 1) '() "jeremy" "player") (actor '(0 9) '() "bad_guy" "enemy")))]
             [expected '(0 2)])
       (check-equal? (shoot current) expected)))
; (test-case   ;;;le check-equal? n'aime pas le #<raart>
 ; "test for the enemy generation"
  ;(let * ([expected-1 '()])
   ;       (letrec ([gen (lambda (n actors) (cond [(< n 1) actors]
    ;                                            [else (gen (- n 2) (cons (actor (list n 60) '() (fg 'green (raart:text "<<")) "enemy") actors))]))])
     ;       (or (check-equal? (generate 1) expected-1)
      ;           (check-equal? (generate 0) (gen 19 '()))))))
    
   ))

(printf "Running tests\n")
(run-tests all-tests)