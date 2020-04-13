#lang racket

(require
  (prefix-in ct: charterm)
  (prefix-in lux: lux)
  (prefix-in raart: raart))

;; Get the terminal dimensions
(define-values (term-cols term-rows)
  (ct:with-charterm (ct:charterm-screen-size)))



(struct world (tick)
        #:methods lux:gen:word
        [(define (word-fps w)      ;; FPS desired rate
           10.0)
         (define (word-label s ft) ;; Window label of the application
           "JUST ASCII IT!")
         (define (word-event w e)  ;; Event Handler
           (match e
             ["q" #f]  ;; Quit the application
             [_   w]   ;; Otherwise do nothing
         ))
         (define (word-output w)      ;; What to display for the application
           (match-define (world tick) w)
           (raart:matte-at term-cols term-rows
                           (modulo tick term-cols)
                           (modulo (quotient tick term-cols) term-rows)
                         (raart:bg 'red (raart:text ">")))
         )
         (define (word-tick w)        ;; Update function after one tick of time
           (match-define (world tick) w)
           (world (+ 1 tick)))
         ])

;; Starter function
(define (start-application)
  (lux:call-with-chaos
   (raart:make-raart)
   (lambda () (lux:fiat-lux (world 0))))
  (void))

(start-application)