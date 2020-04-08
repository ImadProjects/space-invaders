all: build

build: 
		racket src/display.rkt

test:
	racket src/test-actor.rkt

doc:
	echo "doc"
