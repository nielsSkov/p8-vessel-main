; Auto-generated. Do not edit!


(cl:in-package aauship-msg)


;//! \htmlinclude Faps.msg.html

(cl:defclass <Faps> (roslisp-msg-protocol:ros-message)
  ((DevID
    :reader DevID
    :initarg :DevID
    :type cl:string
    :initform "")
   (MsgID
    :reader MsgID
    :initarg :MsgID
    :type cl:string
    :initform "")
   (Data
    :reader Data
    :initarg :Data
    :type (cl:vector cl:string)
   :initform (cl:make-array 0 :element-type 'cl:string :initial-element ""))
   (Time
    :reader Time
    :initarg :Time
    :type cl:float
    :initform 0.0))
)

(cl:defclass Faps (<Faps>)
  ())

(cl:defmethod cl:initialize-instance :after ((m <Faps>) cl:&rest args)
  (cl:declare (cl:ignorable args))
  (cl:unless (cl:typep m 'Faps)
    (roslisp-msg-protocol:msg-deprecation-warning "using old message class name aauship-msg:<Faps> is deprecated: use aauship-msg:Faps instead.")))

(cl:ensure-generic-function 'DevID-val :lambda-list '(m))
(cl:defmethod DevID-val ((m <Faps>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader aauship-msg:DevID-val is deprecated.  Use aauship-msg:DevID instead.")
  (DevID m))

(cl:ensure-generic-function 'MsgID-val :lambda-list '(m))
(cl:defmethod MsgID-val ((m <Faps>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader aauship-msg:MsgID-val is deprecated.  Use aauship-msg:MsgID instead.")
  (MsgID m))

(cl:ensure-generic-function 'Data-val :lambda-list '(m))
(cl:defmethod Data-val ((m <Faps>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader aauship-msg:Data-val is deprecated.  Use aauship-msg:Data instead.")
  (Data m))

(cl:ensure-generic-function 'Time-val :lambda-list '(m))
(cl:defmethod Time-val ((m <Faps>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader aauship-msg:Time-val is deprecated.  Use aauship-msg:Time instead.")
  (Time m))
(cl:defmethod roslisp-msg-protocol:serialize ((msg <Faps>) ostream)
  "Serializes a message object of type '<Faps>"
  (cl:let ((__ros_str_len (cl:length (cl:slot-value msg 'DevID))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_str_len) ostream))
  (cl:map cl:nil #'(cl:lambda (c) (cl:write-byte (cl:char-code c) ostream)) (cl:slot-value msg 'DevID))
  (cl:let ((__ros_str_len (cl:length (cl:slot-value msg 'MsgID))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_str_len) ostream))
  (cl:map cl:nil #'(cl:lambda (c) (cl:write-byte (cl:char-code c) ostream)) (cl:slot-value msg 'MsgID))
  (cl:let ((__ros_arr_len (cl:length (cl:slot-value msg 'Data))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_arr_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_arr_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_arr_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_arr_len) ostream))
  (cl:map cl:nil #'(cl:lambda (ele) (cl:let ((__ros_str_len (cl:length ele)))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_str_len) ostream))
  (cl:map cl:nil #'(cl:lambda (c) (cl:write-byte (cl:char-code c) ostream)) ele))
   (cl:slot-value msg 'Data))
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
(cl:defmethod roslisp-msg-protocol:deserialize ((msg <Faps>) istream)
  "Deserializes a message object of type '<Faps>"
    (cl:let ((__ros_str_len 0))
      (cl:setf (cl:ldb (cl:byte 8 0) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:slot-value msg 'DevID) (cl:make-string __ros_str_len))
      (cl:dotimes (__ros_str_idx __ros_str_len msg)
        (cl:setf (cl:char (cl:slot-value msg 'DevID) __ros_str_idx) (cl:code-char (cl:read-byte istream)))))
    (cl:let ((__ros_str_len 0))
      (cl:setf (cl:ldb (cl:byte 8 0) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:slot-value msg 'MsgID) (cl:make-string __ros_str_len))
      (cl:dotimes (__ros_str_idx __ros_str_len msg)
        (cl:setf (cl:char (cl:slot-value msg 'MsgID) __ros_str_idx) (cl:code-char (cl:read-byte istream)))))
  (cl:let ((__ros_arr_len 0))
    (cl:setf (cl:ldb (cl:byte 8 0) __ros_arr_len) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 8) __ros_arr_len) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 16) __ros_arr_len) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 24) __ros_arr_len) (cl:read-byte istream))
  (cl:setf (cl:slot-value msg 'Data) (cl:make-array __ros_arr_len))
  (cl:let ((vals (cl:slot-value msg 'Data)))
    (cl:dotimes (i __ros_arr_len)
    (cl:let ((__ros_str_len 0))
      (cl:setf (cl:ldb (cl:byte 8 0) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:aref vals i) (cl:make-string __ros_str_len))
      (cl:dotimes (__ros_str_idx __ros_str_len msg)
        (cl:setf (cl:char (cl:aref vals i) __ros_str_idx) (cl:code-char (cl:read-byte istream))))))))
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
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql '<Faps>)))
  "Returns string type for a message object of type '<Faps>"
  "aauship/Faps")
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'Faps)))
  "Returns string type for a message object of type 'Faps"
  "aauship/Faps")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql '<Faps>)))
  "Returns md5sum for a message object of type '<Faps>"
  "f77a3297cbfe51015202ca7cbc1fc789")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql 'Faps)))
  "Returns md5sum for a message object of type 'Faps"
  "f77a3297cbfe51015202ca7cbc1fc789")
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql '<Faps>)))
  "Returns full string definition for message of type '<Faps>"
  (cl:format cl:nil "# This is the message format for AAUSHIP called faps~%string DevID~%string MsgID~%string[] Data~%float64 Time~%~%~%"))
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql 'Faps)))
  "Returns full string definition for message of type 'Faps"
  (cl:format cl:nil "# This is the message format for AAUSHIP called faps~%string DevID~%string MsgID~%string[] Data~%float64 Time~%~%~%"))
(cl:defmethod roslisp-msg-protocol:serialization-length ((msg <Faps>))
  (cl:+ 0
     4 (cl:length (cl:slot-value msg 'DevID))
     4 (cl:length (cl:slot-value msg 'MsgID))
     4 (cl:reduce #'cl:+ (cl:slot-value msg 'Data) :key #'(cl:lambda (ele) (cl:declare (cl:ignorable ele)) (cl:+ 4 (cl:length ele))))
     8
))
(cl:defmethod roslisp-msg-protocol:ros-message-to-list ((msg <Faps>))
  "Converts a ROS message object to a list"
  (cl:list 'Faps
    (cl:cons ':DevID (DevID msg))
    (cl:cons ':MsgID (MsgID msg))
    (cl:cons ':Data (Data msg))
    (cl:cons ':Time (Time msg))
))
