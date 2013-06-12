# --------------------------------------------------------------------------
# --- WCAML API                                                          ---
# --------------------------------------------------------------------------

.PHONY: all opt rebuild

all: opt wcamlpack
rebuild:
	$(MAKE) clean depend
	$(MAKE) all

# --------------------------------------------------------------------------

wcamlpack: wpack.ml
	$(OCAMLOPT) -o $@ $<

# --------------------------------------------------------------------------

include ../design/MakeWcaml
include ../design/MakePort

# --------------------------------------------------------------------------

INCLUDES= -package lablgtk2
OPTML= -w PSUZMV -warn-error PSUZMV
OPTCMX= -for-pack Wcaml

WCAML_SRC= port main userfile user window control text table layout
WCAML_TYPES= widget.cmi model.cmi
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

DISTRIB= wcamlpack wcaml.cmi wcaml.cmxa wcaml.a

install:
	@echo "Install WCaml."
	@ocamlfind remove wcaml
	@ocamlfind install wcaml META $(DISTRIB)

uninstall:
	@echo "Removing WCaml."
	@ocamlfind remove wcaml

# --------------------------------------------------------------------------
include ../design/MakeOcaml
# --------------------------------------------------------------------------
