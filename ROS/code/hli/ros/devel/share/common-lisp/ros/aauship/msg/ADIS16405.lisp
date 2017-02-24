; Auto-generated. Do not edit!


(cl:in-package aauship-msg)


;//! \htmlinclude ADIS16405.msg.html

(cl:defclass <ADIS16405> (roslisp-msg-protocol:ros-message)
  ((supply
    :reader supply
    :initarg :supply
    :type cl:float
    :initform 0.0)
   (xgyro
    :reader xgyro
    :initarg :xgyro
    :type cl:float
    :initform 0.0)
   (ygyro
    :reader ygyro
    :initarg :ygyro
    :type cl:float
    :initform 0.0)
   (zgyro
    :reader zgyro
    :initarg :zgyro
    :type cl:float
    :initform 0.0)
   (xaccl
    :reader xaccl
    :initarg :xaccl
    :type cl:float
    :initform 0.0)
   (yaccl
    :reader yaccl
    :initarg :yaccl
    :type cl:float
    :initform 0.0)
   (zaccl
    :reader zaccl
    :initarg :zaccl
    :type cl:float
    :initform 0.0)
   (xmagn
    :reader xmagn
    :initarg :xmagn
    :type cl:float
    :initform 0.0)
   (ymagn
    :reader ymagn
    :initarg :ymagn
    :type cl:float
    :initform 0.0)
   (zmagn
    :reader zmagn
    :initarg :zmagn
    :type cl:float
    :initform 0.0)
   (temp
    :reader temp
    :initarg :temp
    :type cl:float
    :initform 0.0)
   (adc
    :reader adc
    :initarg :adc
    :type cl:float
    :initform 0.0))
)

(cl:defclass ADIS16405 (<ADIS16405>)
  ())

