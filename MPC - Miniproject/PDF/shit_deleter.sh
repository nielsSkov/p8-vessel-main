#!/bin/bash

# Removes every unneeded files generated from the compilation
find . -name \*.aux -type f -exec rm -f {} + 
find . -name \*.bbl -type f -exec rm -f {} + 
find . -name \*.bcf -type f -exec rm -f {} + 
find . -name \*.blg -type f -exec rm -f {} + 
find . -name \*.brf -type f -exec rm -f {} + 
find . -name \*.log -type f -exec rm -f {} + 
find . -name \*.lox -type f -exec rm -f {} + 
find . -name \*.out -type f -exec rm -f {} + 
find . -name \*.run.xml -type f -exec rm -f {} + 
find . -name \*.synctex.gz -type f -exec rm -f {} + 
find . -name \*.tdo -type f -exec rm -f {} + 
find . -name \*.toc -type f -exec rm -f {} + 
find . -name \*.tps -type f -exec rm -f {} +
find . -name \*.ini -type f -exec rm -f {} +
find . -name \*.make -type f -exec rm -f {} +
find . -name \*.d -type f -exec rm -f {} +
find . -name \*.thm -type f -exec rm -f {} +
find . -name \*.fls -type f -exec rm -f {} +
