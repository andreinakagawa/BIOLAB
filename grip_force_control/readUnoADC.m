%--------------------------------------------------------------------------
% FEDERAL UNIVERSITY OF UBERLANDIA - UFU
% FACULTY OF ELECTRICAL ENGINEERING - FEELT
% BIOMEDICAL ENGINEERING LAB - BIOLAB
% Uberlândia, Brazil
%--------------------------------------------------------------------------
% Author: Andrei Nakagawa-Silva
% Contact: nakagawa.andrei@gmail.com
%--------------------------------------------------------------------------
% Description: This script reads from Arduino during a specific amount of
% time and saves data.
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%Parameters
%Serial
portName = 'COM10'; %serial port
baudRate = 38400; %baudrate
%Serial package
PKG_HEADER = 36; %header
PKG_END = 33; %end of package
PKG_DATA_SIZE = 2; %number of bytes that are actual data
%Acquisition
sampfreq = 100; %sampling frequency in Hz, according to unoADC
dt = 1.0/sampfreq; %sampling period (s)
maxTime = 10; %duration in s
maxSamples = sampfreq * maxTime; %number of samples to be read
counter = 1; %counts the number of samples read from the Arduino board
%time vector
time = (1:maxSamples) .* dt; %multiplies every sample by dt
%data array
dataArray = zeros(1,maxSamples);
%--------------------------------------------------------------------------
%Handler to serialport
serialArduino = serial(portName,'BaudRate',baudRate);
%Open serial communication
fopen(serialArduino);
%Keep reading until maxSamples is reached
while(counter <= maxSamples)
    %reads one byte -> search for the header
    header = fread(serialArduino,1);
    if(header == PKG_HEADER) %header found
        %reads the amount of bytes that are actual data
        data = fread(serialArduino,PKG_DATA_SIZE); 
        pkgEnd = fread(serialArduino,1);
        if(pkgEnd == PKG_END) %end of package found
            %If end of package is found, then the package is valid            
            %retrieves the MSB part of the ADC value
            %analog to data[0]<<8 if it was in C/C++/C#
            dataMSB = bitshift(data(1),8);
            dataLSB = data(2);
            %the ADC value is given by: (dataMSB<<8) | dataLSB (C/C++/C#)            
            dataArray(counter) = bitor(dataMSB,dataLSB); 
            %increments the sample counter
            counter = counter+1;
        end
    end
end
%closes the serial port
fclose(serialArduino);
%--------------------------------------------------------------------------
%saving data in a .mat file
resp.sampfreq = sampfreq; %sampling frequency (Hz)
resp.dt = dt; %sampling period (s)
resp.time = time; %time vector
resp.dataArray = dataArray; %ADC data
save('experimentResults.mat','-struct','resp');
%--------------------------------------------------------------------------