#!/bin/bash
# Testing vectorising a PNG

parallel -u 'echo Converting {} into PPM... && convert {} /tmp/{.}.ppm && echo Vectorising {.}.ppm... && potrace /tmp/{.}.ppm -o {.}.pdf -b pdf && echo Deleting {.}.ppm && rm /tmp/{.}.ppm' ::: *.png 
