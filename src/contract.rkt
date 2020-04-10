#lang racket
(require "actors.rkt")
(require "world.rkt")
(require "main.rkt")
 
(provide (contract-out     
    [actor-location (-> vactor? location?)]
    [actor-send (-> vactor? message? vactor?)]
    [update-position ( -> vactor? vactor? )]
    [actor-update ( -> vactor? list?)]
))

(provide actor actor-mailbox new-actor-update world world-actors send-to-world runtime runtime-tick runtime-duree update-world game x-position-top-mail y-position-top-mail collisions? name-of-actor)