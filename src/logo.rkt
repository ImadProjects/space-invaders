#lang at-exp racket/base

(require raart)
(provide logo-lines logo-raart)

(require racket/string
         (prefix-in raart: raart))

(define (text-lines . strs)
  (string-split (string-join strs "") "\n"))


(define logo-lines
  @text-lines{
  ______ _____ ______  _  _    _____ _   __ __    __
 /_  __// ___//  >  / / |/ |  /_ __// | / //  |  / /
  / /  / /_  /  .--' /     |   //  /  |/ // < | / /
 / /  / __/ / /\ \  / /|/| | _//_ / /|  // _  |/ /_
/_/  /____//_/  \_\/_/   |_|/___//_/ |_//_/ |_/___/

            ****  *  *  ****  ****  ****
           *  *  *  *  *  *  **    ***
          ****  ****  *****    ** *
         *     *  *  *   *  **** ****}
  )

(define logo-raart
  (raart:vappend*
   #:halign 'left
   (map raart:text logo-lines)))

(define logo
   (vappend2
    (matte 54 5
           (vappend
            (text ">> Play Game! <<")
            (text "      Help      ")
            (text "  Show Credits  ")
            ))
    (matte 54 12
          (frame
           logo-raart))
   ))


(provide logo logo-raart)