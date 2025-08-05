.PHONY: all build run

all: build

build:
	mix deps.get
	mix compile

run:
	mix run --no-halt

test:
	mix test --max-cases 1 # We use max-cases 1 to save api-key usage. Feel free to increase it
