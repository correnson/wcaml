# --------------------------------------------------------------------------
# --- WCAML API                                                          ---
# --------------------------------------------------------------------------

.PHONY: all opt rebuild

all: opt
rebuild:
	$(MAKE) depend
	$(MAKE) opt

# --------------------------------------------------------------------------

include ../design/MakeWcaml
include ../design/MakePort

# --------------------------------------------------------------------------

INCLUDES= -package lablgtk2
OPTML= -w PSUZMV -warn-error PSUZMV
OPTCMX= -for-pack Wcaml

WCAML_SRC= port window main
WCAML_TYPES= widget.cmi
WCAML_CMI=$(addsuffix .cmi, $(WCAML_LIB) $(WCAML_SRC))
WCAML_CMX=$(addsuffix .cmx, $(WCAML_LIB) $(WCAML_SRC))

opt: wcaml.cmxa 
wcaml.cmxa: wcaml.cmx
	$(OCAMLOPT) -o wcaml.cmxa -a wcaml.cmx

wcaml.cmx: .port $(WCAML_TYPES) $(WCAML_CMX)
	$(OCAMLOPT) -o wcaml.cmx -pack $(WCAML_TYPES) $(WCAML_CMX)

depend: port

# --------------------------------------------------------------------------

WCAML_LIBDIR?=$(shell $(OCAMLOPT) -where)/wcaml

install:
	@echo "Install library to $(WCAML_LIBDIR)"
	@mkdir -p $(WCAML_LIBDIR)
	@cp -f META wcaml.cmi wcaml.cmxa wcaml.a $(WCAML_LIBDIR)

uninstall:
	@echo "Removing $(WCAML_LIBDIR)"
	@rm -fr $(INSTALL_DIR)

# --------------------------------------------------------------------------
include ../design/MakeOcaml
# --------------------------------------------------------------------------
