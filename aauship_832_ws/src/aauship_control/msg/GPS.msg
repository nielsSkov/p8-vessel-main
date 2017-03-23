# GPS information
# This can contain relevant information from $GPGGA and $GPRMC messages
Header header
int32   time
float32 latitude
float32 longitude
int8    fix      # Fix quality 1 = GPS fix (single precission)
int8    sats     # Number of satellites
float32 HDOP     # Horizontal dillution of precission
float32 SOG      # Speed over ground
float32 track_angle # Track angle
int32   date     # Date in NMEA format
float32 altitude # Altitude over mean sea level
float32 height   # Height of geoid (mean sea level) above WGS84 ellipsoid
