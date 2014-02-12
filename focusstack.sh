#!/bin/bash
# Focus stacking script

align_image_stack -m -a input `ls *JPG`
#enfuse --exposure-weight=0 --saturation-weight=0 --contrast-weight=1 --hard-mask --contrast-window-size=5 --gray-projector=l-star --output=output.tif input*tif
enfuse --exposure-weight=0 --saturation-weight=0 --contrast-weight=1 --hard-mask --contrast-edge-scale=0.4 --gray-projector=l-star --output=output.tif input*tif
