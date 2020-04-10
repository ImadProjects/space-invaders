#lang racket

(require rackunit)
(require rackunit/text-ui)
(require "contract.rkt")

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
            (and (check-equal? (actor-location (caar (actor-update actor-test))) '(0 0)))
                 (check-equal? (actor-mailbox (caar (actor-update actor-test))) '())))

   (test-case
    "updates an actor with a creation message in its mailbox"
    (let* ([actor-test (actor '(0 0) '((create 1 2) (create 2 3)) "test" "test")]
           [list-expected '((actor '(0 0) '() "p" "test") (actor '(2 3) '() "p" "test") '(actor '(1 2) '() "test" "test"))])
           (and (check-equal? (actor-location (caddar (actor-update actor-test))) '(1 2))
                (check-equal? (actor-location (cadar (actor-update actor-test))) '(2 3))
                (check-equal? (actor-location (caar (actor-update actor-test))) '(0 0)))))
   (test-case
     "checks the mails of world"
     (let * ([world-test (world (list (actor '(1 2) '() "test" "player")))]
           [world-expected '(actor '(1 2) '(move 1 1) "test" "player")])
           (and (check-equal? (actor-location (car (world-actors (send-to-world '(move 1 1) world-test)))) '(1 2)))
                (check-equal? (car (actor-mailbox (car (world-actors (send-to-world '(move 1 1) world-test))))) '(move 1 1))))
   (test-case
    "Checks that the actors in the world play"
    (let * ([world-test (world (list (actor '(0 1) '((move 2 3)) "test" "player") (actor '(4 5) '((move 6 7)) "test" "player")))]
            [world-expected (world (list (actor '(2 4) '() "francis" "player") (actor '(10 12) '() "francois" "player")))])										                          (and (check-equal? (actor-location (car (world-actors (update-world world-test (world '()))))) '(10 12))					                              (check-equal? (actor-location (cadr (world-actors (update-world world-test (world '()))))) '(2 4))					                                 (check-equal? (actor-mailbox (car (world-actors (update-world world-test (world '()))))) '()) 						                                    (check-equal? (actor-mailbox (cadr (world-actors (update-world world-test (world '()))))) '()))))	
   (test-case
    "checks the state of the world at the end of the game"
    (let * ([runtime-test (runtime (world (list (actor '(1 2) '() "test" "player"))) 1 4)]										                         [world-expected (world (list (actor '(7 10) '() "test" "player")))])
      (check-equal? (actor-location (car (world-actors (game runtime-test '((move 2 3) (move 4 5)) 0)))) '(7 10))))

   (test-case
    "updates differents actors according to their categories"
    (let * ([actor-test (list (actor '(0 0) '((move 1 0) (move-enemy 2 0) (move-projectile 4 0)) "test" "player") (actor '(0 1) '((move 1 0) (move-enemy 2 0) (move-projectile 3 0)) "test" "enemy")  (actor '(0 3) '((move 1 0) (move-enemy 2 0) (move-projectile 3 0)) "test" "projectile"))]
            [expected (list (actor '(1 0) '() "test" "player") (actor '(2 1) '() "test" "enemy") (actor '(3 3) '() "test" "projectile"))])
      (check-equal? (map caar (map actor-update actor-test)) expected)))
   ))













  ;;
;;   (test-case
;;    "Adding to empty set yields size one"
;;    (let* ([set (set-empty)])
;;      (check-equal? (set-length (set-add set 666)) 1)))
;;
;;   (test-case
;;    "Integer added to empty set is found back"
;;    (let* ([set (set-empty)])
;;      (check-true (set-mem (set-add set 666) 666))
;;      (check-false (set-mem (set-add set 666) 667))))

(printf "Running tests\n")
(run-tests all-tests)