:: This is a script to compile latex on windows
path %path%;"C:\Program Files (x86)\Inkscape\"
:: inkscape.exe

del thesis.pdf
latexmk -pdf --pdflatex="pdflatex --shell-escape" thesis.tex
