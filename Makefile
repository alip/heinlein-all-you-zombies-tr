PDFLATEX   := lualatex --interaction=nonstopmode --halt-on-error
PDFVIEWER  := zathura --fork

GITHEAD    = $(shell git rev-parse HEAD)
LATEXMAIN  = $(shell find $(CURDIR) -mindepth 1 -maxdepth 1 -name '*.tex.latexmain' -not -name 'skel.tex.latexmain')
VCTEX      = $(shell find $(CURDIR) -mindepth 1 -maxdepth 1 -name 'vc')
BIBTEX     = $(shell find $(CURDIR) -mindepth 1 -maxdepth 1 -name '*.bib')

.PHONY: clean check upload

ifeq ($(LATEXMAIN),)
SUBMAKE  = $(shell find $(CURDIR) -mindepth 2 -maxdepth 2 -name Makefile)
SUBDIRS := $(foreach subdir,$(SUBMAKE),$(dir $(subdir)))
.PHONY: $(SUBDIRS)

all: $(SUBDIRS)

$(SUBDIRS):
	$(MAKE) -C $@

check:
	for dir in $(SUBDIRS); do $(MAKE) -C $$dir $@; done
clean:
	for dir in $(SUBDIRS); do $(MAKE) -C $$dir $@; done
count:
	for dir in $(SUBDIRS); do $(MAKE) -C $$dir $@; done
upload:
	for dir in $(SUBDIRS); do $(MAKE) -C $$dir $@; done
else # LATEXMAIN
PDFOUTNAME = $(patsubst %.tex.latexmain,%,$(notdir $(LATEXMAIN)))
PDFOUTFILE = $(PDFOUTNAME).pdf

ifneq ($(VCTEX),)
VCTEXFILE  = vc.tex
else # VCTEX
VCTEXFILE  =
endif # VCTEX

ifneq ($(BIBTEX),)
BIBTEXFILE = $(PDFOUTNAME).bib
BBLTEXFILE = $(PDFOUTNAME).bbl
else # BIBTEX
BIBTEXFILE =
BBLTEXFILE =
endif # BIBTEX

LATEXFILES = $(shell find $(CURDIR) -type f -name '*.tex')

all: $(PDFOUTFILE)

pdf: $(PDFOUTFILE)

clean:
	rm -f nohup.out || true
	find $(CURDIR) -type f -a \
		'(' \
		-name '*~' -o \
		-name '*.dvi' -o \
		-name '*.log' -o \
		-name '*.aux' -o \
		-name '*.bbl' -o \
		-name '*.blg' -o \
		-name '*.toc' -o \
		-name '*.lol' -o \
		-name '*.loa' -o \
		-name '*.lox' -o \
		-name '*.lot' -o \
		-name '*.out' -o \
		-name '*.html' -o \
		-name '*.css' -o \
		-name '*.png' -o \
		-name '*.4ct' -o \
		-name '*.4tc' -o \
		-name '*.idv' -o \
		-name '*.lg' -o \
		-name '*.tdo' -o \
		-name '*.tmp' -o \
		-name '*.xref' -o \
		-name '*.ent' -o \
		-name 'vc.tex' \
		')' \
		-delete

check: $(PDFOUTFILE)
	$(PDFVIEWER) $<

count: $(PDFOUTNAME).tex $(VCTEXFILE)
	texcount -inc -unicode $<

upload: $(PDFOUTFILE)
	rsync -av --progress $^ tchaikovsky.exherbo.org:public_html/tez/

$(PDFOUTFILE): $(LATEXFILES) $(VCTEXFILE) $(BBLTEXFILE)
	$(PDFLATEX) $(PDFOUTNAME)
	$(PDFLATEX) $(PDFOUTNAME)

ifneq ($(VCTEX),)
vc.tex: $(PDFOUTNAME).tex vc-git.awk
	/bin/sh ./vc
endif

ifneq ($(BIBTEX),)
$(BBLTEXFILE): $(BIBTEXFILE)
	$(PDFLATEX) $(PDFOUTNAME)
	bibtex $(PDFOUTNAME)
endif

endif
