# generated from genmsg/cmake/pkg-genmsg.cmake.em

message(STATUS "aauship: 10 messages, 0 services")

set(MSG_I_FLAGS "-Iaauship:/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg;-Istd_msgs:/opt/ros/indigo/share/std_msgs/cmake/../msg;-Isensor_msgs:/opt/ros/indigo/share/sensor_msgs/cmake/../msg;-Igeometry_msgs:/opt/ros/indigo/share/geometry_msgs/cmake/../msg")

# Find all generators
find_package(gencpp REQUIRED)
find_package(genlisp REQUIRED)
find_package(genpy REQUIRED)

add_custom_target(aauship_generate_messages ALL)

# verify that message/service dependencies have not changed since configure



get_filename_component(_filename "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/GPS.msg" NAME_WE)
add_custom_target(_aauship_generate_messages_check_deps_${_filename}
  COMMAND ${CATKIN_ENV} ${PYTHON_EXECUTABLE} ${GENMSG_CHECK_DEPS_SCRIPT} "aauship" "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/GPS.msg" "std_msgs/Header"
)

get_filename_component(_filename "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/ADIS16405.msg" NAME_WE)
add_custom_target(_aauship_generate_messages_check_deps_${_filename}
  COMMAND ${CATKIN_ENV} ${PYTHON_EXECUTABLE} ${GENMSG_CHECK_DEPS_SCRIPT} "aauship" "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/ADIS16405.msg" ""
)

get_filename_component(_filename "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/KFStates.msg" NAME_WE)
add_custom_target(_aauship_generate_messages_check_deps_${_filename}
  COMMAND ${CATKIN_ENV} ${PYTHON_EXECUTABLE} ${GENMSG_CHECK_DEPS_SCRIPT} "aauship" "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/KFStates.msg" "std_msgs/Header"
)

get_filename_component(_filename "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/testSetpoints.msg" NAME_WE)
add_custom_target(_aauship_generate_messages_check_deps_${_filename}
  COMMAND ${CATKIN_ENV} ${PYTHON_EXECUTABLE} ${GENMSG_CHECK_DEPS_SCRIPT} "aauship" "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/testSetpoints.msg" ""
)

get_filename_component(_filename "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/Attitude.msg" NAME_WE)
add_custom_target(_aauship_generate_messages_check_deps_${_filename}
  COMMAND ${CATKIN_ENV} ${PYTHON_EXECUTABLE} ${GENMSG_CHECK_DEPS_SCRIPT} "aauship" "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/Attitude.msg" ""
)

get_filename_component(_filename "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/BatteryMonitor.msg" NAME_WE)
add_custom_target(_aauship_generate_messages_check_deps_${_filename}
  COMMAND ${CATKIN_ENV} ${PYTHON_EXECUTABLE} ${GENMSG_CHECK_DEPS_SCRIPT} "aauship" "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/BatteryMonitor.msg" ""
)

get_filename_component(_filename "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/Faps.msg" NAME_WE)
add_custom_target(_aauship_generate_messages_check_deps_${_filename}
  COMMAND ${CATKIN_ENV} ${PYTHON_EXECUTABLE} ${GENMSG_CHECK_DEPS_SCRIPT} "aauship" "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/Faps.msg" ""
)

get_filename_component(_filename "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/LLIinput.msg" NAME_WE)
add_custom_target(_aauship_generate_messages_check_deps_${_filename}
  COMMAND ${CATKIN_ENV} ${PYTHON_EXECUTABLE} ${GENMSG_CHECK_DEPS_SCRIPT} "aauship" "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/LLIinput.msg" ""
)

get_filename_component(_filename "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/controlTest.msg" NAME_WE)
add_custom_target(_aauship_generate_messages_check_deps_${_filename}
  COMMAND ${CATKIN_ENV} ${PYTHON_EXECUTABLE} ${GENMSG_CHECK_DEPS_SCRIPT} "aauship" "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/controlTest.msg" "aauship/testSetpoints:aauship/PID"
)

