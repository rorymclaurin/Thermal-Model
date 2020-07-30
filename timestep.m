function [step] = timestep(conductances,components,view_factors) 
%Calculates an appropriate timestep using the limit 
%identified by C. B. VanOutryve

conductive_sums = sum(conductances,2);

radiative_sums = 4*(1500^3)*5.669*(10^-8)*components(:,5).*sum(view_factors,2);

recip_bounds = (conductive_sums+radiative_sums)./components(:,3);

step = 1/max(recip_bounds(3:size(recip_bounds,1)));
    
    
end

