% Class and functions used to connect and communicate with KUKA KR6 R700
% over ethernet. Please use either the ethernet cable or connect to the 
% Robot Minions wifi (pass: robotlab). The IP address of the robots are:

% Wall-E: 192.168.1.200
% JARVIS: 192.168.1.210 

%****************************Usage***************************
%% STEP 1 - run module on robot
% run the "KukaServer" module on the KUKA robot. It is located in
% /Program/ethernet/.
%
%% STEP2 - create object and connect
% create instance of this class. This also connects to the robot. You
% should see the program on the robot jump to "WAIT FOR $FLAG[2]. Also, the
% matlab script should return. If the matlab script waits/halts, your
% connection is not working. Check your connection, wifi/cable, and IP of
% robot.
%   r = RobotConnectorKUKA
%
%% STEP3 - call function (use robot)
% to use the robot, simply call one of the functions in this class. for
% instance:
% MOVELINEAR
%   moveLinear(r,x,y,z,a,b,c,vel) - 
% robot moves to the x,y,z,a,b,c coordinate at the given speed. Speed is a 
% scale - hence 0-1 is allowed. Note, the object created in step 2 must
% always be passed in as the first argument for all functions in this
% class.
% GRASP
%   closeGrapper(r)
% simply closes the gripper, nothing else needed.
% GETPOSITION
%   pos = getPosition(r)
% returns an array containing the cartesian postion of the robot TCP. You
% can afterwards access the individual elements by: pos(1), pos(2), etc.
%
% Good luck...

