EMACS ?= emacs

all: generate

generate:
	${EMACS} -Q -nw -l "scripts/makefile-script.el" -f generate-this-doc

clean:
	$(RM) *.html

.PHONY: all generate
