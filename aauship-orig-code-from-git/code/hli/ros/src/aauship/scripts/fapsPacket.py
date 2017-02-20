import serial
import threading
import time
import datetime
import Queue
import struct

running = True;
STARTCHAR = ord('$')

# Class for managing the packets to and from the LLI
class Handler(threading.Thread):
    
    def __init__(self,serialport,speed,time,queue):
        self.connection = serial.Serial(serialport,speed,timeout=time)
        self.q = queue #Queue to share data between threads
        self.errorcount = 0
        self.table = [ #CRC16 lookup table
            0x0000, 0x1189, 0x2312, 0x329B, 0x4624, 0x57AD, 0x6536, 0x74BF,
            0x8C48, 0x9DC1, 0xAF5A, 0xBED3, 0xCA6C, 0xDBE5, 0xE97E, 0xF8F7,
            0x1081, 0x0108, 0x3393, 0x221A, 0x56A5, 0x472C, 0x75B7, 0x643E,
            0x9CC9, 0x8D40, 0xBFDB, 0xAE52, 0xDAED, 0xCB64, 0xF9FF, 0xE876,
            0x2102, 0x308B, 0x0210, 0x1399, 0x6726, 0x76AF, 0x4434, 0x55BD,
            0xAD4A, 0xBCC3, 0x8E58, 0x9FD1, 0xEB6E, 0xFAE7, 0xC87C, 0xD9F5,
            0x3183, 0x200A, 0x1291, 0x0318, 0x77A7, 0x662E, 0x54B5, 0x453C,
            0xBDCB, 0xAC42, 0x9ED9, 0x8F50, 0xFBEF, 0xEA66, 0xD8FD, 0xC974,
            0x4204, 0x538D, 0x6116, 0x709F, 0x0420, 0x15A9, 0x2732, 0x36BB,
            0xCE4C, 0xDFC5, 0xED5E, 0xFCD7, 0x8868, 0x99E1, 0xAB7A, 0xBAF3,
            0x5285, 0x430C, 0x7197, 0x601E, 0x14A1, 0x0528, 0x37B3, 0x263A,
            0xDECD, 0xCF44, 0xFDDF, 0xEC56, 0x98E9, 0x8960, 0xBBFB, 0xAA72,
            0x6306, 0x728F, 0x4014, 0x519D, 0x2522, 0x34AB, 0x0630, 0x17B9,
            0xEF4E, 0xFEC7, 0xCC5C, 0xDDD5, 0xA96A, 0xB8E3, 0x8A78, 0x9BF1,
            0x7387, 0x620E, 0x5095, 0x411C, 0x35A3, 0x242A, 0x16B1, 0x0738,
            0xFFCF, 0xEE46, 0xDCDD, 0xCD54, 0xB9EB, 0xA862, 0x9AF9, 0x8B70,
            0x8408, 0x9581, 0xA71A, 0xB693, 0xC22C, 0xD3A5, 0xE13E, 0xF0B7,
            0x0840, 0x19C9, 0x2B52, 0x3ADB, 0x4E64, 0x5FED, 0x6D76, 0x7CFF,
            0x9489, 0x8500, 0xB79B, 0xA612, 0xD2AD, 0xC324, 0xF1BF, 0xE036,
            0x18C1, 0x0948, 0x3BD3, 0x2A5A, 0x5EE5, 0x4F6C, 0x7DF7, 0x6C7E,
            0xA50A, 0xB483, 0x8618, 0x9791, 0xE32E, 0xF2A7, 0xC03C, 0xD1B5,
            0x2942, 0x38CB, 0x0A50, 0x1BD9, 0x6F66, 0x7EEF, 0x4C74, 0x5DFD,
            0xB58B, 0xA402, 0x9699, 0x8710, 0xF3AF, 0xE226, 0xD0BD, 0xC134,
            0x39C3, 0x284A, 0x1AD1, 0x0B58, 0x7FE7, 0x6E6E, 0x5CF5, 0x4D7C,
            0xC60C, 0xD785, 0xE51E, 0xF497, 0x8028, 0x91A1, 0xA33A, 0xB2B3,
            0x4A44, 0x5BCD, 0x6956, 0x78DF, 0x0C60, 0x1DE9, 0x2F72, 0x3EFB,
            0xD68D, 0xC704, 0xF59F, 0xE416, 0x90A9, 0x8120, 0xB3BB, 0xA232,
            0x5AC5, 0x4B4C, 0x79D7, 0x685E, 0x1CE1, 0x0D68, 0x3FF3, 0x2E7A,
            0xE70E, 0xF687, 0xC41C, 0xD595, 0xA12A, 0xB0A3, 0x8238, 0x93B1,
            0x6B46, 0x7ACF, 0x4854, 0x59DD, 0x2D62, 0x3CEB, 0x0E70, 0x1FF9,
            0xF78F, 0xE606, 0xD49D, 0xC514, 0xB1AB, 0xA022, 0x92B9, 0x8330,
            0x7BC7, 0x6A4E, 0x58D5, 0x495C, 0x3DE3, 0x2C6A, 0x1EF1, 0x0F78]
        threading.Thread.__init__(self) #Initialize Thread
    

    ## run() method for fapsParse.Handler
    def run(self):
        print "Running Handler thread"
        while self.connection.isOpen():    
            try:
                checkchar = self.connection.read(1)#Try will not fail if we could read something
                if checkchar == chr(STARTCHAR):    #Read char until start char is found
                    length=self.connection.read(1) #The next char after start byte is the length
                    res = self.parser(length)      #Input the length into the parser function to get packet
                    if(res[0]):                    #If the packet is valid, prepare the packet and put it in the queue
                        #print "Valid packet", str(time.time())
                        packetforqueue = self.unpackage(res[1])
                        self.q.put(packetforqueue)
                    else:
                        print '\033[1m' # White terminal color
                        print res
                        print '\033[0m' # Reset terminal color
            #    elif checkchar == '':
            #        What is the purpose of this? Uncommented for now.
            #        endpacket = {'DevID': chr(255) , 'MsgID': 0,'Data': 0, 'Time': time.time()}
            #        self.q.put(endpacket)
            except KeyboardInterrupt:
                self.connection.close()
            except Exception as inst:
                print "Exception in fapsPacket.run():\t" + str(time.time()) + " " + str(inst)
                pass
        running = False
        return


    ## Method to close the serial connection
    def close(self):
        print "Error count:", str(self.errorcount)
        self.connection.close()
        

    ## Generate CRC16 CCITT two byte checksum
    def crc16_ccitt_calc(self,packet):
        crc = 0xFFFF

        ## I am not quite sure what thsi try except is usefulls for, sould probably be removed
        try:
            if ord(packet[0]) != 12:
                pass
                #print str(packet)
        except:
            #print str(packet)
            pass

        for i in packet:
            try:
                value = (crc ^ i) & 0xFF        #If the value of 'i' is an int
            except:
                value = (crc ^ ord(i)) & 0xFF   #If the value of 'i' is a chr
            crc = (crc >> 8) ^self.table[value]    
        result = [chr((crc>>8)&0xFF),chr(crc&0xFF)] #Format checksum correctly
        return result


    ## Method to see if the serial connection is open
    def isOpen(self):
        return self.connection.isOpen()
    
 
    ## Verifies weather a packet is valid or not
    def verifyPacket(self,packet):
        p = packet[:] #Copy packet to p

        incCheck=[p.pop(),p.pop()] #Remove the two checksum bytes
        incCheck.reverse()
        check = self.crc16_ccitt_calc(p)   #Get the checksum of the bit.

        if incCheck == check:
            return True
        else:
            print "WARNING: Errorlog written!"
            errorlog = open('errorlog.log', 'a')
            errorlog.write("".join(packet) + "[" + str(ord(incCheck[0])) + " " + str(ord(incCheck[1])) + "] - [" + str(ord(check[0])) + " " + str(ord(check[1])) + "]\n")
            errorlog.close()
            return False


    ## Method that parses the recieved data
    #
    #  This funciton is odd and peculiar in general
    def parser(self,array):
        packet = []
        length = 1

        try:
            length = len(array)
            for j in range(length):
                packet.append(array[j])
        except:
            packet.append(array)

        for i in range((ord(packet[0])-length+5)):
            tempc = self.connection.read(1)
            deltaerr = 0
            if not tempc:
                tempc = self.connection.read(1)
                self.errorcount += 1
                if deltaerr > 10:
                    break
                deltaerr += 1

            packet.append(tempc)

        check = self.verifyPacket(packet)

        if(check):
            # We make sure that we have the valid/invlaid flag on the packet
            return [True, packet]
        else: # I am not sure what the purpose of this else block with the try section is
            try:
                print("Hic sunt leones")
                index = packet.index(0x24)
                if index == len(packet)-1:
                    tempc = self.connection.read(1)
                    deltaerr = 0
                    while not tempc:
                        tempc = self.connection.read(1)
                        self.errorcount += 1
                        if deltaerr > 10:
                            break
                        deltaerr += 1

                    packet.append(tempc)

                del packet[0:index+1]
                print("Hic sunt dracones")
                return self.parser(packet)
            except:
                return [False,packet]
                pass


    ## Arrange recieved data into a packet dict
    def unpackage(self,packet):
        length = packet[0]
        DevID = packet[1]
        MsgID = packet[2]
        Data = []
        for i in range(ord(length)):
            Data.append(packet[3+i])
        newpacket = {'DevID':DevID, 'MsgID': MsgID,'Data': Data, 'Time': time.time()}
        return newpacket


    ## Arrange data into a packet array, without the startchar and checksum
    def package(self,data,DevID,MsgID):
        try:
            length = len(data) #If the data is a string, get the length of the string
            dat = data         #If the data is a string, the data needs no formatting
        except TypeError:      #The above will give a typeError if its a number
            length = 0         #Initial length
            num = []
            dat = []
            while (data >> 8*length) > 0:              #Divide data into bytes
                num.append((data >> (8*length)) & 255) #Append bytewise
                length = length+1                      #Increment length of data
                print(length)
                print("FOOOOOO")
            for i in reversed(num): #Append the data to the dat array in reverse, due to endianness
                dat.append(i)
        
        packet = [length,DevID,MsgID] #The first part of the packet contains the length, the DevID and the MsgID
        
        for i in range(length):
            packet.append(dat[i]) #The data is then appended
        return packet


    ## The funciton to send the packet
    #
    #  This sends the assembled packet on the serial connection
    def lli_send(self,packet):
        Checksum = self.crc16_ccitt_calc(packet) #First, the checksum of the packet is generated
        packet.append(Checksum[0])       #The checksum is appropriately appended
        packet.append(Checksum[1])

        self.connection.write(chr(STARTCHAR)) #The '$' is written
        for i in range(len(packet)):    #The byte are then written individually
            try:
                self.connection.write(chr(packet[i]))
            except:
                self.connection.write(packet[i])
    
