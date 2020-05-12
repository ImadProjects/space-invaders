all: build

build: 
	racket src/runtime.rkt

test:
	racket src/test-actor.rkt

