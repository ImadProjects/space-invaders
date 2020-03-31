all: build

build: 
		racket src/main.rkt

test:
	racket src/test-actor.rkt

doc:
	echo "doc"
