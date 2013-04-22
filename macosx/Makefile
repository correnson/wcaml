# --------------------------------------------------------------------------
# --- WCAML API                                                          ---
# --------------------------------------------------------------------------

.PHONY: all opt rebuild

all: opt wcaml
rebuild:
	$(MAKE) clean depend
	$(MAKE) all

# --------------------------------------------------------------------------

wcaml: wpack.ml
	$(OCAMLOPT) -o $@ $<

# --------------------------------------------------------------------------

include ../design/MakeWcaml
include ../design/MakePort

# --------------------------------------------------------------------------

OPTML= -w PSUZMV -warn-error PSUZMV
OPTCMX= -for-pack Wcaml

WCAML_SRC= main port user
WCAML_TYPES= widget.cmi
WCAML_CMI=$(addsuffix .cmi, $(WCAML_LIB) $(WCAML_SRC))
WCAML_CMX=$(addsuffix .cmx, $(WCAML_LIB) $(WCAML_SRC))

# --------------------------------------------------------------------------

OBJC= CSapp.o CSmain.o CSdata.o CSuser.o

# --------------------------------------------------------------------------

opt: wcaml.cmxa 
wcaml.cmxa: wcaml.cmx $(OBJC)
	$(OCAMLMKLIB) -framework AppKit -o wcaml wcaml.cmx $(OBJC)

wcaml.cmx: .port $(WCAML_TYPES) $(WCAML_CMX)
	$(OCAMLOPT) -o wcaml.cmx -pack $(WCAML_TYPES) $(WCAML_CMX)

depend: .port

# --------------------------------------------------------------------------

install:
	@ocamlfind remove wcaml
	@ocamlfind install wcaml META wcaml wcaml.cmi wcaml.cmxa wcaml.a libwcaml.a

uninstall:
	@ocamlfind remove wcaml

# --------------------------------------------------------------------------
include ../design/MakeOcaml
# --------------------------------------------------------------------------

CSmain.m: CSapp.h
CSuser.m: CSdata.h

.m.h: CS.h
.m.o:
	gcc -c -I$(OCAMLLIB) -O3 $<
# --------------------------------------------------------------------------
