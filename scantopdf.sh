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
#    pngcrush
# <gareth@halfacree.co.uk>
# https://freelance.halfacree.co.uk

DPIMANUAL=0
OUTPUT="scan.pdf"
QUALITY=85
BACKGROUND="white"
DISABLEINVERSION="-c tessedit_do_invert=0"
FORCEJPEG=0
FORCEPNG=0
GREYSCALE=0
BILEVEL=0
THRESHOLD=68
THRESHOLDPROCESS=0
GREYSCALECOMMAND=""
DIRECTORYPREFIX=""

TEMPDIR=$(mktemp -d)

while getopts ":r:b:q:o:i:t:zjpglh" FLAG; do
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
            echo "        -j - Force JPEG imagery even if input files are grayscale"
            echo "        -p - Force PNG imagery even if input files are colour"
            echo "        -g - Force four-colour greyscale output"
            echo "........-l - Force two-colour lineart output"
            echo "........-t - Pre-process PNGs to two-colour"
            echo "        -z - Use Zopfli compression for PNG output (slower, smaller files)"
            echo "        -h - This help"
            exit 0
            ;;
        i )
            echo "FLAG -i: Enabling inverted text support."
            DISABLEINVERSION=""
            ;;
        j )
            echo "FLAG -j: Forcing JPEG imagery."
            FORCEJPEG=1
            ;;
        p )
            echo "FLAG -p: Forcing PNG imagery."
            FORCEPNG=1
            ;;
        g )
            echo "FLAG -g: Forcing four-colour greyscale output."
            GREYSCALE=1
            ;;
        l ) 
            echo "FLAG -l: Forcing two-colour lineart output."
            BILEVEL=1
            ;;
        t ) 
            THRESHOLD="$OPTARG"
            THRESHOLDPROCESS=1
            BILEVEL=1
            case $THRESHOLD in
                ''|*[!0-9]*)
                    echo "ERROR: -t must be a positive integer in threshold percent."
                    exit 1
                    ;;
            esac
            if [[ $THRESHOLD -lt 0 || $THRESHOLD -gt 100 ]]; then
                echo "ERROR: -t must be a threshold level in percent."
                exit 1
            fi
            echo "FLAG -t: Pre-processing images to two-colour lineart at $THRESHOLD% threshold."
            ;;
        z )
            echo "FLAG -z: Compressing PNGs with Zopfli."
            if [[ ! $(which zopflipng) ]]; then
                echo "ERROR: Zopfli requested but not installed; install Zopfli or remove -z flag."
                exit 1
            fi
            ZOPFLI=1
            ;;
        o )
            OUTPUT="$OPTARG"
            echo "FLAG -o: Will output to $OUTPUT."
            ;;
        r )
            DPI="$OPTARG"
            DPIMANUAL=1
            case $DPI in
                ''|*[!0-9]*)
                    echo "ERROR: -r must be a positive integer in DPI."
                    exit 1
                    ;;
            esac
            echo "FLAG -r: Using manual resolution of $DPI DPI."
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
            echo "FLAG -q: Using manual quality of $QUALITY%."
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
            echo "FLAG -b: Using manual background colour of $BACKGROUND."
            ;;
        * )
            echo "ERROR: Flag -$OPTARG not recognised."
            echo "    Usage: scantopdf.sh -r resolution -q quality -o output"
            echo "        -r - Scan resolution in dots per inch (DPI)"
            echo "        -q - JPEG quality in percent"
            echo "        -b - Page background colour, white or black"
            echo "        -o - Filename for output PDF"
            echo "        -i - Search for inverted text during OCR stage"
            echo "        -j - Force JPEG imagery even if input files are grayscale"
            echo "        -p - Force PNG imagery even if input files are colour"
            echo "        -g - Force four-colour greyscale output"
            echo "        -z - Use Zopfli compression for PNG output (slower, smaller files)"
            echo "        -h - This help"
            exit 1
            ;;
    esac
done
shift $((OPTIND -1))

if [[ ! $(ls *[pP][nN][gG] 2>/dev/null) ]]; then
    echo "ERROR: No PNG files found in current directory."
    exit 1
fi

for i in parallel convert jpgcrush-moz pngcrush jpegrescan mozjpeg tesseract pdftk; do
    if [[ ! $(which $i) ]]; then
        echo "ERROR: Dependency $i not found, please install and/or add to path."
        exit 1
    fi
done

if [[ $FORCEJPEG == 1 ]] && [[ $FORCEPNG == 1 ]]; then
    echo "ERROR: Can't force images to both JPEG and PNG format at the same time."
    exit 1
