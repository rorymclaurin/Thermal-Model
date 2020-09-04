function [heat_loss] = vacuum_loss(components,view_factors,temperatures)

%calculates losses to vacuum - which are not treated as reflection
%networks


heat_loss = (temperatures.^4).*components(:,4).*view_factors(:,1).*5.669*(10^-8);

heat_loss = -heat_loss;



end

