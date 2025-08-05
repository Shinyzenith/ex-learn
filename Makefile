.PHONY: all build run

all: build

build:
	mix deps.get
	mix compile

run:
	mix run --no-halt
