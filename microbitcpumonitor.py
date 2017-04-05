import serial, psutil, time
gradients = 20
readingList = [0,1,2,3,4]
ser = serial.Serial("/dev/ttyACM0", 115200, timeout=1)
ser.close()
ser.open()
print "Started monitoring system statistics for micro:bit display."
ser.write("from microbit import * \r".encode())
time.sleep(0.1)
ser.write("display.clear() \r".encode())
time.sleep(0.1)
barGraph = [[0, 0, 0, 0, 0], [0, 0, 0, 0, 0], [0, 0, 0, 0, 0], [0, 0, 0, 0, 0], [0, 0, 0, 0, 0]]
while True:
    sysLoad = psutil.cpu_percent(interval=0)
    readingList.insert(0,int(sysLoad))
    del readingList[5:]
    for x in range(5):
        for y in range(5):
            readingComparison = (y+1) * gradients
            if (readingList[x] >= readingComparison):
                barGraph[y][x] = 9
            else:
                barGraph[y][x] = 0
    ser.write("BARGRAPH = Image(\"%s:%s:%s:%s:%s\") \r".encode() % (''.join(str(e) for e in barGraph[0]), ''.join(str(e) for e in barGraph[1]), ''.join(str(e) for e in barGraph[2]), ''.join(str(e) for e in barGraph[3]), ''.join(str(e) for e in barGraph[4])))
    time.sleep(0.1)
    ser.write("display.show(BARGRAPH) \r".encode())
    time.sleep(0.9)
