# --------------------------------------------------------------------------
# --- WCAML API                                                          ---
# --------------------------------------------------------------------------

.PHONY: all opt

all:
	$(MAKE) depend
	$(MAKE) opt

# --------------------------------------------------------------------------

include ../design/MakeWcaml
include ../design/MakePort

# --------------------------------------------------------------------------

INCLUDES= -I +lablgtk2
OPTCMX= -for-pack Wcaml

WCAML_SRC= port window main
WCAML_TYPES= widget.cmi
WCAML_CMI=$(addsuffix .cmi, $(WCAML_LIB) $(WCAML_SRC))
WCAML_CMX=$(addsuffix .cmx, $(WCAML_LIB) $(WCAML_SRC))

opt: wcaml.cmxa 
wcaml.cmxa: wcaml.cmx
	$(OCAMLOPT) -o wcaml.cmxa -a wcaml.cmx

wcaml.cmx: port $(WCAML_TYPES) $(WCAML_CMI) $(WCAML_CMX)
	$(OCAMLOPT) -o wcaml.cmx -pack $(WCAML_TYPES) $(WCAML_CMX)

depend: port

LIBDIR?=$(shell $(OCAMLOPT) -where)

install:
	@echo "Install to $(LIBDIR)/wcaml"
	@mkdir -p $(LIBDIR)/wcaml
	@cp -f wcaml.cmi wcaml.cmxa wcaml.a $(LIBDIR)/wcaml/

# --------------------------------------------------------------------------
include ../design/MakeOcaml
# --------------------------------------------------------------------------
