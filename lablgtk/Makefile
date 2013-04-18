# --------------------------------------------------------------------------
# --- WCAML API                                                          ---
# --------------------------------------------------------------------------

.PHONY: all opt rebuild

all: opt wcaml
rebuild:
	$(MAKE) depend
	$(MAKE) all

# --------------------------------------------------------------------------

wcaml: wpack.ml
	$(OCAMLOPT) -o $@ $<

# --------------------------------------------------------------------------

include ../design/MakeWcaml
include ../design/MakePort

# --------------------------------------------------------------------------

INCLUDES= -package lablgtk2
OPTML= -w PSUZMV -warn-error PSUZMV
OPTCMX= -for-pack Wcaml

WCAML_SRC= port main userfile user window
WCAML_TYPES= widget.cmi
WCAML_CMI=$(addsuffix .cmi, $(WCAML_LIB) $(WCAML_SRC))
WCAML_CMX=$(addsuffix .cmx, $(WCAML_LIB) $(WCAML_SRC))

opt: wcaml.cmxa 
wcaml.cmxa: wcaml.cmx
	$(OCAMLOPT) -o wcaml.cmxa -a wcaml.cmx

wcaml.cmx: .port $(WCAML_TYPES) $(WCAML_CMX)
	$(OCAMLOPT) -o wcaml.cmx -pack $(WCAML_TYPES) $(WCAML_CMX)

depend: port userfile.ml

clean::
	rm -f userfile.ml

# --------------------------------------------------------------------------

install:
	@echo "Install WCaml."
	@ocamlfind install wcaml META wcaml wcaml.cmi wcaml.cmxa wcaml.a
	@ocamlfind query wcaml

uninstall:
	@echo "Removing WCaml."
	@ocamlfind remove wcaml

# --------------------------------------------------------------------------
include ../design/MakeOcaml
# --------------------------------------------------------------------------
