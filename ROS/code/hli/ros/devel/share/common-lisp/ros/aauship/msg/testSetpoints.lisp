; Auto-generated. Do not edit!


(cl:in-package aauship-msg)


;//! \htmlinclude testSetpoints.msg.html

(cl:defclass <testSetpoints> (roslisp-msg-protocol:ros-message)
  ((cmd_vel
    :reader cmd_vel
    :initarg :cmd_vel
    :type cl:float
    :initform 0.0)
   (cmd_angvel
    :reader cmd_angvel
    :initarg :cmd_angvel
    :type cl:float
    :initform 0.0)
   (cmd_ang
    :reader cmd_ang
    :initarg :cmd_ang
    :type cl:float
    :initform 0.0)
   (controller_type
    :reader controller_type
    :initarg :controller_type
    :type cl:integer
    :initform 0))
)

(cl:defclass testSetpoints (<testSetpoints>)
  ())

(cl:defmethod cl:initialize-instance :after ((m <testSetpoints>) cl:&rest args)
  (cl:declare (cl:ignorable args))
  (cl:unless (cl:typep m 'testSetpoints)
    (roslisp-msg-protocol:msg-deprecation-warning "using old message class name aauship-msg:<testSetpoints> is deprecated: use aauship-msg:testSetpoints instead.")))

(cl:ensure-generic-function 'cmd_vel-val :lambda-list '(m))
(cl:defmethod cmd_vel-val ((m <testSetpoints>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader aauship-msg:cmd_vel-val is deprecated.  Use aauship-msg:cmd_vel instead.")
  (cmd_vel m))

(cl:ensure-generic-function 'cmd_angvel-val :lambda-list '(m))
(cl:defmethod cmd_angvel-val ((m <testSetpoints>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader aauship-msg:cmd_angvel-val is deprecated.  Use aauship-msg:cmd_angvel instead.")
  (cmd_angvel m))

(cl:ensure-generic-function 'cmd_ang-val :lambda-list '(m))
(cl:defmethod cmd_ang-val ((m <testSetpoints>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader aauship-msg:cmd_ang-val is deprecated.  Use aauship-msg:cmd_ang instead.")
  (cmd_ang m))

(cl:ensure-generic-function 'controller_type-val :lambda-list '(m))
(cl:defmethod controller_type-val ((m <testSetpoints>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader aauship-msg:controller_type-val is deprecated.  Use aauship-msg:controller_type instead.")
  (controller_type m))
(cl:defmethod roslisp-msg-protocol:serialize ((msg <testSetpoints>) ostream)
  "Serializes a message object of type '<testSetpoints>"
  (cl:let ((bits (roslisp-utils:encode-double-float-bits (cl:slot-value msg 'cmd_vel))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 32) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 40) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 48) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 56) bits) ostream))
  (cl:let ((bits (roslisp-utils:encode-double-float-bits (cl:slot-value msg 'cmd_angvel))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 32) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 40) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 48) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 56) bits) ostream))
  (cl:let ((bits (roslisp-utils:encode-double-float-bits (cl:slot-value msg 'cmd_ang))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 32) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 40) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 48) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 56) bits) ostream))
  (cl:let* ((signed (cl:slot-value msg 'controller_type)) (unsigned (cl:if (cl:< signed 0) (cl:+ signed 18446744073709551616) signed)))
    (cl:write-byte (cl:ldb (cl:byte 8 0) unsigned) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) unsigned) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) unsigned) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) unsigned) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 32) unsigned) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 40) unsigned) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 48) unsigned) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 56) unsigned) ostream)
    )
)
(cl:defmethod roslisp-msg-protocol:deserialize ((msg <testSetpoints>) istream)
  "Deserializes a message object of type '<testSetpoints>"
    (cl:let ((bits 0))
      (cl:setf (cl:ldb (cl:byte 8 0) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 32) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 40) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 48) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 56) bits) (cl:read-byte istream))
    (cl:setf (cl:slot-value msg 'cmd_vel) (roslisp-utils:decode-double-float-bits bits)))
    (cl:let ((bits 0))
      (cl:setf (cl:ldb (cl:byte 8 0) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 32) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 40) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 48) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 56) bits) (cl:read-byte istream))
    (cl:setf (cl:slot-value msg 'cmd_angvel) (roslisp-utils:decode-double-float-bits bits)))
    (cl:let ((bits 0))
      (cl:setf (cl:ldb (cl:byte 8 0) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 32) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 40) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 48) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 56) bits) (cl:read-byte istream))
    (cl:setf (cl:slot-value msg 'cmd_ang) (roslisp-utils:decode-double-float-bits bits)))
    (cl:let ((unsigned 0))
      (cl:setf (cl:ldb (cl:byte 8 0) unsigned) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) unsigned) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) unsigned) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) unsigned) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 32) unsigned) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 40) unsigned) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 48) unsigned) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 56) unsigned) (cl:read-byte istream))
      (cl:setf (cl:slot-value msg 'controller_type) (cl:if (cl:< unsigned 9223372036854775808) unsigned (cl:- unsigned 18446744073709551616))))
  msg
)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql '<testSetpoints>)))
  "Returns string type for a message object of type '<testSetpoints>"
  "aauship/testSetpoints")
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'testSetpoints)))
  "Returns string type for a message object of type 'testSetpoints"
  "aauship/testSetpoints")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql '<testSetpoints>)))
  "Returns md5sum for a message object of type '<testSetpoints>"
  "7ae8885587dd6aa4814f0117556b4b24")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql 'testSetpoints)))
  "Returns md5sum for a message object of type 'testSetpoints"
  "7ae8885587dd6aa4814f0117556b4b24")
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql '<testSetpoints>)))
  "Returns full string definition for message of type '<testSetpoints>"
  (cl:format cl:nil "# Thi is the msg format for the control-test-node and rqt_mypkg~%# interface~%float64 cmd_vel~%float64 cmd_angvel~%float64 cmd_ang~%int64 controller_type~%~%~%"))
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql 'testSetpoints)))
  "Returns full string definition for message of type 'testSetpoints"
  (cl:format cl:nil "# Thi is the msg format for the control-test-node and rqt_mypkg~%# interface~%float64 cmd_vel~%float64 cmd_angvel~%float64 cmd_ang~%int64 controller_type~%~%~%"))
(cl:defmethod roslisp-msg-protocol:serialization-length ((msg <testSetpoints>))
  (cl:+ 0
     8
     8
     8
     8
))
(cl:defmethod roslisp-msg-protocol:ros-message-to-list ((msg <testSetpoints>))
  "Converts a ROS message object to a list"
  (cl:list 'testSetpoints
    (cl:cons ':cmd_vel (cmd_vel msg))
    (cl:cons ':cmd_angvel (cmd_angvel msg))
    (cl:cons ':cmd_ang (cmd_ang msg))
    (cl:cons ':controller_type (controller_type msg))
))