fi

echo "Found $(ls -1 *[pP][nN][gG] | wc -l) PNG file(s)..."

if [[ $THRESHOLDPROCESS == 1 ]]; then
    echo "Processing PNGs into lineart at $THRESHOLD%..."
    mkdir "$TEMPDIR/lineart"
    parallel --ungroup convert -limit thread 1 "{}" -threshold $THRESHOLD% -depth 1 -colorspace gray "$TEMPDIR/lineart/{.}.png" ::: *[pP][nN][gG]
    DIRECTORYPREFIX="$TEMPDIR/lineart/"
fi

if [[ ! $DPIMANUAL == 1 ]]; then
    echo "    Determining resolution from $(ls -1 *[pP][nN][gG] | head -1)..."
    DPI=$(identify -format '%x' -units PixelsPerInch "$(ls -1 *[pP][nN][gG] | head -1)")
    echo "    Using $DPI DPI. To override, cancel and run with -r resolution flag."
fi

IMAGETYPE=$(identify -verbose "$(ls -1 *[pP][nN][gG] | head -1)" | grep Type | cut -d":" -f2)

if [[ $IMAGETYPE == " Grayscale" || $GREYSCALE == 1 ]] && [[ ! $BILEVEL == 1 ]]; then
    echo "    Grayscale scans detected or -g flag used, setting output files to four-shade greyscale."
    GREYSCALECOMMAND="-colorspace gray -colors 4 -depth 2"
    GREYSCALE=1
elif [[ $IMAGETYPE == " Bilevel" ]] || [[ $BILEVEL == 1 ]]; then
    echo "    Black and white scans detected or -l flag used, setting output files to 1-bit bilevel."
    GREYSCALECOMMAND="-colorspace gray -depth 1"
    GREYSCALE=1
fi

if [[ $FORCEPNG == 1 ]] || [[ $GREYSCALE == 1 && $FORCEJPEG == 0 ]]; then
    echo "    Grayscale scans detected, -p flag, or -l flag used; will not convert to JPEGs."
    echo "Trimming, deskewing, normalising, sharpening PNGs..."
    mkdir "$TEMPDIR"/unoptimised
    parallel --ungroup convert -limit thread 1 "{}" -density "$DPI"x"$DPI" -units PixelsPerInch -background "$BACKGROUND" -fuzz 75% -deskew 75% -shave 25x25 -normalize -unsharp 0 $GREYSCALECOMMAND +repage "$TEMPDIR/unoptimised/{/.}.png" ::: "$DIRECTORYPREFIX"*[pP][nN][gG]
    if [[ $ZOPFLI == 1 ]]; then
        echo "Compressing PNG files with Zopfli..."
        parallel --ungroup zopflipng "{}" "$TEMPDIR"/"{/}" &> /dev/null ::: "$TEMPDIR"/unoptimised/*png
    else
        echo "Losslessly optimising PNG files..."
        parallel --ungroup pngcrush -q "{}" "$TEMPDIR"/"{/}" &> /dev/null ::: "$TEMPDIR"/unoptimised/*png
    fi
    
else
    echo "Trimming, deskewing, normalising, sharpening, and converting to JPEG at $QUALITY% quality..."
    parallel --ungroup convert -limit thread 1 "{}" -density "$DPI"x"$DPI" -units PixelsPerInch -background "$BACKGROUND" -fuzz 75% -deskew 75% -shave 25x25 -normalize -unsharp 0 -quality "$QUALITY"% $GREYSCALECOMMAND +repage "$TEMPDIR/{/.}.jpg" ::: "$DIRECTORYPREFIX"*[pP][nN][gG]
    cd "$TEMPDIR"
    echo "Losslessly optimising JPEG files..."
    parallel --ungroup jpgcrush-moz "{}" &> /dev/null ::: "$TEMPDIR"/*jpg
    cd "$OLDPWD"
fi

echo "Performing OCR..."
parallel --ungroup OMP_THREAD_LIMIT=1 tesseract $DISABLEINVERSION "{}" "{.}" pdf &> /dev/null ::: "$TEMPDIR"/*[pj][np][g]

echo "Creating output PDF..."
pdftk "$TEMPDIR/"*pdf cat output "$OUTPUT"
echo "    File $OUTPUT created, size $(du -h "$OUTPUT" | cut -f1)."

echo "Cleaning up..."
rm -r "$TEMPDIR"

echo "Finished!"
exit 0
