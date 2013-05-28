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

WCAML_SRC= \
	main port portcontrol \
	user window control text layout

WCAML_TYPES= widget.cmi
WCAML_CMI=$(addsuffix .cmi, $(WCAML_LIB) $(WCAML_SRC))
WCAML_CMX=$(addsuffix .cmx, $(WCAML_LIB) $(WCAML_SRC))

# --------------------------------------------------------------------------

OBJC= \
	CSapp.o CSmain.o CSdata.o CSuser.o CSwindow.o \
	CScell.o CSview.o CScontrol.o CStext.o

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

CSmain.o: CSmain.h CSapp.h
CSuser.o: CSuser.h CSdata.h
CSwindow.o: CSwindow.h
CScell.o: CScell.h
CSview.o: CSview.h
CScontrol.o: CScontrol.h

.m.o: CS.h
	gcc -c -I$(OCAMLLIB) -O2 $<

# --------------------------------------------------------------------------
