; Auto-generated. Do not edit!


(cl:in-package aauship-msg)


;//! \htmlinclude controlTest.msg.html

(cl:defclass <controlTest> (roslisp-msg-protocol:ros-message)
  ((pid
    :reader pid
    :initarg :pid
    :type aauship-msg:PID
    :initform (cl:make-instance 'aauship-msg:PID))
   (setpoints
    :reader setpoints
    :initarg :setpoints
    :type aauship-msg:testSetpoints
    :initform (cl:make-instance 'aauship-msg:testSetpoints)))
)

(cl:defclass controlTest (<controlTest>)
  ())

(cl:defmethod cl:initialize-instance :after ((m <controlTest>) cl:&rest args)
  (cl:declare (cl:ignorable args))
  (cl:unless (cl:typep m 'controlTest)
    (roslisp-msg-protocol:msg-deprecation-warning "using old message class name aauship-msg:<controlTest> is deprecated: use aauship-msg:controlTest instead.")))

(cl:ensure-generic-function 'pid-val :lambda-list '(m))
(cl:defmethod pid-val ((m <controlTest>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader aauship-msg:pid-val is deprecated.  Use aauship-msg:pid instead.")
  (pid m))

(cl:ensure-generic-function 'setpoints-val :lambda-list '(m))
(cl:defmethod setpoints-val ((m <controlTest>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader aauship-msg:setpoints-val is deprecated.  Use aauship-msg:setpoints instead.")
  (setpoints m))
(cl:defmethod roslisp-msg-protocol:serialize ((msg <controlTest>) ostream)
  "Serializes a message object of type '<controlTest>"
  (roslisp-msg-protocol:serialize (cl:slot-value msg 'pid) ostream)
  (roslisp-msg-protocol:serialize (cl:slot-value msg 'setpoints) ostream)
)
(cl:defmethod roslisp-msg-protocol:deserialize ((msg <controlTest>) istream)
  "Deserializes a message object of type '<controlTest>"
  (roslisp-msg-protocol:deserialize (cl:slot-value msg 'pid) istream)
  (roslisp-msg-protocol:deserialize (cl:slot-value msg 'setpoints) istream)
  msg
)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql '<controlTest>)))
  "Returns string type for a message object of type '<controlTest>"
  "aauship/controlTest")
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'controlTest)))
  "Returns string type for a message object of type 'controlTest"
  "aauship/controlTest")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql '<controlTest>)))
  "Returns md5sum for a message object of type '<controlTest>"
  "cc467b6eed7e26ccc32696c510ec064d")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql 'controlTest)))
  "Returns md5sum for a message object of type 'controlTest"
  "cc467b6eed7e26ccc32696c510ec064d")
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql '<controlTest>)))
  "Returns full string definition for message of type '<controlTest>"
  (cl:format cl:nil "# Coherent message format for all the stuff that is of use for the control-test-node.py~%aauship/PID pid~%aauship/testSetpoints setpoints~%~%================================================================================~%MSG: aauship/PID~%# This is a msg format for exchanging PID controller values~%float64 Kp~%float64 Ki~%float64 Kd~%~%================================================================================~%MSG: aauship/testSetpoints~%# Thi is the msg format for the control-test-node and rqt_mypkg~%# interface~%float64 cmd_vel~%float64 cmd_angvel~%float64 cmd_ang~%int64 controller_type~%~%~%"))
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql 'controlTest)))
  "Returns full string definition for message of type 'controlTest"
  (cl:format cl:nil "# Coherent message format for all the stuff that is of use for the control-test-node.py~%aauship/PID pid~%aauship/testSetpoints setpoints~%~%================================================================================~%MSG: aauship/PID~%# This is a msg format for exchanging PID controller values~%float64 Kp~%float64 Ki~%float64 Kd~%~%================================================================================~%MSG: aauship/testSetpoints~%# Thi is the msg format for the control-test-node and rqt_mypkg~%# interface~%float64 cmd_vel~%float64 cmd_angvel~%float64 cmd_ang~%int64 controller_type~%~%~%"))
(cl:defmethod roslisp-msg-protocol:serialization-length ((msg <controlTest>))
  (cl:+ 0
     (roslisp-msg-protocol:serialization-length (cl:slot-value msg 'pid))
     (roslisp-msg-protocol:serialization-length (cl:slot-value msg 'setpoints))
))
(cl:defmethod roslisp-msg-protocol:ros-message-to-list ((msg <controlTest>))
  "Converts a ROS message object to a list"
  (cl:list 'controlTest
    (cl:cons ':pid (pid msg))
    (cl:cons ':setpoints (setpoints msg))
))
