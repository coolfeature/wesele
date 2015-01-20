REBAR = ./rebar
RECORDS_PATH = $(CURDIR)/include

.PHONY: all compile test clean get-deps build-plt dialyze

all: compile

compile:
	export RECORDS_PATH=$(CURDIR)/include; $(REBAR) compile

test: compile
	@$(REBAR) eunit skip_deps=true

clean:
	@$(REBAR) clean

get-deps:
	@$(REBAR) get-deps

build-plt:
	@$(REBAR) build-plt

dialyze: compile
	@$(REBAR) dialyze