%%          
classdef RobotConnectorKUKA
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        % Wall-E ip = '192.168.1.200'
        %JARVIS ip = '192.168.1.210'       %copy/paste the IP needed 
        hostAddress = '192.168.1.210';
        hostPort = 54601;
        tcpipSocket;
        debug = true; % debug print-outs
        speed_lower_threshold = 0.01; % 1% speed is lower limit
    end
    
    methods
        % Constructor
        function obj = RobotConnectorKUKA(hostAddress_,hostPort_)
            % See if connector is started with an argument
            if nargin > 0
                obj.hostAddress = hostAddress_;
                obj.hostPort = hostPort_;
            end
            
            % Connect to the server
            obj.tcpipSocket = tcpip(obj.hostAddress,obj.hostPort);
            
            try
                fopen(obj.tcpipSocket);
                disp('opening socket');
            catch err
                disp(['COULD NOT CONNECT TO SERVER: ' err.message]);
                %rethrow(err);
            end
        end
        
        % Destructor
        function delete(obj)
            fclose(obj.tcpipSocket);
            delete(obj.tcpipSocket);
        end
        
        %******** Move functions
        % Move Joint
        function moveJoint(obj,varargin) % moveJoint(x,y,z,w,p,r,speed) or moveJoint(A,speed) where A = [ x y z w p r ];
            
            if nargin == 3
                A = varargin{1};
                if (length(A) == 6 )
                    x = A(1); y = A(2); z = A(3); w = A(4); p = A(5); r = A(6);
                else
                    disp(['Position matrix has the wrong dimension, expected 6, but got: ' num2str(length(A))]);
                    return;
                end
                speed=varargin{2};
            elseif nargin == 8
                x  = varargin{1}; y = varargin{2}; z = varargin{3}; w = varargin{4}; p = varargin{5}; r = varargin{6};
                speed = varargin{7};
            else
                disp(['Incorrect number of argumets, expected 2 or 7, but found: ' num2str(nargin) ]);
                return;
            end
            
            %Ensure speed consistency
            speed = checkSpeed(obj,speed);
            
            str = [ '1 ' num2str(x) ' ' num2str(y) ' ' num2str(z) ' ' num2str(w) ' ' num2str(p) ' ' num2str(r) ' ' num2str(speed) 13 10];
            robotSend(obj,str);
            robotWait(obj,['MoveJ;started;' 13 10]); % Wait for commands
            robotWait(obj,['MoveJ;ended;' 13 10]);
        end
        
        % Move cartesian (ptp movement)
        function moveCart(obj,varargin) % moveCart(x,y,z,w,p,r,speed) or moveCart(A,speed) where A = [ x y z w p r ];
            
            if nargin == 3
                A = varargin{1};
                if (length(A) == 6 )
                    x = A(1); y = A(2); z = A(3); w = A(4); p = A(5); r = A(6);
                else
                    disp(['Position matrix has the wrong dimension, expected 6, but got: ' num2str(length(A))]);
                    return;
                end
                speed=varargin{2};
            elseif nargin == 8
                x  = varargin{1}; y = varargin{2}; z = varargin{3}; w = varargin{4}; p = varargin{5}; r = varargin{6};
                speed = varargin{7};
            else
                disp(['Incorrect number of argumets, expected 2 or 7, but found: ' num2str(nargin) ]);
                return;
            end
            
            %Ensure speed consistency
            if speed <= obj.speed_lower_threshold
                speed = obj.speed_lower_threshold;
            elseif speed > 1
                speed = 1.0;
            end
            
            str = [ '2 ' num2str(x) ' ' num2str(y) ' ' num2str(z) ' ' num2str(w) ' ' num2str(p) ' ' num2str(r) ' ' num2str(speed) 13 10];
            robotSend(obj,str);
            robotWait(obj,['MoveC;started;' 13 10]); % Wait for commands
            robotWait(obj,['MoveC;ended;' 13 10]);
        end
        
        % Move cartesian Linear
        function moveLinear(obj,varargin) % moveLinear(x,y,z,w,p,r,speed) or moveLinear(A,speed) where A = [ x y z w p r ];
            
            if nargin == 3
                A = varargin{1};
                if (length(A) == 6 )
                    x = A(1); y = A(2); z = A(3); w = A(4); p = A(5); r = A(6);
                else
                    disp(['Position matrix has the wrong dimension, expected 6, but got: ' num2str(length(A))]);
                    return;
                end
                speed=varargin{2};
            elseif nargin == 8
                x  = varargin{1}; y = varargin{2}; z = varargin{3}; w = varargin{4}; p = varargin{5}; r = varargin{6};
                speed = varargin{7};
            else
                disp(['Incorrect number of argumets, expected 2 or 7, but found: ' num2str(nargin) ]);
                return;
            end
            
            %Ensure speed consistency
            if speed <= obj.speed_lower_threshold
                speed = obj.speed_lower_threshold;
            elseif speed > 1
                speed = 1.0;
            end
            
            str = [ '3 ' num2str(x) ' ' num2str(y) ' ' num2str(z) ' ' num2str(w) ' ' num2str(p) ' ' num2str(r) ' ' num2str(speed) 13 10];
            robotSend(obj,str);
            robotWait(obj,['MoveL;started;' 13 10]); % Wait for commands
            robotWait(obj,['MoveL;ended;' 13 10]);
        end
        
        
        % Move Relative Joint
        function moveRelativeJoint(obj,varargin) % moveRelativeJoint(x,y,z,w,p,r,speed) or moveRelativeJoint(A,speed) where A = [ x y z w p r ];
            
            if nargin == 3
                A = varargin{1};
                if (length(A) == 6 )
                    x = A(1); y = A(2); z = A(3); w = A(4); p = A(5); r = A(6);
                else
                    disp(['Position matrix has the wrong dimension, expected 6, but got: ' num2str(length(A))]);
                    return;
                end
                speed=varargin{2};
            elseif nargin == 8
                x  = varargin{1}; y = varargin{2}; z = varargin{3}; w = varargin{4}; p = varargin{5}; r = varargin{6};
                speed = varargin{7};
            else
                disp(['Incorrect number of argumets, expected 2 or 7, but found: ' num2str(nargin) ]);
                return;
            end
            
            %Ensure speed consistency
            if speed <= obj.speed_lower_threshold
                speed = obj.speed_lower_threshold;
            elseif speed > 1
                speed = 1.0;
            end
            
            str = [ '4 ' num2str(x) ' ' num2str(y) ' ' num2str(z) ' ' num2str(w) ' ' num2str(p) ' ' num2str(r) ' ' num2str(speed) 13 10];
            robotSend(obj,str);
            robotWait(obj,['MoveJR;started;' 13 10]); % Wait for commands
            robotWait(obj,['MoveJR;ended;' 13 10]);
        end
        
        % Move Relative Linear
        function moveRelativeLinear(obj,varargin) % moveRelaviteLinear(x,y,z,w,p,r,speed) or moveRelativeLinear(A,speed) where A = [ x y z w p r ];
            
            if nargin == 3
                A = varargin{1};
                if (length(A) == 6 )
                    x = A(1); y = A(2); z = A(3); w = A(4); p = A(5); r = A(6);
                else
                    disp(['Position matrix has the wrong dimension, expected 6, but got: ' num2str(length(A))]);
                    return;
                end
                speed=varargin{2};
            elseif nargin == 8
                x  = varargin{1}; y = varargin{2}; z = varargin{3}; w = varargin{4}; p = varargin{5}; r = varargin{6};
                speed = varargin{7};
            else
                disp(['Incorrect number of argumets, expected 2 or 7, but found: ' num2str(nargin) ]);
                return;
            end
            
            %Ensure speed consistency
            if speed <= obj.speed_lower_threshold
                speed = obj.speed_lower_threshold;
            elseif speed > 1
                speed = 1.0;
            end
            
            str = [ '5 ' num2str(x) ' ' num2str(y) ' ' num2str(z) ' ' num2str(w) ' ' num2str(p) ' ' num2str(r) ' ' num2str(speed) 13 10];
            robotSend(obj,str);
            robotWait(obj,['MoveLR;started;' 13 10]); % Wait for commands
            robotWait(obj,['MoveLR;ended;' 13 10]);
        end
        
        % Open and close grabber
        function openGrapper(obj)
            str = [ '6 ' 13 10 ];
            robotSend(obj,str);
            robotWait(obj,['OpenG;started;' 13 10]); % Wait for commands
            robotWait(obj,['OpenG;ended;' 13 10]);
        end
        
        function closeGrapper(obj)
            % str = [ 'MOVEL;[-3 12 -41 9 -36 0 20];'];
            str = [ '7 ' 13 10 ];
            robotSend(obj,str);
            robotWait(obj,['CloseG;started;' 13 10]); % Wait for commands
            robotWait(obj,['CloseG;ended;' 13 10]);
        end
        
        %******** Get joint configuration function
        function A = getJoint(obj) % Retuenvalue  A = [x y z w p r]
            str = [ '8 ' 13 10 ];
            robotSend(obj,str);
            
            % Wait for the data to arraivem and extract the returned position
            while (obj.tcpipSocket.BytesAvailable == 0)
            end
            
            % Read all the data available
            data = fread(obj.tcpipSocket,obj.tcpipSocket.BytesAvailable);
            data = char(data');
            
            if obj.debug == true
                disp(['Data Received: ' data ]);
            end
            
            vals = strsplit(data);
            
            % Test if the correct number of cells has been received
            if ( length(vals) < 6 )
                disp(['Too few values in string, expected 6, but got: ' num2str(length(vals)) ]);
                return;
            end
            
            % Form the resulting matrix
            A = [str2num(vals{1}) str2num(vals{2}) str2num(vals{3}) str2num(vals{4}) str2num(vals{5}) str2num(vals{6})];
            
        end
        
        %******** Get cartesian position function
        function A = getPosition(obj) % Retuenvalue  A = [x y z w p r]
            str = [ '9 ' 13 10 ];
            robotSend(obj,str);
            
            % Wait for the data to arraivem and extract the returned position
            while (obj.tcpipSocket.BytesAvailable == 0)
            end
            
            % Read all the data available
            data = fread(obj.tcpipSocket,obj.tcpipSocket.BytesAvailable);
            data = char(data');
            if obj.debug == true
                disp(['Data Received: ' data ]);
            end
            
            vals = strsplit(data);
            
            % Test if the correct number of cells has been received
            if ( length(vals) < 6 )
                disp(['Too few values in string, expected 6, but got: ' num2str(length(vals)) ]);
                return;
            end
            
            % Form the resulting matrix
            A = [str2num(vals{1}) str2num(vals{2}) str2num(vals{3}) str2num(vals{4}) str2num(vals{5}) str2num(vals{6})];
            
        end
        
        function speed_out = checkSpeed(obj,speed_in)
            speed_out = speed_in;
            if speed_in <= obj.speed_lower_threshold
                speed_out = obj.speed_lower_threshold;
                disp('Speed below lower threshold - setting speed = lower threshold');
            elseif speed_in > 1
                speed_out = 1.0;
                disp('Speed above 1 (100%) - setting speed = 1 (100%)');
            end
        end
        
    end
    
end


function robotSend(obj,str)

% Clear the incoming buffer
robotClearBuf(obj);


if obj.debug == true
    disp(['Data sent:     ' str(1:end-1)]);
end

fwrite(obj.tcpipSocket,str);
end

function robotWait(obj,str)
% Wait for data to be ready
while (obj.tcpipSocket.BytesAvailable == 0)
    
end

% Read all the data available
data = fread(obj.tcpipSocket,obj.tcpipSocket.BytesAvailable);
data = char(data');

if obj.debug == true
    disp(['Data Received: ' data ]);
end

if strcmp(data,str) == 0
    disp('DATA NOT AS EXPECTED!');
end

end

function robotClearBuf(obj)

if obj.tcpipSocket.BytesAvailable > 0
    % Read all the data available
    data = fread(obj.tcpipSocket,obj.tcpipSocket.BytesAvailable);
    data = char(data');
    
    if obj.debug == true
        disp(['Data Received (clear buf): ' data ]);
    end
end
end




