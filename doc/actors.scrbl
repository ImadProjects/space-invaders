#lang scribble/manual

@title{Acting Shooting Star: Documentation}

@author["Olivier Nguyen" "Hicham Zghari" "Augustin Gaucher" "Imad Boudroua"]

@table-of-contents[]

@section{Structures}

@subsection{Actor}

@racketblock[
(actor (position mailbox name category))]

position est une liste de deux éléments qui contient les coordonnées x et y
mailbox est une liste de messages
name? contient la représentation raart de l’acteur
category est le type de l’acteur (joueur, ennemi, projectile)

@subsection{World}

@racketblock[
(world (actors))]

actors est une liste d’acteurs intervenants dans le monde

Runtime : (runtime (world tick duree))
world est le monde qui interagit avec le jeu
tick est le nombre de ticks qui va être incrémenté jusqu’à atteindre la durée prévue du jeu
duree est la durée totale du jeu


message* est une liste dont le contenu varie selon le type de message :
Pour les messages de mouvement “message” prend la forme (move ‘(position)) avec position le vecteur coordonnée qui va faire bouger l’acteur qui reçoit le message
Pour les messages de création d’acteur “message” prend la forme (create ‘(position)) avec position les coordonnées où est créé l’acteur

Fonctions et prédicats

@racketblock[
(define (nobody-understands-me what)
  (list "When I think of all the"
        what
         "I've tried so hard to explain!"))
(nobody-understands-me "glorble snop")
]