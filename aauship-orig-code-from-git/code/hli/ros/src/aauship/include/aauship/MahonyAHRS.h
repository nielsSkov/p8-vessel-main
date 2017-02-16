//=====================================================================================================
// MahonyAHRS.h
//=====================================================================================================
//
// Madgwick's implementation of Mayhony's AHRS algorithm.
// See: http://www.x-io.co.uk/node/8#open_source_ahrs_and_imu_algorithms
//
// Date			Author			Notes
// 29/09/2011	SOH Madgwick    Initial release
// 02/10/2011	SOH Madgwick	Optimised for reduced CPU load
// 29/06/2014   Nick Østergaard Convert to C++ for use with ROS.org
//
//=====================================================================================================
#ifndef MahonyAHRS_h
#define MahonyAHRS_h

class MahonyAHRS{
private:
    volatile float twoKp;											// 2 * proportional gain (Kp)
    volatile float twoKi;											// 2 * integral gain (Ki)
    float sampleFreq;			// sample frequency in Hz
//    float KpA;                    // proportional gain (Kp)
//    float KiA;                    // integral gain (Ki)
//    float KpM;                    // proportional gain (Kp)
//    float KiM;                    // integral gain (Ki)
    float q0, q1, q2, q3;            // quaternion of sensor frame relative to auxiliary frame
 
    float integralFBx;                // integral error terms scaled by Ki
    float integralFBy;                // integral error terms scaled by Ki
    float integralFBz;                // integral error terms scaled by Ki
 
    float correctedRateVectorX;     // Corrected Gyroscope Data
    float correctedRateVectorY;
    float correctedRateVectorZ;
 
    float eulerAngleX;
    float eulerAngleY;
    float eulerAngleZ;
 
    float ex;
    float ey;
    float ez;
    
    float magX;
    float magY;
    float magZ;
    
public:
    MahonyAHRS(float,float,float);
    void MahonyAHRSupdate(float gx, float gy, float gz, float ax, float ay, float az, float mx, float my, float mz);
    void MahonyAHRSupdateIMU(float gx, float gy, float gz, float ax, float ay, float az);
    float invSqrt(float x);
    void setTuning(float,float);
    float getTuning(int);
    float getSampleFreq( void );
    void setSampleFreq(float);
    float getEulerAngles(int);
    float getQuaternions(int);
    void calculateEulerAngles(void);
    
//    float getError(int);
//    void reset(void);
//    float getCorrectedRate(int);
};

#endif
