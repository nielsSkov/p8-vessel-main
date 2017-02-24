; Auto-generated. Do not edit!


(cl:in-package aauship-msg)


;//! \htmlinclude BatteryMonitor.msg.html

(cl:defclass <BatteryMonitor> (roslisp-msg-protocol:ros-message)
  ((bank1
    :reader bank1
    :initarg :bank1
    :type (cl:vector cl:float)
   :initform (cl:make-array 4 :element-type 'cl:float :initial-element 0.0))
   (bank2
    :reader bank2
    :initarg :bank2
    :type (cl:vector cl:float)
   :initform (cl:make-array 4 :element-type 'cl:float :initial-element 0.0)))
)

(cl:defclass BatteryMonitor (<BatteryMonitor>)
  ())

(cl:defmethod cl:initialize-instance :after ((m <BatteryMonitor>) cl:&rest args)
  (cl:declare (cl:ignorable args))
  (cl:unless (cl:typep m 'BatteryMonitor)
    (roslisp-msg-protocol:msg-deprecation-warning "using old message class name aauship-msg:<BatteryMonitor> is deprecated: use aauship-msg:BatteryMonitor instead.")))

(cl:ensure-generic-function 'bank1-val :lambda-list '(m))
(cl:defmethod bank1-val ((m <BatteryMonitor>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader aauship-msg:bank1-val is deprecated.  Use aauship-msg:bank1 instead.")
  (bank1 m))

(cl:ensure-generic-function 'bank2-val :lambda-list '(m))
(cl:defmethod bank2-val ((m <BatteryMonitor>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader aauship-msg:bank2-val is deprecated.  Use aauship-msg:bank2 instead.")
  (bank2 m))
(cl:defmethod roslisp-msg-protocol:serialize ((msg <BatteryMonitor>) ostream)
  "Serializes a message object of type '<BatteryMonitor>"
  (cl:map cl:nil #'(cl:lambda (ele) (cl:let ((bits (roslisp-utils:encode-single-float-bits ele)))
    (cl:write-byte (cl:ldb (cl:byte 8 0) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) bits) ostream)))
   (cl:slot-value msg 'bank1))
  (cl:map cl:nil #'(cl:lambda (ele) (cl:let ((bits (roslisp-utils:encode-single-float-bits ele)))
    (cl:write-byte (cl:ldb (cl:byte 8 0) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) bits) ostream)))
   (cl:slot-value msg 'bank2))
)
(cl:defmethod roslisp-msg-protocol:deserialize ((msg <BatteryMonitor>) istream)
  "Deserializes a message object of type '<BatteryMonitor>"
  (cl:setf (cl:slot-value msg 'bank1) (cl:make-array 4))
  (cl:let ((vals (cl:slot-value msg 'bank1)))
    (cl:dotimes (i 4)
    (cl:let ((bits 0))
      (cl:setf (cl:ldb (cl:byte 8 0) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) bits) (cl:read-byte istream))
    (cl:setf (cl:aref vals i) (roslisp-utils:decode-single-float-bits bits)))))
  (cl:setf (cl:slot-value msg 'bank2) (cl:make-array 4))
  (cl:let ((vals (cl:slot-value msg 'bank2)))
    (cl:dotimes (i 4)
    (cl:let ((bits 0))
      (cl:setf (cl:ldb (cl:byte 8 0) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) bits) (cl:read-byte istream))
    (cl:setf (cl:aref vals i) (roslisp-utils:decode-single-float-bits bits)))))
  msg
)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql '<BatteryMonitor>)))
  "Returns string type for a message object of type '<BatteryMonitor>"
  "aauship/BatteryMonitor")
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'BatteryMonitor)))
  "Returns string type for a message object of type 'BatteryMonitor"
  "aauship/BatteryMonitor")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql '<BatteryMonitor>)))
  "Returns md5sum for a message object of type '<BatteryMonitor>"
  "2a4c3b0a55a6c04019bd839017fb8d1f")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql 'BatteryMonitor)))
  "Returns md5sum for a message object of type 'BatteryMonitor"
  "2a4c3b0a55a6c04019bd839017fb8d1f")
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql '<BatteryMonitor>)))
  "Returns full string definition for message of type '<BatteryMonitor>"
  (cl:format cl:nil "# This is the message format for the battery monitor for the AAUSHIP~%float32[4] bank1~%float32[4] bank2~%~%~%"))
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql 'BatteryMonitor)))
  "Returns full string definition for message of type 'BatteryMonitor"
  (cl:format cl:nil "# This is the message format for the battery monitor for the AAUSHIP~%float32[4] bank1~%float32[4] bank2~%~%~%"))
(cl:defmethod roslisp-msg-protocol:serialization-length ((msg <BatteryMonitor>))
  (cl:+ 0
     0 (cl:reduce #'cl:+ (cl:slot-value msg 'bank1) :key #'(cl:lambda (ele) (cl:declare (cl:ignorable ele)) (cl:+ 4)))
     0 (cl:reduce #'cl:+ (cl:slot-value msg 'bank2) :key #'(cl:lambda (ele) (cl:declare (cl:ignorable ele)) (cl:+ 4)))
))
(cl:defmethod roslisp-msg-protocol:ros-message-to-list ((msg <BatteryMonitor>))
  "Converts a ROS message object to a list"
  (cl:list 'BatteryMonitor
    (cl:cons ':bank1 (bank1 msg))
    (cl:cons ':bank2 (bank2 msg))
))
