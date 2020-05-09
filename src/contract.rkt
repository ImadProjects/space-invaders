#lang racket
(require "actors.rkt")
(require "world.rkt")

;;actors.rkt
(provide (contract-out     
    [actor-location (-> actor? list?)]
    [actor-send (-> actor? list? actor?)]
    [update-position (-> actor? actor? )]
    [actor-update (-> actor? list?)]
    [y-pos-top-mail (-> actor? number?)]
    [x-pos-top-mail (-> actor? number?)]
    [actor-category (-> actor? (lambda(x) (not (empty? x))))]
    [colliding? (-> actor? actor? boolean?)]
    [collisions? (-> actor? list? boolean?)]
    ))

(provide actor name-of-actor actor? actor-mailbox)

;world.rkt
(provide (struct-out world))

(provide (contract-out
          [send-world (-> world? list? (lambda(x) (not (empty? x))) world?)]
          [update-world (-> world? world?)]
          [save-world (-> world? void?)]
          [world-travel (-> number? world? world?)]
          [shoot (-> world? list?)]
          [generate (-> number? list?)]
          [player-dead? (-> world? boolean?)]
          [actor-alive? (-> actor? world? boolean?)]
           ))

(provide execute-msg
         world-filter world-alive
         )
