%--------------------------------------------------------------------------
% FEDERAL UNIVERSITY OF UBERLANDIA - UFU
% Faculty of Electrical Engineering - FEELT
% Biomedical Engineering Lab - Biolab
% Uberlandia, Brazil
%--------------------------------------------------------------------------
% Author: Andrei Nakagawa-Silva
% Contact: nakagawa.andrei@gmail.com
%--------------------------------------------------------------------------
% Description: This script controls mouse position according to the force
% read by a FSR sensor connected to an Arduino Uno board. This script
% implements two different curves to convert force into mouse position
% (linear and exponential curves). From 0 to 2V, conversion is linar. From
% 2V onwards, conversion is exponential. This script serves to illustrate
% how motor learning experiments based on isometric force can be performed.
%--------------------------------------------------------------------------
% How to use:
%   - Have a force sensor (e.g.: FSR) connected to an Arduino Uno board
%   - Upload the sketch daqUNO.ino to the board
%   - Check the experiment parameters such as screen size, min and max
%   force, gain etc.
%   - Run this script
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%Libraries necessary to control mouse position from MATLAB
import java.awt.Robot;
import java.awt.event.*;
mouse = Robot; %object to control the mouse
screenSize = get(0, 'screensize'); %return screen size (didn`t work)
%--------------------------------------------------------------------------
%EXPERIMENT PARAMETERS
minScreen = 0; %minimum size of the screen
maxScreen = 1920; %maximum size of the screen
minForce = 0; %minimum force in V
maxForce = 5; %maximum force in V
gain = 7; %this gain was adjusted according to the output of the FSR
sampfreq = 100; %samplnig frequency of the Arduino Uno board
maxTime = 5; %duration of the acquisition (s)
maxSamples = maxTime * sampfreq; %total samples to be collected
forceDiv = 2; %change in curves occurs when force is equal to 2V
%--------------------------------------------------------------------------
%Linear regression coefficients.
preg = polyfit([minForce,maxForce],[minScreen,maxScreen],1);
%--------------------------------------------------------------------------
%Arduino Serial Communication
serialArduino = serial('COM6','BaudRate',38400);
fopen(serialArduino);
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%daq loop
counter = 0;
while(true)
    %data acquisition
    %read the incoming package from Arduino 
    %package protocol: [header=36][dataMSB][dataLSB][end=33]
    data = fread(serialArduino,1); %reads one byte
    if(data(1) == 36) %checks if it is the header, if positive, continue
        data = fread(serialArduino,2); %reads two bytes
        %mount the correct 16bit adc value
        force = (bitshift(data(1),8) + data(2)); 
        force = (force*5)/1023; %convert to V
        force = force*gain; %gain
        %reads one byte
        data = fread(serialArduino,1);
        if(data(1) == 33) %checks if it is end of package
            disp(['pkg ok!  force: ', num2str(force)]); %package ok
        end
    end
    
    %from the force reading, find cursor position on screen
    %If force is less than 2V, linear conversion
    if(force < forceDiv)
        cursorPos = preg(1)*force + preg(2); %applying linear regression
    else %if force is above 2V, then exponential conversion
        x = exp(force); %exponential value   
        xmin = exp(forceDiv); %minimum possible value
        xmax = exp(maxForce); %maximum possible value
        ymin=preg(1)*forceDiv + p(2); %find position when force=2V
        ymax=maxScreen; %max possible position on screen
        %converts exponential value into position on screen
        cursorPos = ((x-xmin).*(ymax-ymin) ./ (xmax-xmin)) + ymin; 
    end   
    %using floor so cursor position is an integer (pixel)
    cursorPos = floor(cursorPos);
    %display value in command window
    disp(['cursorPos: ', num2str(cursorPos)]);
    %Moves mouse on screen
    mouse.mouseMove(cursorPos,screenSize(4)/2);
    %Increments sample counter
    counter = counter+1;
    %If the desired number of samples have been collected, acquisition is
    %stopped
    if(counter >= maxSamples)
        break;  
    end
end
%--------------------------------------------------------------------------
%Closes communication with Arduino Uno.
fclose(serialArduino);
