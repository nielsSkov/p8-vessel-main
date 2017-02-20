#
# Makefile til projektet
# Kræver latexmk og ca. hele texlive-distributionen
#


# Navn på masterfil
TARGET=aalborgtheme

# Alle DIA-diagrammer
FIGS_DIA=

# Alle SVG-filer
#FIGS_SVG=illustrations/cover.svg

# Alle EPS-filer (PS-illustrationer angivet i linien nedenunder)
#FIGS_EPS= \

# Alle PDF-filer
FIGS_PDF= 

# Alle JPEG-filer, kun endelsen jpeg genkendes. Kræver jpeg2ps,
# http://www.pdflib.com/download/free-software/jpeg2ps/
FIGS_JPEG=

# Initialisering til figurkonvertering
FIGS_EPS_GEN=$(FIGS_DIA:.dia=.eps) $(FIGS_PDF:.pdf=.eps) $(FIGS_JPEG:.jpeg=.eps) $(FIGS_SVG:.svg=.eps)
FIGS_PDF_GEN=$(FIGS_DIA:.dia=.pdf) $(FIGS_EPS:.eps=.pdf) $(FIGS_SVG:.svg=.pdf)


.SUFFIXES: .dia .eps .pdf .jpeg .svg .ps

debug:	$(FIGS_PDF_GEN)
	latexmk -pdf -pdflatex="pdflatex --shell-escape %O %S" $(TARGET)

final:	$(FIGS_PDF_GEN)
	latexmk -pdf $(TARGET)
	latexmk -c
	rm -f $(TARGET).lox
	rm -f $(TARGET).out
	rm -f *.aux
	rm -f *.bak
	rm -f $(FIGS_EPS_GEN)
	rm -f $(FIGS_PDF_GEN)

dvi:	$(FIGS_EPS_GEN)
	latexmk $(TARGET)

ps:	$(FIGS_EPS_GEN)
	latexmk -ps $(TARGET)

pdf: $(FIGS_PDF_GEN)
	latexmk -pdf -pdflatex="pdflatex --shell-escape %O %S" $(TARGET)

blazingfast:	$(FIGS_PDF_GEN)
	latexmk -pdf -silent -pdflatex="pdflatex --shell-escape %O %S" $(TARGET)

clean:
	latexmk -C
	rm -f $(TARGET).lox
	rm -f $(TARGET).out
	rm -f *.aux
	rm -f *.bak
	rm -f $(FIGS_EPS_GEN)
	rm -f $(FIGS_PDF_GEN)
	rm -f fig/*.pdf
	rm -f fig/*.pdf_tex
	rm -f *.maf
	rm -f *.mtc*
	rm -f *.bbl

cleanex:
	latexmk -C
	rm -f $(TARGET).lox
	rm -f $(TARGET).out
	rm -f *.aux
	rm -f *.bak

live:
	latexmk -pvc -pdf -quiet -pdflatex="pdflatex --shell-escape %O %S" $(TARGET).tex

raw:
	pdflatex $(TARGET)
	bibtex $(TARGET)
	pdflatex $(TARGET)
	pdflatex $(TARGET)


# Konvertering mellem forskellige formater

# fx dia -t eps -e target.eps target.dia
.dia.eps:
	dia -t eps -e $@ $<

# fx jpeg2ps target.jpeg > target.eps
.jpeg.eps:
	jpeg2ps $< > $@

# fx inkscape --export-eps=target.eps --export-text-to-path target.svg
.svg.eps:
	inkscape --export-eps=$@ --export-text-to-path $<

# fx inkscape --export-pdf=target.pdf --export-text-to-path target.svg
.svg.pdf:
	inkscape -D -z --export-pdf=$@ $<

