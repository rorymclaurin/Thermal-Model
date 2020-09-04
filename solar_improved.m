function [heat,solar_phi,solar_theta,solar_intensity] = solar_improved(components,view_factors,time,spin_rate)

%calculates solar input to components of the lander

heat = zeros(size(components,1),1);

solar_intensity = 1371; %W/m^2

solar_theta = 0;

solar_phi = 2*pi*mod(spin_rate*(time/60),1);

    
%Now in reference frame centred on position, new (old version, slightly dodgy) coordinate system

solar_vector = [sin(solar_theta),cos(solar_theta)*sin(solar_phi),cos(solar_theta)*cos(solar_phi)];

for i = 1:size(components,1)

    %direct sun

    component_vector = [sin(components(i,7)),cos(components(i,7))*...
        sin(components(i,6)),cos(components(i,7))*cos(components(i,6))];

    norm2sun = 2*asin(norm(component_vector-solar_vector)/2);

    if and(not(view_factors(i,1)==0),abs(norm2sun)<pi/2)

        heat(i,1) = heat(i,1)+components(i,5)*solar_intensity*...
            view_factors(1,i)*cos(norm2sun);

    end

end
    

end

