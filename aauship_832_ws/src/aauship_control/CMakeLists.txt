cmake_minimum_required(VERSION 2.8.3)
project(aauship_control)

## Find catkin macros and libraries
## if COMPONENTS list like find_package(catkin REQUIRED COMPONENTS xyz)
## is used, also find other catkin packages
find_package(catkin REQUIRED COMPONENTS
  roscpp
  rospy
  std_msgs
  sensor_msgs
  genmsg
  message_generation
  tf
)

## System dependencies are found with CMake's conventions
# find_package(Boost REQUIRED COMPONENTS system)
find_package( PkgConfig REQUIRED)
pkg_check_modules( gsl REQUIRED gsl )

## Uncomment this if the package has a setup.py. This macro ensures
## modules and global scripts declared therein get installed
## See http://ros.org/doc/api/catkin/html/user_guide/setup_dot_py.html
# catkin_python_setup()

################################################
## Declare ROS messages, services and actions ##
################################################

## To declare and build messages, services or actions from within this
## package, follow these steps:
## * Let MSG_DEP_SET be the set of packages whose message types you use in
##   your messages/services/actions (e.g. std_msgs, actionlib_msgs, ...).
## * In the file package.xml:
##   * add a build_depend and a run_depend tag for each package in MSG_DEP_SET
##   * If MSG_DEP_SET isn't empty the following dependencies might have been
##     pulled in transitively but can be declared for certainty nonetheless:
##     * add a build_depend tag for "message_generation"
##     * add a run_depend tag for "message_runtime"
## * In this file (CMakeLists.txt):
##   * add "message_generation" and every package in MSG_DEP_SET to
##     find_package(catkin REQUIRED COMPONENTS ...)
##   * add "message_runtime" and every package in MSG_DEP_SET to
##     catkin_package(CATKIN_DEPENDS ...)
##   * uncomment the add_*_files sections below as needed
##     and list every .msg/.srv/.action file to be processed
##   * uncomment the generate_messages entry below
##   * add every package in MSG_DEP_SET to generate_messages(DEPENDENCIES ...)

## Generate messages in the 'msg' folder
# add_message_files(
#   FILES
#   Message1.msg
#   Message2.msg
# )
add_message_files(
  FILES
  Faps.msg
  Ref.msg
  ADIS16405.msg
  LLIinput.msg
#  testSetpoints.msg
#  PID.msg
  Attitude.msg
  GPS.msg
#  controlTest.msg
  BatteryMonitor.msg
  KFStates.msg
  AttitudeStates.msg
  PositionStates.msg
)

## Generate services in the 'srv' folder
# add_service_files(
#   FILES
#   Service1.srv
#   Service2.srv
# )

## Generate actions in the 'action' folder
# add_action_files(
#   FILES
#   Action1.action
#   Action2.action
# )

## Generate added messages and services with any dependencies listed here
# generate_messages(
#   DEPENDENCIES
#   std_msgs  # Or other packages containing msgs
# )
generate_messages(
  DEPENDENCIES
  std_msgs
  sensor_msgs
)

###################################
## catkin specific configuration ##
###################################
## The catkin_package macro generates cmake config files for your package
## Declare things to be passed to dependent projects
## INCLUDE_DIRS: uncomment this if you package contains header files
## LIBRARIES: libraries you create in this project that dependent projects also need
## CATKIN_DEPENDS: catkin_packages dependent projects also need
## DEPENDS: system dependencies of this project that dependent projects also need
catkin_package(
  INCLUDE_DIRS include
  LIBRARIES aauship_control
  CATKIN_DEPENDS roscpp rospy std_msgs sensor_msgs message_runtime
  DEPENDS system_lib
)

###########
## Build ##
###########

## Specify additional locations of header files
## Your package locations should be listed before other locations
# include_directories(include)
include_directories(
  include ${catkin_INCLUDE_DIRS}
)

## Declare a cpp library
# add_library(aauship_control
#   src/${PROJECT_NAME}/aauship_control.cpp
# )
add_library(aauship_control
  src/MahonyAHRS.cpp
#  src/lqr-controller-node.cpp
#  src/MadgwickAHRS.cpp
# scripts/kalmanfilter-node.py
  src/KalmanFilter.cpp
)

