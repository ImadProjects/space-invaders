#lang racket

;;racket draw.rkt

    (define (clear-display) (printf "\e[2J"))
    (define (move-cursor-to x y) (printf "\e[~a;~aH" x y))
    (define (save-cursor) (printf "\e[s"))
    (define (restore-cursor) (printf "\e[u"))
    (define (text-color c) (printf "\e[~am" c))
    (define (restore-text-color) (printf "\e[39m"))

    (define red 31)
    (define green 32)
    (define yellow 33)
    (define blue 34)

(save-cursor)
(clear-display)
(move-cursor-to 10 12)
(text-color green)
(printf "Hello World")
(restore-text-color)

(move-cursor-to 12 10)
(printf "###############")
(move-cursor-to 8 10)
(printf "###############")

(move-cursor-to 10 10)
(printf "#")
(move-cursor-to 9 10)
(printf "#")
(move-cursor-to 11 10)
(printf "#")
(move-cursor-to 10 24)
(printf "#")
(move-cursor-to 9 24)
(printf "#")
(move-cursor-to 11 24)
(printf "#")

(restore-text-color)
(restore-cursor)
