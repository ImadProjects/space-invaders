all: build

build: 
	racket src/main.rkt

test:
	racket src/test-actor.rkt

documentation:
	scribble --pdf  doc/documentation.scrbl 

