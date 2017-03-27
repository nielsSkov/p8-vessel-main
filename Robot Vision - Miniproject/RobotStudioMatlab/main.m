%%
clear
clc

robot = RobotStudioConnector('192.168.0.172',1024);  %This creates a 
            % RobotStudioConnector object while connecting to the server
MoveHome(robot)
robot.getPosition