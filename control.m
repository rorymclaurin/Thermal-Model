function [heat] = control(temperatures,time,solar_intensity)
%Models thermal control systems in the spacecraft. 
%Use the solar_intensity value to build scheduled changes, such as turning on heaters

heat = zeros(size(temperatures,1),1);
      
end

