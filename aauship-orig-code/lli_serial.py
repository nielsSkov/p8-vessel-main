import serial

ser = serial.Serial()
ser.port = "/dev/lli"
ser.baudrate = 57600
ser.timeout = 0.02

ser.open()
while ser.isOpen():
	try:
		line = ser.readline()
		print line
	except KeyboardInterrupt:
		ser.close()

print "Done"
