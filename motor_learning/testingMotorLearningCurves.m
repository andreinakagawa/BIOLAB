%--------------------------------------------------------------------------
% FEDERAL UNIVERSITY OF UBERLANDIA - UFU
% Faculty of Electrical Engineering - FEELT
% Biomedical Engineering Lab - Biolab
% Uberlandia, Brazil
%--------------------------------------------------------------------------
% Author: Andrei Nakagawa-Silva
% Contact: nakagawa.andrei@gmail.com
%--------------------------------------------------------------------------
% Description: This script serves to simulate a motor learning task where
% force is converted to position in the scren
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
screenWidthMin = 0; %minimum position in screen width
screenWidthMax = 1366; %maximum position in screen width
%--------------------------------------------------------------------------
maxADV = 5.0; %ADC full-scale: 5V
minForce = 0.7; %taking into account possible baseline noise
maxForce = 3.2; %force during MVC
maxPercMVC = 70; %motor learning task will go up to 70% of MVC level
%--------------------------------------------------------------------------
%ALGORITHM:
%From 0 to 40% MVC, the conversion from force (in V) to position on the
%screen is linear. From that value until force reaches 70% MVC (in V), the
%conversion is exponential. To find the position on the screen according to
%an exponential curve, I used a method that converts one scale to another
%according to minimum and maximum values.
%--------------------------------------------------------------------------
%Consider a linear increasing force from rest to the maximum percentage
%of the MVC
forceSignal = minForce:0.01:((maxPercMVC/100)*maxForce);
%--------------------------------------------------------------------------
%Linear Regression from rest to 40% MVC -> origin to middle of screen
%find index that are less than 40% MVC
idx = find(forceSignal <= 0.4*(maxPercMVC/100)*maxForce);
%regression coefficient
preg = polyfit([forceSignal(1),forceSignal(idx(end))], ...
    [screenWidthMin,screenWidthMax/2],1); 
%--------------------------------------------------------------------------
%From 40% MVC onwards, exponential curve
expCurve = exp(forceSignal(idx(end)+1:end));
minExp = min(expCurve); %minimum value in the exponential curve
maxExp = max(expCurve); %maximum value in the exponential curve
%--------------------------------------------------------------------------
%From forceSignal, generate positions on the screen
cursorPosition = []; %array to store positions
for k=1:length(forceSignal)
    if(forceSignal(k) <= forceSignal(idx(end)))
        pos = (preg(1)*forceSignal(k)) + preg(2);
        if(pos < 0)
            pos = 0;
        end
        cursorPosition = [cursorPosition pos];
    else
        %find the position on the screen based on the exponential value
        %convScale converts values in exponential scale to position scale
        expPos = convScale(exp(forceSignal(k)),minExp,maxExp,...
            cursorPosition(idx(end)),screenWidthMax);
        cursorPosition = [cursorPosition expPos];
    end
end
%--------------------------------------------------------------------------
%Plot the curves
figure(); %new figure
subplot(2,1,1); %1st subplot
plot(forceSignal); %force
ylabel('Force (V)');
subplot(2,1,2); %2nd subplot
plot(cursorPosition); %position
ylabel('Position (pixel)');
xlabel('Samples');