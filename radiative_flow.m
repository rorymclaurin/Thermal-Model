function [heat_gain,heat_loss] = radiative_flow(components,view_factors,temperatures,vf_compact)

%calculates radiative heat flows - particularly losses to space
%Update to add reflectance?

heat_gain = zeros(size(temperatures,1),1);

heat_loss = (temperatures.^4).*components(:,4).*sum(view_factors,2).*5.669*(10^-8);

for i = 1:size(vf_compact,1)
    
    heat_gain(vf_compact(i,2),1) = heat_gain(vf_compact(i,2),1)+...
        (vf_compact(i,3)*components(vf_compact(i,1),4)*...
                components(vf_compact(i,2),5)*5.669*(10^-8)*...
                (temperatures(vf_compact(i,1),1)^4));
    
    
end


end

