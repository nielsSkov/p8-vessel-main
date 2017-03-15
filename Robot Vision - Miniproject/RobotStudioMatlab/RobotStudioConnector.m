classdef RobotStudioConnector

    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        tcpipSocket;
        hostAddress = '192.168.1.25';
        hostPort = 59002;
        debug = false;
    end
    
    methods
        % Constructor
        function obj = RobotStudioConnector(hostAddress_,hostPort_)
            % See if connector is started with an argument
            if nargin > 0
                obj.hostAddress = hostAddress_;
                obj.hostPort = hostPort_;
            end
            
            % Connect to the server
            obj.tcpipSocket = tcpip(obj.hostAddress,obj.hostPort);
            
            try
                fopen(obj.tcpipSocket);
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
        
        %******** Move functions joint space
        
        % Move Joints
        function moveJoints(obj,varargin)
            
             if nargin == 3
                A = varargin{1};
                if (length(A) == 6 )
                    j1 = A(1); j2 = A(2); j3 = A(3); j4 = A(4); j5 = A(5); j6 = A(6);
                else
                    disp(['Position matrix has the wrong dimension, expected 6, but got: ' num2str(length(A))]);
                    return;
                end
                speed=varargin{2};
            elseif nargin == 8
               j1  = varargin{1}; j2 = varargin{2}; j3 = varargin{3}; j4 = varargin{4}; j5 = varargin{5}; j6 = varargin{6}; 
               speed = varargin{7};
            else
                disp(['Incorrect number of argumets, expected 2 or 7, but found: ' num2str(nargin) ]);
                return;
            end
            
            str = [ 'MOVEJOINTS;[' num2str(j1) ',' num2str(j2) ',' num2str(j3) ',' num2str(j4) ',' num2str(j5) ',' num2str(j6) '];' speed]; 
            robotStudioConnectorSend(obj,str);
            robotStudioConnectorWait(obj,'MOVEJOINTS;started'); % Wait for commands
            robotStudioConnectorWait(obj,'MOVEJOINTS;ended');
            
        end
        
        %******** Move functions cartesian space
        
        % Move PTP 
        function movePTP(obj,varargin) % moveJoint(x,y,z,q1,q2,q3,q4,speed) or moveJoint(A,speed) where A = [ x y z q1 q2 q3 q4 ];
    
            if nargin == 3
                A = varargin{1};
                if (length(A) == 7 )
                    x = A(1); y = A(2); z = A(3); q1 = A(4); q2 = A(5); q3 = A(6); q4 = A(7);
                else
                    disp(['Position matrix has the wrong dimension, expected 7, but got: ' num2str(length(A))]);
                    return;
                end
                speed=varargin{2};
            elseif nargin == 9
               x  = varargin{1}; y = varargin{2}; z = varargin{3}; q1 = varargin{4}; q2 = varargin{5}; q3 = varargin{6}; 
               q4 = varargin{7}; speed = varargin{8};
            else
                disp(['Incorrect number of argumets, expected 2 or 8, but found: ' num2str(nargin) ]);
                return;
            end
            
            str = [ 'MOVEPTP;[' num2str(x) ',' num2str(y) ',' num2str(z) '];[' num2str(q1) ',' num2str(q2) ',' num2str(q3) ',' num2str(q4) '];' speed];
            robotStudioConnectorSend(obj,str);
            robotStudioConnectorWait(obj,'MOVEPTP;started'); % Wait for commands
            robotStudioConnectorWait(obj,'MOVEPTP;ended');
        end
        
        % Move Linear 
        function moveLinear(obj,varargin) % moveLinear(x,y,z,q1,q2,q3,q4,speed) or moveLinear(A,speed) where A = [ x y z q1 q2 q3 q4 ];
    
            if nargin == 3
                A = varargin{1};
                if (length(A) == 7 )
                    x = A(1); y = A(2); z = A(3); q1 = A(4); q2 = A(5); q3 = A(6); q4 = A(7);
                else
                    disp(['Position matrix has the wrong dimension, expected 7, but got: ' num2str(length(A))]);
                    return;
                end
                speed=varargin{2};
            elseif nargin == 9
               x  = varargin{1}; y = varargin{2}; z = varargin{3}; q1 = varargin{4}; q2 = varargin{5}; q3 = varargin{6}; 
               q4 = varargin{7}; speed = varargin{8};
            else
                disp(['Incorrect number of argumets, expected 2 or 8, but found: ' num2str(nargin) ]);
                return;
            end
            
            str = [ 'MOVEL;[' num2str(x) ',' num2str(y) ',' num2str(z) '];[' num2str(q1) ',' num2str(q2) ',' num2str(q3) ',' num2str(q4) '];' speed];
            robotStudioConnectorSend(obj,str);
            robotStudioConnectorWait(obj,'MOVEL;started'); % Wait for commands
            robotStudioConnectorWait(obj,'MOVEL;ended');
        end

        % Move Relative PTP
        function moveRelativePTP(obj,varargin) % moveRelativeJoint(x,y,z,q1,q2,q3,q4,speed) or moveRelativeJoint(A,speed) where A = [ x y z q1 q2 q3 q4 ];
    
            if nargin == 3
                A = varargin{1};
                if (length(A) == 7 )
                    x = A(1); y = A(2); z = A(3); q1 = A(4); q2 = A(5); q3 = A(6); q4 = A(7);
                else
                    disp(['Position matrix has the wrong dimension, expected 7, but got: ' num2str(length(A))]);
                    return;
                end
                speed=varargin{2};
            elseif nargin == 9
               x  = varargin{1}; y = varargin{2}; z = varargin{3}; q1 = varargin{4}; q2 = varargin{5}; q3 = varargin{6}; 
               q4 = varargin{7}; speed = varargin{8}; 
            else
                disp(['Incorrect number of argumets, expected 2 or 8, but found: ' num2str(nargin) ]);
                return;
            end
            
            str = [ 'MOVEPTPR;[' num2str(x) ',' num2str(y) ',' num2str(z) '];[' num2str(q1) ',' num2str(q2) ',' num2str(q3) ',' num2str(q4) '];' speed];
            robotStudioConnectorSend(obj,str);
            robotStudioConnectorWait(obj,'MOVEPTPR;started'); % Wait for commands
            robotStudioConnectorWait(obj,'MOVEPTPR;ended');
        end
        
        % Move Relative Linear
        function moveRelativeLinear(obj,varargin) % moveRelaviteLinear(x,y,z,q1,q2,q3,q4,speed) or moveRelativeLinear(A,speed) where A = [ x y z q1 q2 q3 q4 ];
    
            if nargin == 3
                A = varargin{1};
                if (length(A) == 7 )
                    x = A(1); y = A(2); z = A(3); q1 = A(4); q2 = A(5); q3 = A(6); q4 = A(7);
                else
                    disp(['Position matrix has the wrong dimension, expected 7, but got: ' num2str(length(A))]);
                    return;
                end
                speed=varargin{2};
            elseif nargin == 9
               x  = varargin{1}; y = varargin{2}; z = varargin{3}; q1 = varargin{4}; q2 = varargin{5}; q3 = varargin{6}; 
               q4 = varargin{7}; speed = varargin{8};
            else
                disp(['Incorrect number of argumets, expected 2 or 8, but found: ' num2str(nargin) ]);
                return;
            end
            
            str = [ 'MOVELR;[' num2str(x) ',' num2str(y) ',' num2str(z) '];[' num2str(q1) ',' num2str(q2) ',' num2str(q3) ',' num2str(q4) '];' speed];
            disp(str);
            
            robotStudioConnectorSend(obj,str);
            robotStudioConnectorWait(obj,'MOVELR;started'); % Wait for commands
            robotStudioConnectorWait(obj,'MOVELR;ended');
        end
        
        %******** Gripper functions
        function objectGrapsState = gripperOn(obj)
            str = 'GRIPPERON;';
            robotStudioConnectorSend(obj,str);
            robotStudioConnectorWait(obj,'GRIPPERON;started'); % Wait for commands
            
            % Wait for response on object grasped
            while (obj.tcpipSocket.BytesAvailable == 0)
            end
                
            % Read all the data available
            data = fread(obj.tcpipSocket,obj.tcpipSocket.BytesAvailable);
            data = char(data');
            
            if obj.debug == true
                disp(['Data Received: ' data ]);
            end
            
            vals = regexpi(data,';','split');
            
            if (strcmp(vals{1},'GRIPPER') == 0 && strcmp(vals{2},'ended') == 0)
                disp(['DATA NOT AS EXPECTED! received: ' data]); 
                objectGrapsState = 0;
                return
            end
            
            objectGrapsState = vals{3};               
        end
        
        function gripperOff(obj)
            str = 'GRIPPEROFF;';
            robotStudioConnectorSend(obj,str);
            robotStudioConnectorWait(obj,'GRIPPEROFF;started'); % Wait for commands
            robotStudioConnectorWait(obj,'GRIPPEROFF;ended');
        end
        
        %******** Get position function
        function A = getPosition(obj) % Retuenvalue  A = [x y z q1 q2 q3 q4]
            str = 'GETPOS;';
            robotStudioConnectorSend(obj,str);
            
            % Wait for the data to arraive and extract the returned position
            while (obj.tcpipSocket.BytesAvailable == 0)
            end
                
            % Read all the data available
            data = fread(obj.tcpipSocket,obj.tcpipSocket.BytesAvailable);
            data = char(data');
            
            if obj.debug == true
                disp(['Data Received: ' data ]);
            end
            
            % Get csv data inside inside square paranthesis
            data = regexpi(data,'[[]]','split');
            data = data{2};

            % Extract the values from the csv data
            vals = regexpi(data,',','split');
            
            mask = zeros(length(vals),1);
            for i = 1:length(mask)
                if length(vals{i}) > 0
                    mask(i) = 1;
                end
            end
            
            mask = boolean(mask);
            
            vals = vals(mask);
            
            % Test if the correct number of cells has been received
            if ( length(vals) ~= 7 )
                disp(['Too few values in string, expected 7, but got: ' num2str(length(vals)) ]); 
                return;
            end

            % Form the resulting matrix
            A = [str2num(vals{1}) str2num(vals{2}) str2num(vals{3}) str2num(vals{4}) str2num(vals{5}) str2num(vals{6}) str2num(vals{7})];

        end
        
        %******** Get joint values function
        function A = getJointValues(obj)
            str = 'GETJOINTVALUES;';
            robotStudioConnectorSend(obj,str);
            
                        % Wait for the data to arraive and extract the returned position
            while (obj.tcpipSocket.BytesAvailable == 0)
            end
                
            % Read all the data available
            data = fread(obj.tcpipSocket,obj.tcpipSocket.BytesAvailable);
            data = char(data');
            
            if obj.debug == true
                disp(['Data Received: ' data ]);
            end
            
            % Get csv data inside inside square paranthesis
            data = regexpi(data,'[[]]','split');
            data = data{2};

            % Extract the values from the csv data
            vals = regexpi(data,',','split');
            
            mask = zeros(length(vals),1);
            for i = 1:length(mask)
                if length(vals{i}) > 0
                    mask(i) = 1;
                end
            end
            mask = boolean(mask);
            
            vals = vals(mask);
            
            % Form the resulting matrix
            A = [str2num(vals{1}) str2num(vals{2}) str2num(vals{3}) str2num(vals{4}) str2num(vals{5}) str2num(vals{6})];

        end
        
        %******** Camera functions
        function takePicture(obj)
            str = 'TAKEPICTURE;';
            robotStudioConnectorSend(obj,str);
            robotStudioConnectorWait(obj,'TAKEPICTURE;started'); % Wait for commands
            robotStudioConnectorWait(obj,'TAKEPICTURE;ended');
        end
    end 
end
    
function robotStudioConnectorSend(obj,str)

    % Clear the incoming buffer
    robotStudioConnectorClearBuf(obj);
    
    
    if obj.debug == true
        disp(['Data Sent:     ' str]);
    end
    
    fwrite(obj.tcpipSocket,str)
end

function robotStudioConnectorWait(obj,str)
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
       disp(['DATA NOT AS EXPECTED! received: ' data]); 
    end 
    
end

function robotStudioConnectorClearBuf(obj)
    
    if obj.tcpipSocket.BytesAvailable > 0
        % Read all the data available
        data = fread(obj.tcpipSocket,obj.tcpipSocket.BytesAvailable);
        data = char(data');

        if obj.debug == true
            disp(['Data Received (clear buf): ' data ]);
        end
    end
end
