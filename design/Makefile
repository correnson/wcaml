# --------------------------------------------------------------------------
# --- WCAML API                                                          ---
# --------------------------------------------------------------------------

include MakeWcaml

OPTML= -w PSUZMV -warn-error PSUZMV
WCAML_CMI=$(addsuffix .cmi, $(WCAML_LIB) $(WCAML_API))
WCAML_CMO=$(addsuffix .cmo, $(WCAML_LIB))

# --------------------------------------------------------------------------

.PHONY: all byte doc 

all:
	$(MAKE) depend
	$(MAKE) byte doc

byte: $(WCAML_CMI) $(WCAML_CMO)

# --------------------------------------------------------------------------
# ---  HTML Documentation                                                ---
# --------------------------------------------------------------------------

doc: html/index.html
html/index.html: $(WCAML_CMI) Makefile
	mkdir -p html
	rm -f html/*
	cp style.css html/
	ocamldoc -html -d html -stars -colorize-code \
		-t "WCaml Library" $(WCAML_MLI)

clean::
	rm -fr html

# --------------------------------------------------------------------------
include MakeOcaml
# --------------------------------------------------------------------------
