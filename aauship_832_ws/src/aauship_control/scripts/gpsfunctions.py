from math import sqrt, sin, cos, pi, floor, atan2, fmod
import numpy as np

def wgs842ecef(lat,lon,h=None):
    if h == None:
        h = 0.0

    '''
    # old implementation
    a = 6378137.0
    e = 0.0818
    N = a / sqrt(1-e**2*sin(lat))
    
    result = np.zeros((3,1))
    result[0][0] = (N+h)*cos(lat)*cos(lon)
    result[1][0] = (N+h)*cos(lat)*sin(lon)
    result[2][0] = (N*(1-e**2)+h)*sin(lat)
    '''

    # Taken from MMS toolbox
    r_e = 6378137.0 # WGS-84 data
    r_p = 6356752.0
    e = 0.08181979099211
    N = r_e**2/sqrt( (r_e*cos(lat))**2 + (r_p*sin(lat))**2 )
    result = np.zeros((3,1))
    result[0][0] = (N+h)*cos(lat)*cos(lon)
    result[1][0] = (N+h)*cos(lat)*sin(lon)
    result[2][0] = (N*(r_p/r_e)**2 + h)*sin(lat)

    return result

# Convert earth-centered earth-fixed (ECEF) cartesian coordinates to latitude,
# longitude, and altitude.
#
# Based on:
# http://www.mathworks.com/matlabcentral/fileexchange/7941-convert-cartesian--ecef--coordinates-to-lat--lon--alt
# Assuming original author released it as public domain, because the
# BSD license it not specified.
#
# Notes:
# (1) This function assumes the WGS84 model.
# (2) Latitude is customary geodetic (not geocentric).
# (3) Inputs may be scalars, vectors, or matrices of the same size and shape.
#     Outputs will have that same size and shape.
# (4) Tested but no warranty; use at your own risk.
# (5) Originally written in Matlab by Michael Kleder, April 2006
def ecef2wgs82(x,y,z):
    # WGS84 ellipsoid constants
    a = 6378137
    e = 8.1819190842622e-2

    # Calculations
    b   = sqrt(a**2*(1-e**2));
    ep  = sqrt((a**2-b**2)/b**2);
    p   = sqrt(x**2+y**2);
    th  = atan2(a*z,b*p);
    lon = atan2(y,x);
    lat = atan2((z+ep**2.*b*sin(th)**3),(p-e**2*a*cos(th)**3));
    N   = a/sqrt(1-e**2.*sin(lat)**2);
    alt = p/cos(lat)-N; # The altitude does not seem precise comparing
    # with ecef2llh.m from MSS toolbox

    # Return lon in range [0, 2*pi)
    lon = fmod(lon, 2*pi)

    # correct for numerical instability in altitude near exact poles:
    # (after this correction, error is about 2 millimeters, which is
    # about the same as the numerical precision of the overall function)
    k = abs(x)<1 and abs(y)<1
    #alt(k) = abs(z(k))-b
    if k == True:
        print('ecef2wgs82 input is not stable at the poles')

    return {'lat':lat,'lon':lon,'alt':alt}

def get_rot_matrix(centerlat,centerlon):
    Rot = np.matrix([[-sin(centerlat)*cos(centerlon), -sin(centerlat)*sin(centerlon), cos(centerlat)],
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

# Angle in rad to the interval (-pi pi]
def rad2pipi(rad):
    r = fmod((rad+np.sign(rad)*pi) , 2*pi) # remainder
    s = np.sign(np.sign(rad) + 2*(np.sign(abs( fmod((rad+pi), (2*pi)) /(2*pi)))-1));
    pipi = r - s*pi;
    return pipi

# Rotation matrix from NED to BODY frame
# Rotation order is zyx
def RNED2BODY(phi, theta, psi):
    cphi = cos(phi)
    sphi = sin(phi)
    cth  = cos(theta)
    sth  = sin(theta)
    cpsi = cos(psi)
    spsi = sin(psi)
     
    R = np.matrix([ [cpsi*cth, -spsi*cphi+cpsi*sth*sphi,  spsi*sphi+cpsi*cphi*sth],
                    [spsi*cth,  cpsi*cphi+sphi*sth*spsi, -cpsi*sphi+sth*spsi*cphi],
                    [    -sth,                 cth*sphi,                 cth*cphi] ])
    return R

# Rotation matrix from NED to ECEF frame
# Using the eq. (2.84) from Fossen
def RNED2ECEF(lon, lat):
    clon = cos(lon)
    slon = sin(lon)
    clat = cos(lat)
    slat = sin(lat)

    R = np.matrix([ [-clon*slat,  -slon,   -clon*clat],
                    [-slon*slat,   clon,   -slon*clat],
                    [      clat,      0,        -slat] ])

    return R

if __name__ == "__main__":
    lat = 57*pi/180
    lon = 10*pi/180
    ecef = wgs842ecef(lat, lon, 0.0)
    wgs82 = ecef2wgs82(ecef[0], ecef[1], ecef[2])
    print(lat, lon, 0)
    print(ecef)
    print(wgs82)
    print(lat-wgs82['lat'])
    print(lon-wgs82['lon'])
    print(0-wgs82['alt'])

    '''
    print wgs842ecef(0,0)
    print get_rot_matrix(pi,0)
    pos = get_rot_matrix(pi,0)*wgs842ecef(0,0)
    print pos
    print pos[2,0]
    [l, b] = nmea2decimal(2.231,'N',3.23,'E')
    print l
    print b
    '''
