#ifndef KalmanFilter_h
#define KalmanFilter_h

#include "ukf.h"
#include <aauship/ukf.h>
#include "ekf.h"
#include "ukf_state_ndim.h"
using namespace ekf;
class KalmanFilter{
private:
public:
  int foo;
  KalmanFilter(void);
  void KalmanFilterUpdate(void);
  void f(gsl_vector * params, gsl_vector * xk_1, gsl_vector * xk);
  void df(gsl_vector * params, gsl_vector * xk_1, gsl_matrix * Fxk);
  void h(gsl_vector * params, gsl_vector * xk , gsl_vector * yk);
  void dh(gsl_vector * params, gsl_vector * xk , gsl_matrix * Hyk);
};

#endif