(cl:defmethod cl:initialize-instance :after ((m <ADIS16405>) cl:&rest args)
  (cl:declare (cl:ignorable args))
  (cl:unless (cl:typep m 'ADIS16405)
    (roslisp-msg-protocol:msg-deprecation-warning "using old message class name aauship-msg:<ADIS16405> is deprecated: use aauship-msg:ADIS16405 instead.")))

(cl:ensure-generic-function 'supply-val :lambda-list '(m))
(cl:defmethod supply-val ((m <ADIS16405>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader aauship-msg:supply-val is deprecated.  Use aauship-msg:supply instead.")
  (supply m))

(cl:ensure-generic-function 'xgyro-val :lambda-list '(m))
(cl:defmethod xgyro-val ((m <ADIS16405>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader aauship-msg:xgyro-val is deprecated.  Use aauship-msg:xgyro instead.")
  (xgyro m))

(cl:ensure-generic-function 'ygyro-val :lambda-list '(m))
(cl:defmethod ygyro-val ((m <ADIS16405>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader aauship-msg:ygyro-val is deprecated.  Use aauship-msg:ygyro instead.")
  (ygyro m))

(cl:ensure-generic-function 'zgyro-val :lambda-list '(m))
(cl:defmethod zgyro-val ((m <ADIS16405>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader aauship-msg:zgyro-val is deprecated.  Use aauship-msg:zgyro instead.")
  (zgyro m))

(cl:ensure-generic-function 'xaccl-val :lambda-list '(m))
(cl:defmethod xaccl-val ((m <ADIS16405>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader aauship-msg:xaccl-val is deprecated.  Use aauship-msg:xaccl instead.")
  (xaccl m))

(cl:ensure-generic-function 'yaccl-val :lambda-list '(m))
(cl:defmethod yaccl-val ((m <ADIS16405>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader aauship-msg:yaccl-val is deprecated.  Use aauship-msg:yaccl instead.")
  (yaccl m))

(cl:ensure-generic-function 'zaccl-val :lambda-list '(m))
(cl:defmethod zaccl-val ((m <ADIS16405>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader aauship-msg:zaccl-val is deprecated.  Use aauship-msg:zaccl instead.")
  (zaccl m))

(cl:ensure-generic-function 'xmagn-val :lambda-list '(m))
(cl:defmethod xmagn-val ((m <ADIS16405>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader aauship-msg:xmagn-val is deprecated.  Use aauship-msg:xmagn instead.")
  (xmagn m))

(cl:ensure-generic-function 'ymagn-val :lambda-list '(m))
(cl:defmethod ymagn-val ((m <ADIS16405>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader aauship-msg:ymagn-val is deprecated.  Use aauship-msg:ymagn instead.")
  (ymagn m))

(cl:ensure-generic-function 'zmagn-val :lambda-list '(m))
(cl:defmethod zmagn-val ((m <ADIS16405>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader aauship-msg:zmagn-val is deprecated.  Use aauship-msg:zmagn instead.")
  (zmagn m))

(cl:ensure-generic-function 'temp-val :lambda-list '(m))
(cl:defmethod temp-val ((m <ADIS16405>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader aauship-msg:temp-val is deprecated.  Use aauship-msg:temp instead.")
  (temp m))

(cl:ensure-generic-function 'adc-val :lambda-list '(m))
(cl:defmethod adc-val ((m <ADIS16405>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader aauship-msg:adc-val is deprecated.  Use aauship-msg:adc instead.")
  (adc m))
(cl:defmethod roslisp-msg-protocol:serialize ((msg <ADIS16405>) ostream)
  "Serializes a message object of type '<ADIS16405>"
  (cl:let ((bits (roslisp-utils:encode-single-float-bits (cl:slot-value msg 'supply))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) bits) ostream))
  (cl:let ((bits (roslisp-utils:encode-single-float-bits (cl:slot-value msg 'xgyro))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) bits) ostream))
  (cl:let ((bits (roslisp-utils:encode-single-float-bits (cl:slot-value msg 'ygyro))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) bits) ostream))
  (cl:let ((bits (roslisp-utils:encode-single-float-bits (cl:slot-value msg 'zgyro))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) bits) ostream))
  (cl:let ((bits (roslisp-utils:encode-single-float-bits (cl:slot-value msg 'xaccl))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) bits) ostream))
  (cl:let ((bits (roslisp-utils:encode-single-float-bits (cl:slot-value msg 'yaccl))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) bits) ostream))
  (cl:let ((bits (roslisp-utils:encode-single-float-bits (cl:slot-value msg 'zaccl))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) bits) ostream))
  (cl:let ((bits (roslisp-utils:encode-single-float-bits (cl:slot-value msg 'xmagn))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) bits) ostream))
  (cl:let ((bits (roslisp-utils:encode-single-float-bits (cl:slot-value msg 'ymagn))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) bits) ostream))
  (cl:let ((bits (roslisp-utils:encode-single-float-bits (cl:slot-value msg 'zmagn))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) bits) ostream))
  (cl:let ((bits (roslisp-utils:encode-single-float-bits (cl:slot-value msg 'temp))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) bits) ostream))
  (cl:let ((bits (roslisp-utils:encode-single-float-bits (cl:slot-value msg 'adc))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) bits) ostream))
)
(cl:defmethod roslisp-msg-protocol:deserialize ((msg <ADIS16405>) istream)
  "Deserializes a message object of type '<ADIS16405>"
    (cl:let ((bits 0))
      (cl:setf (cl:ldb (cl:byte 8 0) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) bits) (cl:read-byte istream))
    (cl:setf (cl:slot-value msg 'supply) (roslisp-utils:decode-single-float-bits bits)))
    (cl:let ((bits 0))
      (cl:setf (cl:ldb (cl:byte 8 0) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) bits) (cl:read-byte istream))
    (cl:setf (cl:slot-value msg 'xgyro) (roslisp-utils:decode-single-float-bits bits)))
    (cl:let ((bits 0))
      (cl:setf (cl:ldb (cl:byte 8 0) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) bits) (cl:read-byte istream))
    (cl:setf (cl:slot-value msg 'ygyro) (roslisp-utils:decode-single-float-bits bits)))
    (cl:let ((bits 0))
      (cl:setf (cl:ldb (cl:byte 8 0) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) bits) (cl:read-byte istream))
    (cl:setf (cl:slot-value msg 'zgyro) (roslisp-utils:decode-single-float-bits bits)))
    (cl:let ((bits 0))
      (cl:setf (cl:ldb (cl:byte 8 0) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) bits) (cl:read-byte istream))
    (cl:setf (cl:slot-value msg 'xaccl) (roslisp-utils:decode-single-float-bits bits)))
    (cl:let ((bits 0))
      (cl:setf (cl:ldb (cl:byte 8 0) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) bits) (cl:read-byte istream))
    (cl:setf (cl:slot-value msg 'yaccl) (roslisp-utils:decode-single-float-bits bits)))
    (cl:let ((bits 0))
      (cl:setf (cl:ldb (cl:byte 8 0) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) bits) (cl:read-byte istream))
    (cl:setf (cl:slot-value msg 'zaccl) (roslisp-utils:decode-single-float-bits bits)))
    (cl:let ((bits 0))
      (cl:setf (cl:ldb (cl:byte 8 0) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) bits) (cl:read-byte istream))
    (cl:setf (cl:slot-value msg 'xmagn) (roslisp-utils:decode-single-float-bits bits)))
    (cl:let ((bits 0))
      (cl:setf (cl:ldb (cl:byte 8 0) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) bits) (cl:read-byte istream))
    (cl:setf (cl:slot-value msg 'ymagn) (roslisp-utils:decode-single-float-bits bits)))
    (cl:let ((bits 0))
      (cl:setf (cl:ldb (cl:byte 8 0) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) bits) (cl:read-byte istream))
    (cl:setf (cl:slot-value msg 'zmagn) (roslisp-utils:decode-single-float-bits bits)))
    (cl:let ((bits 0))
      (cl:setf (cl:ldb (cl:byte 8 0) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) bits) (cl:read-byte istream))
    (cl:setf (cl:slot-value msg 'temp) (roslisp-utils:decode-single-float-bits bits)))
    (cl:let ((bits 0))
      (cl:setf (cl:ldb (cl:byte 8 0) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) bits) (cl:read-byte istream))
    (cl:setf (cl:slot-value msg 'adc) (roslisp-utils:decode-single-float-bits bits)))
  msg
)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql '<ADIS16405>)))
  "Returns string type for a message object of type '<ADIS16405>"
  "aauship/ADIS16405")
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'ADIS16405)))
  "Returns string type for a message object of type 'ADIS16405"
  "aauship/ADIS16405")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql '<ADIS16405>)))
  "Returns md5sum for a message object of type '<ADIS16405>"
  "7cf3439b3e98d50b8f75a089f6f143fa")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql 'ADIS16405)))
  "Returns md5sum for a message object of type 'ADIS16405"
  "7cf3439b3e98d50b8f75a089f6f143fa")
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql '<ADIS16405>)))
  "Returns full string definition for message of type '<ADIS16405>"
  (cl:format cl:nil "# Format for the ADIS13205 IMU from the LLI decoded data~%float32 supply~%float32 xgyro~%float32 ygyro~%float32 zgyro~%float32 xaccl~%float32 yaccl~%float32 zaccl~%float32 xmagn~%float32 ymagn~%float32 zmagn~%float32 temp~%float32 adc~%~%~%"))
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql 'ADIS16405)))
  "Returns full string definition for message of type 'ADIS16405"
  (cl:format cl:nil "# Format for the ADIS13205 IMU from the LLI decoded data~%float32 supply~%float32 xgyro~%float32 ygyro~%float32 zgyro~%float32 xaccl~%float32 yaccl~%float32 zaccl~%float32 xmagn~%float32 ymagn~%float32 zmagn~%float32 temp~%float32 adc~%~%~%"))
(cl:defmethod roslisp-msg-protocol:serialization-length ((msg <ADIS16405>))
  (cl:+ 0
     4
     4
     4
     4
     4
     4
     4
     4
     4
     4
     4
     4
))
(cl:defmethod roslisp-msg-protocol:ros-message-to-list ((msg <ADIS16405>))
  "Converts a ROS message object to a list"
  (cl:list 'ADIS16405
    (cl:cons ':supply (supply msg))
    (cl:cons ':xgyro (xgyro msg))
    (cl:cons ':ygyro (ygyro msg))
    (cl:cons ':zgyro (zgyro msg))
    (cl:cons ':xaccl (xaccl msg))
    (cl:cons ':yaccl (yaccl msg))
    (cl:cons ':zaccl (zaccl msg))
    (cl:cons ':xmagn (xmagn msg))
    (cl:cons ':ymagn (ymagn msg))
    (cl:cons ':zmagn (zmagn msg))
    (cl:cons ':temp (temp msg))
    (cl:cons ':adc (adc msg))
))
