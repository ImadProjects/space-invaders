#lang racket

(require rackunit)
(require rackunit/text-ui)
(require "contract.rkt")

(define all-tests
  (test-suite
   "Tests for an actor implementation"

   (test-case
    "checks an actor's location"
    (let* ([actor-test (actor '(0 0) '())])
      (check-equal? (actor-location actor-test) '(0 0))))
   
   (test-case
    "updates an actor's mailbox"
    (let* ([actor-test (actor '(0 0) '())])
      (check-equal? (actor-mailbox (actor-send actor-test '(mooooove 100 100))) '((mooooove 100 100)))))

   (test-case
    "updates an actor according to its mailbox"
    (let* ([actor-test (actor '(0 0) '((move 1 1) (move 2 2)))]
           [actor-expected (actor '(3 3) '())]) 
            (and (check-equal? (actor-location (actor-update actor-test)) '(3 3)))
                 (check-equal? (actor-mailbox (actor-update actor-test)) '())))
   (test-case
    "updates an actor with an empty mailbox"
   (let* ([actor-test (actor '(0 0) '())]
           [actor-expected (actor '(0 0) '())]) 
            (and (check-equal? (actor-location (actor-update actor-test)) '(0 0)))
                 (check-equal? (actor-mailbox (actor-update actor-test)) '())))
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