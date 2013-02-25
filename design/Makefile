# --------------------------------------------------------------------------
# --- WCAML API                                                          ---
# --------------------------------------------------------------------------

include MakeWcaml

WCAML_CMI=$(addsuffix .cmi, $(WCAML_SRC))
WCAML_CMO=$(addsuffix .cmo, $(WCAML_SRC))

# --------------------------------------------------------------------------

.PHONY: all byte doc

all: byte doc
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