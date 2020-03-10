#lang racket
(require "Shoot.rkt")
 
(provide (contract-out     
    [actor-location (-> vactor? list?)]
    [actor-send (-> vactor? list? vactor?)]
    [update-position ( -> vactor? vactor? )]
    [actor-update ( -> vactor? vactor?)]
))

(provide actor actor-mailbox)