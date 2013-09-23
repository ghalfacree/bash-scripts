#!/bin/bash
#
# Shrink filesize of a PDF using GhostScript
#
# syntax :
#    ./shrinkpdf.sh in=[input-file].pdf out=[output-file].pdf res=[resolution]
 
outfile="out.pdf"
res="72"
 
for arg; do
  case $arg in
    in=*) infile=${arg#in=};;
    out=*) outfile=${arg#out=};;
    res=*) res=${arg#res=};;
  esac;
done
if [ -z "$infile" ]; then
   usage;
   exit 1;
fi
 
echo "Shrinking pdf..."
echo "This may take some time."
gs -q -dNOPAUSE -dBATCH -dSAFER \
	-sDEVICE=pdfwrite \
	-dCompatibilityLevel=1.5 \
	-dPDFSETTINGS=/ebook \
	-dEmbedAllFonts=true \
	-dSubsetFonts=true \
	-dColorImageDownsampleType=/Bicubic \
	-dColorImageResolution=$res \
	-dGrayImageDownsampleType=/Bicubic \
	-dGrayImageResolution=$res \
	-dMonoImageDownsampleType=/Bicubic \
	-dMonoImageResolution=$res \
	-sColorConversionStrategy=LeaveColorUnchanged \
	-sOutputFile="$outfile" \
	 "$infile"
echo "Finished."
echo "Output data saved to $outfile"
