function [heat,control_track] = control(temperatures,time)
%Models thermal control systems in the spacecraft. 
%Use the time value to build scheduled changes, such as turning on heaters
%or heat pipes

heat = zeros(size(temperatures,1),1);


%spot heaters (night)

% if mod(time,672*3600)>(1-eclipse_fraction)*672*3600
    
    % heat(12,1) = heat(12,1) + 10; %10 watts heating to WEB
                 
    % heat(13,1) = heat(13,1) + 5; %5 watts heating to Antenna

    
% end  

%spot heaters (temperature dependent)

%WEB

% if temperatures(12,1)<293
    
    % heat(12,1) = heat(12,1)+10; %10 watts heating
    
% end


            


        
end