## Declare a cpp executable
# add_executable(aauship_control_node src/aauship_control_node.cpp)

## Add cmake target dependencies of the executable/library
## as an example, message headers may need to be generated before nodes
# add_dependencies(aauship_control_node aauship_control_generate_messages_cpp)

## Specify libraries to link a library or executable target against
# target_link_libraries(aauship_control_node
#   ${catkin_LIBRARIES}
# )
#catkin_install_python(PROGRAMS scripts/kalmanfilter-node.py
#DESTINATION ${CATKIN_PACKAGE_BIN_DESTINATION})
add_executable(joy-teleop-node src/joy-teleop-node.cpp)
add_dependencies(joy-teleop-node ${catkin_EXPORTED_TARGETS})
target_link_libraries(joy-teleop-node ${catkin_LIBRARIES})

add_executable(ahrs-mahony-node src/ahrs-mahony-node.cpp)
add_dependencies(ahrs-mahony-node ${catkin_EXPORTED_TARGETS})
target_link_libraries(ahrs-mahony-node aauship_control ${gsl_LIBRARIES}  ${catkin_LIBRARIES})

add_executable(lqr_node src/lqr-controller-node.cpp)
add_dependencies(lqr_node ${catkin_EXPORTED_TARGETS})
target_link_libraries(lqr_node ${gsl_LIBRARIES} ${catkin_LIBRARIES})

add_executable(path_follower_node src/path-follower-node.cpp)
add_dependencies(path_follower_node ${catkin_EXPORTED_TARGETS})
target_link_libraries(path_follower_node ${gsl_LIBRARIES} ${catkin_LIBRARIES})

# add_executable(gps_data_node src/gps_get_data.cpp)
# add_dependencies(gps_data_node ${catkin_EXPORTED_TARGETS})
# target_link_libraries(gps_data_node ${gsl_LIBRARIES} ${catkin_LIBRARIES})

add_executable(KF_attitude_node src/KF-att-node.cpp)
add_dependencies(KF_attitude_node ${catkin_EXPORTED_TARGETS})
target_link_libraries(KF_attitude_node aauship_control ${gsl_LIBRARIES}  ${catkin_LIBRARIES})

add_executable(KF_position_node src/KF-pos-node.cpp)
add_dependencies(KF_position_node ${catkin_EXPORTED_TARGETS})
target_link_libraries(KF_position_node aauship_control ${gsl_LIBRARIES}  ${catkin_LIBRARIES})

#############
## Install ##
#############

# all install targets should use catkin DESTINATION variables
# See http://ros.org/doc/api/catkin/html/adv_user_guide/variables.html

## Mark executable scripts (Python etc.) for installation
## in contrast to setup.py, you can choose the destination
# install(PROGRAMS
  # scripts/lli_input.py
  # scripts/joy-teleop-node.py
  # DESTINATION ${CATKIN_PACKAGE_BIN_DESTINATION}
# )

## Mark executables and/or libraries for installation
# install(TARGETS aauship_control aauship_control_node
#   ARCHIVE DESTINATION ${CATKIN_PACKAGE_LIB_DESTINATION}
#   LIBRARY DESTINATION ${CATKIN_PACKAGE_LIB_DESTINATION}
#   RUNTIME DESTINATION ${CATKIN_PACKAGE_BIN_DESTINATION}
# )

## Mark cpp header files for installation
# install(DIRECTORY include/${PROJECT_NAME}/
#   DESTINATION ${CATKIN_PACKAGE_INCLUDE_DESTINATION}
#   FILES_MATCHING PATTERN "*.h"
#   PATTERN ".svn" EXCLUDE
# )

## Mark other files for installation (e.g. launch and bag files, etc.)
# install(FILES
#   # myfile1
#   # myfile2
#   DESTINATION ${CATKIN_PACKAGE_SHARE_DESTINATION}
# )

#############
## Testing ##
#############

## Add gtest based cpp test target and link libraries
# catkin_add_gtest(${PROJECT_NAME}-test test/test_aauship_control.cpp)
# if(TARGET ${PROJECT_NAME}-test)
#   target_link_libraries(${PROJECT_NAME}-test ${PROJECT_NAME})
# endif()

## Add folders to be run by python nosetests
# catkin_add_nosetests(test)
