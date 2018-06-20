#!/bin/bash
#############################################################
# SignPDF: A simple way to add a signature image to a pdf at given page under linux.
#          The inserted signature has the same aspect ratio than the original.
#############################################################
# Description:
#   The script uses xv to display the page where the signature should be inserted. Click on two points inside xv with the left-mouse-button to define the signature's box corner. Don't maintain the mouse. It has to be two single clicks. The order of the click does not matter. Only the two last clicks are considered. Press q to quit xv. The signed file is generated in the same folder than the original, without overriding it. The signature keeps the same proportion than the original. You can move, but should not resize xv window.
#
# Written by : Emmanuel Branlard
# Date : April 2012
# Dependencies :  xv, pdftk, imagemagick .
#        To get xv: compile from source http://www.trilon.com/xv/d
#                   OR find a .deb repository on internet
# License : Feel free to modify and adapt it
#
# Usage:
#   First argument: pdf file 
#   Second argument: page number where the signature should be put
#   
#
# Example: Add a signature to file "my file.pdf" on page 5:
# ./SignPDF "my file.pdf" 5 "signature.png" 
#
# Note : You need to edit the SIGNATURE variable below for default signature
#        This script generates a folder where everything takes place
#        The folder is deleted afterwards. See line below:
TMP=tmp-folder-signpdf

if [ $# -eq 0 ]
then
    echo "
Usage: 
    SignPdf <PdfFile> <PageNumber> 
    SignPdf <PdfFile> <PageNumber> [SignatureFile]
Example:
    SignPdf \"my file.pdf\" 5 signature.png

Look at the source for more informations.
    "
    exit 0
elif [ $# -eq 2 ]
then
    SIGNATURE="/mnt/DataWin/Admin/IDs/SignatureBlue-New.pdf"
else
    SIGNATURE=$3
fi

echo " -------------- Called with:  -------------- 
File : $1
Page : $2
Signature: $SIGNATURE "


#  set -vx
DIR=`pwd`;
mkdir $TMP
cd $TMP

echo "-------------- Bursting pdf   -----------------"
pdftk "../$1" burst output page_%d.pdf
# convert -page A4 -units PixelsPerInch -density 100 page_$2.pdf page_$2.png
convert -density 100 page_$2.pdf page_$2.png


echo "-------------- !!! Click on two points defining the signature box -----------------"
echo "-------------- !!! Don't resize the window - you can move it though -----------------"
echo "--------------        Press q to exit       -----------------"
xv -nolimits -D 1 page_$2.png 2> log.log
# cat log.log |grep --colours=none ButtonPress |grep --colours=none mainW
# cat log.log |grep --color=none ButtonPress |grep --color=none mainW |tail -n 2 >buff.log
cat log.log |grep --color=none ButtonPress |grep --color=none mainW |tail -n 2|cut -c 29- > buff.log
x1=`awk -F, 'NR==1 {print $1}' buff.log|tr -d -c '[0-9]'`
y1=`awk -F, 'NR==1 {print $2}' buff.log|tr -d -c '[0-9]'`
x2=`awk -F, 'NR==2 {print $1}' buff.log|tr -d -c '[0-9]'`
y2=`awk -F, 'NR==2 {print $2}' buff.log|tr -d -c '[0-9]'`

# dimensions of the rectangle specified by the user
dx=`expr $x2 - $x1`
dy0=`expr $y1 - $y2`

# a flag to see if the user has gone up and down instead of down and up
reverse_flag=0
# checking user input
if [[ $dy0 -lt 0 ]]
then
    reverse_flag=1
    dy0=`expr $y2 - $y1`
fi 
if [[ $dx -lt 0 ]]
then
    buffer=$x2
    x2=$x1
    x1=$buffer
    dx=`expr $x2 - $x1`
fi

cd $DIR
# Signature image dimensions
dxs=`identify -format "%[fx:w]" "$SIGNATURE"|tr -d -c '[0-9]'`
dys=`identify -format "%[fx:h]" "$SIGNATURE"|tr -d -c '[0-9]'`
cd $TMP

# Keeping aspect ratio of the signature
dy=`expr $dx \* $dys / $dxs`

if [[ $reverse_flag -eq 0 ]]
then
    # Here it's tricky either you use the user input $dy0 or $dyA
    y1=`expr $y1 - $dy0`
fi 
# The following because I chose to double the density
# dx=`expr $dx \* 2`
# dy=`expr $dy \* 2`
# y1=`expr $y1 \* 2`
# x1=`expr $x1 \* 2`
# composite -geometry  100x100+$y1+$x1 $SIGNATURE page_$2.png composite.png
echo "-------------- Inserting Signature at lower left corner: +$x1+$y1"

cd $DIR
composite -geometry  "$dx"x"$dy"+$x1+$y1 "$SIGNATURE" $TMP/page_$2.png $TMP/page_$2b.png
convert -density 100 $TMP/page_$2b.png $TMP/page_$2.pdf
pdftk $TMP/page_*.pdf cat output "${1%.pdf}_signed.pdf"


echo "-------------- File ${1%.pdf}_signed.pdf created  ------------- "
echo "-------------- Done -------------"
rm -r $TMP