get_filename_component(_filename "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/PID.msg" NAME_WE)
add_custom_target(_aauship_generate_messages_check_deps_${_filename}
  COMMAND ${CATKIN_ENV} ${PYTHON_EXECUTABLE} ${GENMSG_CHECK_DEPS_SCRIPT} "aauship" "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/PID.msg" ""
)

#
#  langs = gencpp;genlisp;genpy
#

### Section generating for lang: gencpp
### Generating Messages
_generate_msg_cpp(aauship
  "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/GPS.msg"
  "${MSG_I_FLAGS}"
  "/opt/ros/indigo/share/std_msgs/cmake/../msg/Header.msg"
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/aauship
)
_generate_msg_cpp(aauship
  "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/ADIS16405.msg"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/aauship
)
_generate_msg_cpp(aauship
  "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/BatteryMonitor.msg"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/aauship
)
_generate_msg_cpp(aauship
  "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/testSetpoints.msg"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/aauship
)
_generate_msg_cpp(aauship
  "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/Attitude.msg"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/aauship
)
_generate_msg_cpp(aauship
  "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/KFStates.msg"
  "${MSG_I_FLAGS}"
  "/opt/ros/indigo/share/std_msgs/cmake/../msg/Header.msg"
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/aauship
)
_generate_msg_cpp(aauship
  "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/Faps.msg"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/aauship
)
_generate_msg_cpp(aauship
  "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/LLIinput.msg"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/aauship
)
_generate_msg_cpp(aauship
  "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/controlTest.msg"
  "${MSG_I_FLAGS}"
  "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/testSetpoints.msg;/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/PID.msg"
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/aauship
)
_generate_msg_cpp(aauship
  "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/PID.msg"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/aauship
)

### Generating Services

### Generating Module File
_generate_module_cpp(aauship
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/aauship
  "${ALL_GEN_OUTPUT_FILES_cpp}"
)

add_custom_target(aauship_generate_messages_cpp
  DEPENDS ${ALL_GEN_OUTPUT_FILES_cpp}
)
add_dependencies(aauship_generate_messages aauship_generate_messages_cpp)

