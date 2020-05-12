#lang scribble/manual

@title{Acting Shooting Star: Documentation}

@author["Olivier Nguyen" "Hicham Zghari" "Augustin Gauchet" "Imad Boudroua"]

@table-of-contents[]



@section{Actor}

@subsection{Structures}

@defstruct[actor ([position list?] [mailbox list?] [name any?] [category any?])]{
La structure qui décrit les acteurs.

position est une liste de deux éléments qui contient les coordonnées x et y
mailbox est une liste de messages
name? contient la représentation raart de l’acteur
category est le type de l’acteur (joueur, ennemi, projectile)

}



message est une liste dont le contenu varie selon le type de message :
Pour les messages de mouvement “message” prend la forme (move ‘(position)) avec position le vecteur coordonnée qui va faire bouger l’acteur qui reçoit le message
Pour les messages de création d’acteur “message” prend la forme (create ‘(position)) avec position les coordonnées où est créé l’acteur

@subsection{Fonctions et prédicats}

@defproc[(name-of-actors [actor (actor?)])
			 
         actor?]{
  Retourne le nom de l'acteur
}



@racket[(actor-location actor?)]

    entrée: actor
    sortie: la liste de coordonnées de l’actor

@racket[(actor-send actor? message?)]
    entrée: actor, message
    une copie de l’actor avec le message ajouté à sa mailbox

@racket[x-pos-top-mail:]
    entrée: actor
    sortie: si le message en première position de la mailbox de l’actor est un message de mouvement, renvoie la composante horizontale du mouvement en question

y-pos-top-mail:
    entrée: actor
    sortie: si le message en première position de la mailbox de l’actor est un message de mouvement, renvoie la composante verticale du mouvement en question


actor-update:
    entrée: actor
    sortie: une liste dont le premier élément contenant à la fois une copie de l’acteur initial qui a effectué toutes les instructions contenues dans sa mailbox, et les actors créés par les messages de création.

colliding?:
entrée: deux actors
sortie: #t si les deux actors ont les mêmes coordonnées, #f sinon

collisions?
entrée: un actor et une liste d’actors
sortie: #t s’il existe un actor dans la liste qui a les mêmes coordonnées que l’acteur passé en paramètre, #f sinon


@section{World}

@subsection{structure}