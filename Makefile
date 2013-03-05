# Copyright (c) 2013 Patrick Huck
# Makefile to generate pdf, tex & hp from asciidoc
# Author: Patrick Huck (@tschaume)

# pdf document name
DOCOUT=asciidoc
# your initials
INITIALS=PH

# filelist (needs to be in order!)
# put paths to all asciidoc source files in
# filelist.txt or list them here directly
# you can submit single files via the *.txt target
# use SIMSTR=-n to simulate submission
FILELIST=$(shell cat filelist.txt)

# symbolic links
# this list is checked in the 'check' target
# and requirement for successfull compilation
# remove 'images' if no images included
#    (or adjust to image include in source file)
LINKLIST = #images

###############################
#  NO CHANGES REQUIRED BELOW  #
###############################

# variables
DOCINFO=docinfo.xml
DOCINFOREV=$(DOCOUT)-$(DOCINFO)
TAGLIST=$(shell git tag -l | tr '\n' ' ')

# shell commands
SIMSTR=
BPCMD=blogpost.py $(SIMSTR) -p post
SEDCMD=sed -e '/^:blogpost/d' -e 's:\/\/=:=:'

# phony takes target always as out-of-date
.PHONY: all pdf hp docinfo check clean

# default target if none specified
all: pdf hp latex

# define directive for single revision entry
# argument: tagname
define REVCMD

echo '<revision>' >> $(DOCINFOREV)
echo '  <revnumber>'$(1)'</revnumber>' >> $(DOCINFOREV)
echo '  <date>'$(shell git log -1 $(1) --format=%ad --date=short)'</date>' >> $(DOCINFOREV)
echo '  <authorinitials>$(INITIALS)</authorinitials>' >> $(DOCINFOREV)
echo '  <revremark>'$(shell git log -1 $(1) --format=%B)'</revremark>' >> $(DOCINFOREV)
echo '</revision>' >> $(DOCINFOREV)
endef

# define A2X command
# argument: format (pdf/tex), asciidoc file, outdir
# -a docinfo = include $(DOCOUT)-docinfo.xml
define A2XCMD
a2x -vv -a latexmath -a docinfo -L -D $(3) -f $(1) $(2)
endef

# check whether required symbolic links exist
# abort otherwise
define TESTDEF
$$(if $$(wildcard $(1)),$$(info symlink $(1) ok),$$(error symlink $(1) NOT found))
endef
check:
	$(foreach link, $(LINKLIST), $(eval $(call TESTDEF,$(link))))

# generate $(DOCOUT)-docinfo.xml
docinfo:
	cp $(DOCINFO) $(DOCINFOREV)
	$(foreach tag, $(TAGLIST), $(call REVCMD,$(tag)))
	echo '</revhistory>' >> $(DOCINFOREV)

# generate pdf
pdf: docinfo check
	cp preamb.txt $(DOCOUT).txt
	@$(foreach file, $(FILELIST), $(SEDCMD) $(file) >> $(DOCOUT).txt; )
	$(call A2XCMD,pdf,$(DOCOUT).txt,.)

# generate page-by-page tex files for inclusion in latex document
latex: check
	mkdir tex && ln -s images tex/images
	@$(foreach file, $(FILELIST), $(call A2XCMD,tex,$(file),tex); )

# push all asciidocs to wordpress
hp: check
	@$(foreach file, $(FILELIST), $(BPCMD) $(file); )

# push a single asciidoc to wordpress
FORCE:
%.txt: FORCE
	$(BPCMD) $*.txt

# clean up
clean:
	@if [ -e $(DOCOUT).txt ]; then rm -v $(DOCOUT).txt; fi
	@if [ -e $(DOCOUT).pdf ]; then rm -v $(DOCOUT).pdf; fi
	@if [ -e $(DOCINFOREV) ]; then rm -v $(DOCINFOREV); fi
	@if [ -d tex ]; then rm -rfv tex; fi