# add dependencies to all check dependencies targets
get_filename_component(_filename "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/GPS.msg" NAME_WE)
add_dependencies(aauship_generate_messages_cpp _aauship_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/ADIS16405.msg" NAME_WE)
add_dependencies(aauship_generate_messages_cpp _aauship_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/KFStates.msg" NAME_WE)
add_dependencies(aauship_generate_messages_cpp _aauship_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/testSetpoints.msg" NAME_WE)
add_dependencies(aauship_generate_messages_cpp _aauship_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/Attitude.msg" NAME_WE)
add_dependencies(aauship_generate_messages_cpp _aauship_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/BatteryMonitor.msg" NAME_WE)
add_dependencies(aauship_generate_messages_cpp _aauship_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/Faps.msg" NAME_WE)
add_dependencies(aauship_generate_messages_cpp _aauship_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/LLIinput.msg" NAME_WE)
add_dependencies(aauship_generate_messages_cpp _aauship_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/controlTest.msg" NAME_WE)
add_dependencies(aauship_generate_messages_cpp _aauship_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/PID.msg" NAME_WE)
add_dependencies(aauship_generate_messages_cpp _aauship_generate_messages_check_deps_${_filename})

# target for backward compatibility
add_custom_target(aauship_gencpp)
add_dependencies(aauship_gencpp aauship_generate_messages_cpp)

# register target for catkin_package(EXPORTED_TARGETS)
list(APPEND ${PROJECT_NAME}_EXPORTED_TARGETS aauship_generate_messages_cpp)

### Section generating for lang: genlisp
### Generating Messages
_generate_msg_lisp(aauship
  "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/GPS.msg"
  "${MSG_I_FLAGS}"
  "/opt/ros/indigo/share/std_msgs/cmake/../msg/Header.msg"
  ${CATKIN_DEVEL_PREFIX}/${genlisp_INSTALL_DIR}/aauship
)
_generate_msg_lisp(aauship
  "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/ADIS16405.msg"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${genlisp_INSTALL_DIR}/aauship
)
_generate_msg_lisp(aauship
  "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/BatteryMonitor.msg"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${genlisp_INSTALL_DIR}/aauship
)
_generate_msg_lisp(aauship
  "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/testSetpoints.msg"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${genlisp_INSTALL_DIR}/aauship
)
_generate_msg_lisp(aauship
  "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/Attitude.msg"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${genlisp_INSTALL_DIR}/aauship
)
_generate_msg_lisp(aauship
  "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/KFStates.msg"
  "${MSG_I_FLAGS}"
  "/opt/ros/indigo/share/std_msgs/cmake/../msg/Header.msg"
  ${CATKIN_DEVEL_PREFIX}/${genlisp_INSTALL_DIR}/aauship
)
_generate_msg_lisp(aauship
  "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/Faps.msg"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${genlisp_INSTALL_DIR}/aauship
)
_generate_msg_lisp(aauship
  "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/LLIinput.msg"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${genlisp_INSTALL_DIR}/aauship
)
_generate_msg_lisp(aauship
  "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/controlTest.msg"
  "${MSG_I_FLAGS}"
  "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/testSetpoints.msg;/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/PID.msg"
  ${CATKIN_DEVEL_PREFIX}/${genlisp_INSTALL_DIR}/aauship
)
_generate_msg_lisp(aauship
  "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/PID.msg"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${genlisp_INSTALL_DIR}/aauship
)

### Generating Services

### Generating Module File
_generate_module_lisp(aauship
  ${CATKIN_DEVEL_PREFIX}/${genlisp_INSTALL_DIR}/aauship
  "${ALL_GEN_OUTPUT_FILES_lisp}"
)

add_custom_target(aauship_generate_messages_lisp
  DEPENDS ${ALL_GEN_OUTPUT_FILES_lisp}
)
add_dependencies(aauship_generate_messages aauship_generate_messages_lisp)

# add dependencies to all check dependencies targets
get_filename_component(_filename "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/GPS.msg" NAME_WE)
add_dependencies(aauship_generate_messages_lisp _aauship_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/ADIS16405.msg" NAME_WE)
add_dependencies(aauship_generate_messages_lisp _aauship_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/KFStates.msg" NAME_WE)
add_dependencies(aauship_generate_messages_lisp _aauship_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/testSetpoints.msg" NAME_WE)
add_dependencies(aauship_generate_messages_lisp _aauship_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/Attitude.msg" NAME_WE)
add_dependencies(aauship_generate_messages_lisp _aauship_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/BatteryMonitor.msg" NAME_WE)
add_dependencies(aauship_generate_messages_lisp _aauship_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/Faps.msg" NAME_WE)
add_dependencies(aauship_generate_messages_lisp _aauship_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/LLIinput.msg" NAME_WE)
add_dependencies(aauship_generate_messages_lisp _aauship_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/controlTest.msg" NAME_WE)
add_dependencies(aauship_generate_messages_lisp _aauship_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/PID.msg" NAME_WE)
add_dependencies(aauship_generate_messages_lisp _aauship_generate_messages_check_deps_${_filename})

# target for backward compatibility
add_custom_target(aauship_genlisp)
add_dependencies(aauship_genlisp aauship_generate_messages_lisp)

# register target for catkin_package(EXPORTED_TARGETS)
list(APPEND ${PROJECT_NAME}_EXPORTED_TARGETS aauship_generate_messages_lisp)

### Section generating for lang: genpy
### Generating Messages
_generate_msg_py(aauship
  "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/GPS.msg"
  "${MSG_I_FLAGS}"
  "/opt/ros/indigo/share/std_msgs/cmake/../msg/Header.msg"
  ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/aauship
)
_generate_msg_py(aauship
  "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/ADIS16405.msg"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/aauship
)
_generate_msg_py(aauship
  "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/BatteryMonitor.msg"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/aauship
)
_generate_msg_py(aauship
  "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/testSetpoints.msg"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/aauship
)
_generate_msg_py(aauship
  "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/Attitude.msg"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/aauship
)
_generate_msg_py(aauship
  "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/KFStates.msg"
  "${MSG_I_FLAGS}"
  "/opt/ros/indigo/share/std_msgs/cmake/../msg/Header.msg"
  ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/aauship
)
_generate_msg_py(aauship
  "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/Faps.msg"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/aauship
)
_generate_msg_py(aauship
  "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/LLIinput.msg"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/aauship
)
_generate_msg_py(aauship
  "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/controlTest.msg"
  "${MSG_I_FLAGS}"
  "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/testSetpoints.msg;/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/PID.msg"
  ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/aauship
)
_generate_msg_py(aauship
  "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/PID.msg"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/aauship
)

### Generating Services

### Generating Module File
_generate_module_py(aauship
  ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/aauship
  "${ALL_GEN_OUTPUT_FILES_py}"
)

add_custom_target(aauship_generate_messages_py
  DEPENDS ${ALL_GEN_OUTPUT_FILES_py}
)
add_dependencies(aauship_generate_messages aauship_generate_messages_py)

# add dependencies to all check dependencies targets
get_filename_component(_filename "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/GPS.msg" NAME_WE)
add_dependencies(aauship_generate_messages_py _aauship_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/ADIS16405.msg" NAME_WE)
add_dependencies(aauship_generate_messages_py _aauship_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/KFStates.msg" NAME_WE)
add_dependencies(aauship_generate_messages_py _aauship_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/testSetpoints.msg" NAME_WE)
add_dependencies(aauship_generate_messages_py _aauship_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/Attitude.msg" NAME_WE)
add_dependencies(aauship_generate_messages_py _aauship_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/BatteryMonitor.msg" NAME_WE)
add_dependencies(aauship_generate_messages_py _aauship_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/Faps.msg" NAME_WE)
add_dependencies(aauship_generate_messages_py _aauship_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/LLIinput.msg" NAME_WE)
add_dependencies(aauship_generate_messages_py _aauship_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/controlTest.msg" NAME_WE)
add_dependencies(aauship_generate_messages_py _aauship_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/aauship/aauship-formation/code/hli/ros/src/aauship/msg/PID.msg" NAME_WE)
add_dependencies(aauship_generate_messages_py _aauship_generate_messages_check_deps_${_filename})

# target for backward compatibility
add_custom_target(aauship_genpy)
add_dependencies(aauship_genpy aauship_generate_messages_py)

# register target for catkin_package(EXPORTED_TARGETS)
list(APPEND ${PROJECT_NAME}_EXPORTED_TARGETS aauship_generate_messages_py)



if(gencpp_INSTALL_DIR AND EXISTS ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/aauship)
  # install generated code
  install(
    DIRECTORY ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/aauship
    DESTINATION ${gencpp_INSTALL_DIR}
  )
endif()
add_dependencies(aauship_generate_messages_cpp std_msgs_generate_messages_cpp)
add_dependencies(aauship_generate_messages_cpp sensor_msgs_generate_messages_cpp)

if(genlisp_INSTALL_DIR AND EXISTS ${CATKIN_DEVEL_PREFIX}/${genlisp_INSTALL_DIR}/aauship)
  # install generated code
  install(
    DIRECTORY ${CATKIN_DEVEL_PREFIX}/${genlisp_INSTALL_DIR}/aauship
    DESTINATION ${genlisp_INSTALL_DIR}
  )
endif()
add_dependencies(aauship_generate_messages_lisp std_msgs_generate_messages_lisp)
add_dependencies(aauship_generate_messages_lisp sensor_msgs_generate_messages_lisp)

if(genpy_INSTALL_DIR AND EXISTS ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/aauship)
  install(CODE "execute_process(COMMAND \"/usr/bin/python\" -m compileall \"${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/aauship\")")
  # install generated code
  install(
    DIRECTORY ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/aauship
    DESTINATION ${genpy_INSTALL_DIR}
  )
endif()
add_dependencies(aauship_generate_messages_py std_msgs_generate_messages_py)
add_dependencies(aauship_generate_messages_py sensor_msgs_generate_messages_py)
