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

OPTML= -w PSUZMV -warn-error PSUZMV
OPTCMX= -for-pack Wcaml

WCAML_SRC= 
WCAML_TYPES= widget.cmi
WCAML_CMI=$(addsuffix .cmi, $(WCAML_LIB) $(WCAML_SRC))
WCAML_CMX=$(addsuffix .cmx, $(WCAML_LIB) $(WCAML_SRC))

# --------------------------------------------------------------------------

OBJC= WSmain.o

# --------------------------------------------------------------------------

opt: wcaml.cmxa 
wcaml.cmxa: wcaml.cmx $(OBJC)
	$(OCAMLMKLIB) -framework AppKit -o wcaml wcaml.cmx $(OBJC)

wcaml.cmx: port $(WCAML_TYPES) $(WCAML_CMI) $(WCAML_CMX)
	$(OCAMLOPT) -o wcaml.cmx -pack $(WCAML_TYPES) $(WCAML_CMX)

depend: port

# --------------------------------------------------------------------------

INSTALL_DIR?=$(shell $(OCAMLOPT) -where)/wcaml

install:
	@echo "Install to $(INSTALL_DIR)"
	@mkdir -p $(INSTALL_DIR)
	@cp -f META wcaml.cmi wcaml.cmxa wcaml.a $(INSTALL_DIR)

uninstall:
	@echo "Removing $(INSTALL_DIR)"
	@rm -fr $(INSTALL_DIR)

# --------------------------------------------------------------------------
include ../design/MakeOcaml
# --------------------------------------------------------------------------
.m.h: WS.h
.m.o:
	gcc -c -I$(OCAMLLIB) -O3 $<
# --------------------------------------------------------------------------
