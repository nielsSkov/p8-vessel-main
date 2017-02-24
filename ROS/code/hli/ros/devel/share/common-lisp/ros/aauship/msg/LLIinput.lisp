; Auto-generated. Do not edit!


(cl:in-package aauship-msg)


;//! \htmlinclude LLIinput.msg.html

(cl:defclass <LLIinput> (roslisp-msg-protocol:ros-message)
  ((DevID
    :reader DevID
    :initarg :DevID
    :type cl:fixnum
    :initform 0)
   (MsgID
    :reader MsgID
    :initarg :MsgID
    :type cl:fixnum
    :initform 0)
   (Data
    :reader Data
    :initarg :Data
    :type cl:fixnum
    :initform 0)
   (Time
    :reader Time
    :initarg :Time
    :type cl:float
    :initform 0.0))
)

(cl:defclass LLIinput (<LLIinput>)
  ())

(cl:defmethod cl:initialize-instance :after ((m <LLIinput>) cl:&rest args)
  (cl:declare (cl:ignorable args))
  (cl:unless (cl:typep m 'LLIinput)
    (roslisp-msg-protocol:msg-deprecation-warning "using old message class name aauship-msg:<LLIinput> is deprecated: use aauship-msg:LLIinput instead.")))

(cl:ensure-generic-function 'DevID-val :lambda-list '(m))
(cl:defmethod DevID-val ((m <LLIinput>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader aauship-msg:DevID-val is deprecated.  Use aauship-msg:DevID instead.")
  (DevID m))

(cl:ensure-generic-function 'MsgID-val :lambda-list '(m))
(cl:defmethod MsgID-val ((m <LLIinput>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader aauship-msg:MsgID-val is deprecated.  Use aauship-msg:MsgID instead.")
  (MsgID m))

(cl:ensure-generic-function 'Data-val :lambda-list '(m))
(cl:defmethod Data-val ((m <LLIinput>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader aauship-msg:Data-val is deprecated.  Use aauship-msg:Data instead.")
  (Data m))

(cl:ensure-generic-function 'Time-val :lambda-list '(m))
(cl:defmethod Time-val ((m <LLIinput>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader aauship-msg:Time-val is deprecated.  Use aauship-msg:Time instead.")
  (Time m))
(cl:defmethod roslisp-msg-protocol:serialize ((msg <LLIinput>) ostream)
  "Serializes a message object of type '<LLIinput>"
  (cl:write-byte (cl:ldb (cl:byte 8 0) (cl:slot-value msg 'DevID)) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 0) (cl:slot-value msg 'MsgID)) ostream)
  (cl:let* ((signed (cl:slot-value msg 'Data)) (unsigned (cl:if (cl:< signed 0) (cl:+ signed 65536) signed)))
    (cl:write-byte (cl:ldb (cl:byte 8 0) unsigned) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) unsigned) ostream)
    )
  (cl:let ((bits (roslisp-utils:encode-double-float-bits (cl:slot-value msg 'Time))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 32) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 40) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 48) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 56) bits) ostream))
)
(cl:defmethod roslisp-msg-protocol:deserialize ((msg <LLIinput>) istream)
  "Deserializes a message object of type '<LLIinput>"
    (cl:setf (cl:ldb (cl:byte 8 0) (cl:slot-value msg 'DevID)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 0) (cl:slot-value msg 'MsgID)) (cl:read-byte istream))
    (cl:let ((unsigned 0))
      (cl:setf (cl:ldb (cl:byte 8 0) unsigned) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) unsigned) (cl:read-byte istream))
      (cl:setf (cl:slot-value msg 'Data) (cl:if (cl:< unsigned 32768) unsigned (cl:- unsigned 65536))))
    (cl:let ((bits 0))
      (cl:setf (cl:ldb (cl:byte 8 0) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 32) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 40) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 48) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 56) bits) (cl:read-byte istream))
    (cl:setf (cl:slot-value msg 'Time) (roslisp-utils:decode-double-float-bits bits)))
  msg
)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql '<LLIinput>)))
  "Returns string type for a message object of type '<LLIinput>"
  "aauship/LLIinput")
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'LLIinput)))
  "Returns string type for a message object of type 'LLIinput"
  "aauship/LLIinput")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql '<LLIinput>)))
  "Returns md5sum for a message object of type '<LLIinput>"
  "a94107953bed535b2b14516497d99ca7")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql 'LLIinput)))
  "Returns md5sum for a message object of type 'LLIinput"
  "a94107953bed535b2b14516497d99ca7")
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql '<LLIinput>)))
  "Returns full string definition for message of type '<LLIinput>"
  (cl:format cl:nil "# This is the lli input message format for AAUSHIP~%uint8 DevID~%uint8 MsgID~%int16 Data~%float64 Time~%~%~%"))
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql 'LLIinput)))
  "Returns full string definition for message of type 'LLIinput"
  (cl:format cl:nil "# This is the lli input message format for AAUSHIP~%uint8 DevID~%uint8 MsgID~%int16 Data~%float64 Time~%~%~%"))
(cl:defmethod roslisp-msg-protocol:serialization-length ((msg <LLIinput>))
  (cl:+ 0
     1
     1
     2
     8
))
(cl:defmethod roslisp-msg-protocol:ros-message-to-list ((msg <LLIinput>))
  "Converts a ROS message object to a list"
  (cl:list 'LLIinput
    (cl:cons ':DevID (DevID msg))
    (cl:cons ':MsgID (MsgID msg))
    (cl:cons ':Data (Data msg))
    (cl:cons ':Time (Time msg))
))
