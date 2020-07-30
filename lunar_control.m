function [lunar_temp] = lunar_control(time,eclipse_fraction)

%controls the temperature of the lunar surface according to day night cycle

if mod(time,672*3600)<(1-eclipse_fraction)*672*3600
    
    lunar_temp = 250;
    
else
    
    lunar_temp = 50;
    
end

end

