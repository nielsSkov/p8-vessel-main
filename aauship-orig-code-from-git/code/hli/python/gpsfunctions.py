from math import sqrt, sin, cos, pi, floor
import numpy
def wgs842ecef(lat,lon,h=None):
    if h == None:
        h = 0    
    a = 6378137.0
    e = 0.0818
    N = a / sqrt(1-e**2*sin(lat))
    
    result = numpy.zeros((3,1))
    result[0][0] = (N+h)*cos(lat)*cos(lon)
    result[1][0] = (N+h)*cos(lat)*sin(lon)
    result[2][0] = (N*(1-e**2)+h)*sin(lat)
    return result
    
def get_rot_matrix(centerlat,centerlon):

    Rot = numpy.matrix([[-sin(centerlat)*cos(centerlon), -sin(centerlat)*sin(centerlon), cos(centerlat)],
                        [-sin(centerlon), cos(centerlon), 0],
                        [-cos(centerlat)*cos(centerlon), - cos(centerlat)*sin(centerlon), -sin(centerlat)]])
    return Rot
    
def rotate(Pos,Rot):
    result = Rot*Pos
    return result
    
def nmea2decimal(lat,latsign,lon,lonsign):
    if (latsign == 'S'):
        lat = -lat
    if (lonsign == 'W'):
        lon = -lon
    pos = [lat, lon]
    majorangle = [floor(pos[0]/100), floor(pos[1]/100)]
    minorangle = [(pos[0] - majorangle[0]*100)/60,(pos[1] - majorangle[1]*100)/60]
    #print "Major: " + str(majorangle)
    #print "Minor: " + str(minorangle)
    angle = [majorangle[0] + minorangle[0],majorangle[1] + minorangle[1]]

    return angle

if __name__ == "__main__":
    print wgs842ecef(0,0)
    print get_rot_matrix(pi,0)
    pos = get_rot_matrix(pi,0)*wgs842ecef(0,0)
    print pos
    print pos[2,0]
    [l, b] = nmea2decimal(2.231,'N',3.23,'E')
    print l
    print b
