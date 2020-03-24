#lang racket
(require "Shoot.rkt")
 
(provide (contract-out     
    [actor-location (-> vactor? location?)]
    [actor-send (-> vactor? message? vactor?)]
    [update-position ( -> vactor? vactor? )]
    [actor-update ( -> vactor? vactor?)]
))

(provide actor actor-mailbox)