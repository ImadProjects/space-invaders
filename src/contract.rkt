#lang racket
(require "actors.rkt")
(require "world.rkt")
;(require "runtime.rkt")
 
(provide (contract-out     
    [actor-location (-> actor? list?)]
    [actor-send (-> actor? list? actor?)]
    [update-position ( -> actor? actor? )]
    ;[actor-update ( -> actor? list?)]
))

(provide  actor name-of-actor actor?
          actor-category y-pos-top-mail x-pos-top-mail
          actor-mailbox actor-update
          colliding? collisions?)

(provide (struct-out world))
(provide send-world update-world execute-msg
         shoot save-world world-travel
         world-filter world-alive
         actor-alive?
         generate) 
