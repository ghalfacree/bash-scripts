#!/bin/bash
# Scan to PDF, a handy-dandy shell script for converting PNGs to a PDF with
# searchable text.
# Requires:
#    GNU Parallel
#    ImageMagick
#    jpegcrush-moz (you can get this in the same place as scantopdf.sh)
#        Everything jpgcrush-moz needs: jpegrescan, mozjpeg
#    tesseract
#    pdftk
# <gareth@halfacree.co.uk>
# https://freelance.halfacree.co.uk

DPI=300
OUTPUT="scan.pdf"
QUALITY=85
BACKGROUND="white"
DISABLEINVERSION="-c tessedit_do_invert=0"

TEMPDIR=$(mktemp -d)

while getopts ":robqih" FLAG; do
    case $FLAG in
        h )
            echo "scantopdf.sh: Script to turn PNGs into a PDF with searchable text"
            echo "<gareth@halfacree.co.uk> / https://freelance.halfacree.co.uk"
            echo "    Usage: scantopdf.sh -r resolution -q quality -o output"
            echo "        -r - Scan resolution in dots per inch (DPI)"
            echo "        -q - JPEG quality in percent"
            echo "        -b - Page background colour, white or black"
            echo "        -o - Filename for output PDF"
            echo "        -i - Search for inverted text during OCR stage"
            echo "        -h - This help"
            exit 0
            ;;
        i )
            DISABLEINVERSION=""
            ;;
        o )
            OUTPUT="$OPTARG"
            ;;
        r )
            DPI="$OPTARG"
            case $DPI in
                ''|*[!0-9]*)
                    echo "ERROR: -r must be a positive integer in DPI."
                    exit 1
                    ;;
            esac
            ;;
        q )
            QUALITY="$OPTARG"
            case $QUALITY in
                ''|*[!0-9]*)
                    echo "ERROR: -q must be a positive integer in JPEG quality."
                    exit 1
                    ;;
            esac
            if [[ $QUALITY -lt 0 || $QUALITY -gt 100 ]]; then
                echo "ERROR: -q must be a JPEG quality percentage between 0 and 100."
                exit 1
            fi
            ;;
        b )
            BACKGROUND="$OPTARG"
            case $BACKGROUND in
                "white" )
                    echo "Page background set to white."
                    ;;
                "black" )
                    echo "Page background set to black."
                    ;;
                * )
                    echo "ERROR: -b must be either black or white."
                    exit 1
                    ;;
            esac
            ;;
        * )
            echo "ERROR: Flag -$OPTARG not recognised."
            echo "    Usage: scantopdf.sh -r resolution -q quality -o output"
            echo "        -r - Scan resolution in dots per inch (DPI)"
            echo "        -q - JPEG quality in percent"
            echo "        -b - Page background colour, white or black"
            echo "        -o - Filename for output PDF"
            echo "        -i - Search for inverted text during OCR stage"
            echo "        -h - This help"
            exit 1
            ;;
    esac
done
shift $((OPTIND -1))

if [[ ! $(ls *[pPnNgG] 2>/dev/null) ]]; then
    echo "ERROR: No PNG files found in current directory."
    exit 1
fi

for i in parallel convert jpgcrush-moz jpegrescan mozjpeg tesseract pdftk; do
    if [[ ! $(which $i) ]]; then
        echo "ERROR: Dependency $i not found, please install and/or add to path."
        exit 1
    fi
done

echo "Found $(ls -1 *[pPnNgG] | wc -l) PNG file(s)..."
echo "Trimming, deskewing, sharpening, and converting to JPEG at $QUALITY% quality..."
parallel --ungroup convert -limit thread 1 "{}" -density "$DPI"x"$DPI" -units PixelsPerInch -background "$BACKGROUND" -fuzz 75% -deskew 75% -shave 25x25 -unsharp 0 -quality "$QUALITY"% +repage "$TEMPDIR/{.}.jpg" ::: *[pPnNgG]
cd "$TEMPDIR"
echo "Losslessly optimising JPEG files..."
parallel --ungroup jpgcrush-moz "{}" &> /dev/null ::: "$TEMPDIR"/*jpg
cd "$OLDPWD"
echo "Performing OCR..."
parallel --ungroup OMP_THREAD_LIMIT=1 tesseract $DISABLEINVERSION "{}" "{.}" pdf &> /dev/null ::: "$TEMPDIR"/*jpg
echo "Creating output PDF..."
pdftk "$TEMPDIR/"*pdf cat output "$OUTPUT"
echo File "$OUTPUT" created, size $(du -h "$OUTPUT" | cut -f1).
echo "Cleaning up..."
rm -rf "$TEMPDIR"
echo "Finished!"
exit 0
