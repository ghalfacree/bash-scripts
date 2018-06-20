#!/usr/bin/python

import wave
import struct
import sys
import csv
import numpy 
from scipy.io import wavfile
from scipy.signal import resample

def write_wav(data, filename, framerate, amplitude):
    wavfile = wave.open(filename,'w')
    nchannels = 1
    sampwidth = 2
    framerate = framerate
    nframes = len(data)
    comptype = "NONE"
    compname = "not compressed"
    wavfile.setparams((nchannels,
                        sampwidth,
                        framerate,
                        nframes,
                        comptype,
                        compname))
    frames = []
    for s in data:
        mul = int(s * amplitude)
        frames.append(struct.pack('h', mul))

    frames = ''.join(frames)
    wavfile.writeframes(frames)
    wavfile.close()
    print("%s written" %(filename)) 


if __name__ == "__main__":
    if len(sys.argv) <= 1:
        print ("You must supply a filename to generate")
        exit(-1)
    for fname in sys.argv[1:]:

        data = []
        for time, value in csv.reader(open(fname, 'U'), delimiter=','):
            try:
                data.append(float(value))#Here you can see that the time column is skipped
            except ValueError:
                pass # Just skip it


        arr = numpy.array(data)#Just organize all your samples into an array
        # Normalize data
        arr /= numpy.max(numpy.abs(data)) #Divide all your samples by the max sample value
        filename_head, extension = fname.rsplit(".", 1)        
        data_resampled = resample( arr, len(data) )
        wavfile.write('rec.wav', 16000, data_resampled) #resampling at 16khz
        print ("File written succesfully !")
