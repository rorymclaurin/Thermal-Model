function [lunar_temp] = lunar_control(time,solar_intensity)

%controls the temperature of the lunar surface according to day night cycle

if solar_intensity == 0
    
    lunar_temp = 50;
    
else
    
    lunar_temp = 250;
    
end

end

