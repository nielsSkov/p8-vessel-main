//=====================================================================================================
// MadgwickAHRS.h
//=====================================================================================================
//
// Implementation of Madgwick's IMU and AHRS algorithms.
// See: http://www.x-io.co.uk/node/8#open_source_ahrs_and_imu_algorithms
//
// Date			Author          Notes
// 29/09/2011	SOH Madgwick    Initial release
// 02/10/2011	SOH Madgwick	Optimised for reduced CPU load
// 07/07/2014   Nick Østergaard Convert to C++ for use with ROS.org
//
//=====================================================================================================
#ifndef MadgwickAHRS_h
#define MadgwickAHRS_h

class MadgwickAHRS{
private:
    volatile float beta;				// algorithm gain
    volatile float q0, q1, q2, q3;	// quaternion of sensor frame relative to auxiliary frame
    float sampleFreq;

    float eulerAngleX;
    float eulerAngleY;
    float eulerAngleZ;

public:
    MadgwickAHRS(float,float);
    void MadgwickAHRSupdate(float gx, float gy, float gz, float ax, float ay, float az, float mx, float my, float mz);
    void MadgwickAHRSupdateIMU(float gx, float gy, float gz, float ax, float ay, float az);
    float invSqrt(float x);
    /*void setTuning(float,float);
    float getTuning(int);
    float getSampleFreq( void );
    void setSampleFreq(float);*/
    float getEulerAngles(int);
    float getQuaternions(int);
    void calculateEulerAngles(void);
    
};

#endif
