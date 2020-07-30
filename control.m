function [heat,control_track] = control(temperatures,time,control_track)
%Models thermal control systems in the spacecraft. 
%Use the time value to build scheduled changes, such as turning on heaters
%or heat pipes

heat = zeros(size(temperatures,1),1);

control_track = 0*control_track;

control_track(1,1) = time;

%add power consumption?

%spot heaters (night)

% if mod(time,672*3600)>(1-eclipse_fraction)*672*3600
    
    % heat(12,1) = heat(12,1) + 10;%10 watts heating to WEB
    
    % control_track(2,1) = 10;
            
            
    % heat(13,1) = heat(13,1) + 5; %5 watts heating to Antenna
    
    % control_track(3,1) = 5;
    
% end  

%spot heaters (temperature dependent)

%WEB

% if temperatures(12,1)<293
    
    % heat(12,1) = heat(12,1)+10; %10 watts heating
    
    % control_track(4,1) = 10;
    
% end





%sum tracker

control_track(size(control_track,1),1) = sum(control_track(2:size(control_track,1)-1),1);
            


        
end

