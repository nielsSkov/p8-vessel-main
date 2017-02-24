import serial

serialport = '/dev/lli'
speed = 57600
time = 0.02
STARTCHAR = ord('$')

connection = serial.Serial(serialport,speed,timeout=time)

#connection.open()

while connection.isOpen():
	try:
		char = connection.read()
		if char == '$':
			length = ord(connection.read())
			print length
	except KeyboardInterrupt:
        	connection.close()
