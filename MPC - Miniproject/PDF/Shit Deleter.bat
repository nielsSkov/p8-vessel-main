echo off

rem the following deletes only files and NOT directories.

del "*.aux"
del "*.bbl"
del "*.bcf"
del "*.blg"
del "*.brf"
del "*.log"
del "*.lox"
del "*.nav"
del "*.out"
del "*.run.xml"
del "*.snm"
del "*.synctex.gz"
del "*.synctex.gz(busy)"
del "*.tdo"
del "*.toc"
del "*.tps"

cd .\Chapters\Chapter1
del "*.aux"
cd ..\..\Chapters\Chapter2
del "*.aux"
cd ..\..\Chapters\Chapter3
del "*.aux"
cd ..\..\formalities
del "*.aux"
cd ..\appendix
del "*.aux"