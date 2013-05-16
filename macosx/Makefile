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

OPTML= -w PSUZMV -warn-error PSUZMV
OPTCMX= -for-pack Wcaml

WCAML_SRC= main port user window control

WCAML_TYPES= widget.cmi
WCAML_CMI=$(addsuffix .cmi, $(WCAML_LIB) $(WCAML_SRC))
WCAML_CMX=$(addsuffix .cmx, $(WCAML_LIB) $(WCAML_SRC))

# --------------------------------------------------------------------------

OBJC= \
	CSapp.o CSmain.o CSdata.o CSuser.o CSwindow.o \
	CScell.o CSview.o CStext.o

# --------------------------------------------------------------------------

opt: wcaml.cmxa 
wcaml.cmxa: wcaml.cmx $(OBJC)
	$(OCAMLMKLIB) -framework AppKit -o wcaml wcaml.cmx $(OBJC)

wcaml.cmx: .port $(WCAML_TYPES) $(WCAML_CMX)
	$(OCAMLOPT) -o wcaml.cmx -pack $(WCAML_TYPES) $(WCAML_CMX)

depend: .port

# --------------------------------------------------------------------------

DISTRIB= wcamlpack wcaml.cmi wcaml.cmxa wcaml.a libwcaml.a

install:
	@ocamlfind remove wcaml
	@ocamlfind install wcaml META $(DISTRIB)

uninstall:
	@ocamlfind remove wcaml

# --------------------------------------------------------------------------
include ../design/MakeOcaml
# --------------------------------------------------------------------------

CSmain.m: CSapp.h
CSuser.m: CSdata.h
CSwindow.m:
CScell.m:
CSview.m:

.m.h: CS.h
.m.o:
	gcc -c -I$(OCAMLLIB) -O3 $<
# --------------------------------------------------------------------------
