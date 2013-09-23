#!/bin/bash
# Testing vectorising a PDF

for i in *.pdf
do
  echo Exploding $i into images...
  pdfimages $i output
  echo Vectorising...
  #ls output* | xargs -i --max-procs=4 bash -c "potrace {} -o {}.pdf -b pdf"
  parallel potrace {} -o {.}.pdf -b pdf --progress -k 0.75 ::: *.ppm
  echo Combining PDFs...
  pdftk output*.pdf cat output vectorised_$i
  echo File vectorised_$i complete. Cleaning up...
  rm output*
  echo Done.
done
