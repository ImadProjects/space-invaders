#lang at-exp racket/base

(require raart)
(provide logo-lines logo-lines2)

(require racket/string
         (prefix-in raart: raart))

(define (text-lines . strs)
  (string-split (string-join strs "") "\n"))


(define logo-lines
  @text-lines{







              
                         ______   _____  _ _____    _  _      _____   _   __   __      __
.                       /_  __/  / ___/  /  >  /   / |/ |    /_ __/  / | / /  /  |    / /
                         / /    / /_    /  .--'   /     |     //    /  |/ /  / < |   / /
                        / /    / __/   / /\ \    / /|/| | _  //_   / /|  /  / _  |  / /_
                       /_/    /____/  /_/  \_\  /_/   |_|  /___/  /_/ |_/  /_/ |_/  _ __/


                     
                                 ****  *  *  ****  ****  ****
                                *  *  *  *  *  *  **    ***
                               ****  ****  *****    ** *
                              *     *  *  *   *  **** ****






                                  >> Press n to start << 

}
  )

(define logo-lines2
  @text-lines{

 
                   ========================                 ======================
                  |                        |               |                      |
                  |                        |               |                      |
                  |                        |               |                      |
                  |                        |               |                      |
                  |                        |               |                      |
                  |                                        |                      |
                  |                                        |                      |
                  |         ===============|               |                      |
                  |         |              |               |                      |
                  |         |              |               |                      |
                  |                        |               |                      |
                  |                        |               |                      |
                  |========================|        o      |======================|





.

              })

