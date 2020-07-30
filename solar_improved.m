function [heat,solar_phi,solar_theta] = solar_improved(components,view_factors,time,latitude,longitude,initial_season_angle,horizon_elevation)

%calculates solar input to components of the lander

heat = zeros(size(components,1),1);

solar_intensity = 1371; %W/m^2

season_angle = initial_season_angle + ((2*pi*time)/(12*3600*24*28));


%Sun centred reference
Sun_Earth_Vec = 1.5*(10^8)*[cos(season_angle);sin(season_angle);0];%Are spring and Autumn equivalent?


%Earth centered reference (for now!)
%Sim starts at midnight for Lunar prime meridian

Earth_Moon_Angle = (mod(time,672*3600)/(672*3600))*2*pi;
Earth_Moon_Vec = 385000*[-(cos(Earth_Moon_Angle)*cos(5.14*2*pi/360));sin(Earth_Moon_Angle);...
    cos(Earth_Moon_Angle)*sin(5.14*2*pi/360)];

%Moon centred reference (but accounting for season) will not be rotated to
%preserve polar axis of moon

Moon_Pos_Vec = 1737.4*((sin(latitude)*[-sin(1.54*2*pi/360);0;cos(1.54*2*pi/360)])+...
    (cos(latitude)*[cos(1.54*2*pi/360)*cos(longitude+Earth_Moon_Angle+season_angle);...
    sin(longitude+Earth_Moon_Angle+season_angle);sin(1.54*2*pi/360)*cos(longitude+Earth_Moon_Angle+season_angle)]));


%Back to Sun centered frame
season_rotation = [cos(season_angle),-sin(season_angle),0;...
    sin(season_angle),cos(season_angle),0;0,0,1];
Sun_Pos_Vec = Sun_Earth_Vec + (season_rotation*Earth_Moon_Vec) + Moon_Pos_Vec;

%Centre on position and normalise
Pos_Sun_Unit = (-1/norm(Sun_Pos_Vec))*Sun_Pos_Vec;

Local_Noon_Unit = Moon_Pos_Vec/norm(Moon_Pos_Vec);

Pos_Pole_Vec = (1737.4*[-sin(1.54*2*pi/360);0;cos(1.54*2*pi/360)])-Moon_Pos_Vec;

Pos_Pole_Unit = Pos_Pole_Vec/norm(Pos_Pole_Vec);

Local_North_Vec = cross(Local_Noon_Unit,cross(Pos_Pole_Unit,Local_Noon_Unit));
Local_North_Unit = Local_North_Vec/norm(Local_North_Vec);

solar_theta = (pi/2)-acos(dot(Pos_Sun_Unit,Local_Noon_Unit));

Solar_Tangent_Vec = cross(Local_Noon_Unit,cross(Pos_Sun_Unit,Local_Noon_Unit));
Solar_Tangent_Unit = Solar_Tangent_Vec/norm(Solar_Tangent_Vec);

%Corrects so that western angles are negative
phi_correction = dot(Local_Noon_Unit,...
    (cross(Local_North_Unit,Solar_Tangent_Unit))/norm(cross(Local_North_Unit,Solar_Tangent_Unit)));

solar_phi = phi_correction*acos(dot(Local_North_Unit,Solar_Tangent_Unit));

solar_phi = real(solar_phi);
solar_theta = real(solar_theta);


%alter intensity for sunrise/set
sun_radius = 0.25*pi/180;

if solar_theta-sun_radius>horizon_elevation
    
    solar_area_coeff = 1;
    
elseif solar_theta>horizon_elevation
    
    solar_area_coeff = ((pi-acos((solar_theta-horizon_elevation)/sun_radius))/pi)+...
        ((solar_theta-horizon_elevation)*sun_radius*...
        sin(acos((solar_theta-horizon_elevation)/sun_radius))/(pi*(sun_radius^2)));
    
elseif solar_theta+sun_radius>horizon_elevation
    
    solar_area_coeff = 1-(((pi-acos((horizon_elevation-solar_theta)/sun_radius))/pi)+...
        ((horizon_elevation-solar_theta)*sun_radius*...
        sin(acos((horizon_elevation-solar_theta)/sun_radius))/(pi*(sun_radius^2))));
    
else
    
    solar_area_coeff = 0;
    
end

solar_intensity = solar_intensity*solar_area_coeff;


%check for sun and run if up

if not(solar_intensity == 0)
    
    if solar_theta<0
        
        solar_theta = 0;
        
    end
    
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
        
        %lunar albedo
        
        if and(not(view_factors(i,1)==0),not(view_factors(i,2)==0))
            
            heat(i,1) = heat(i,1)+view_factors(2,i)*components(i,5)*...
                solar_intensity*cos(solar_theta)*0.14; %lunar albedo = 0.14
            
        end
        
        
        
    end
    

else
    
    heat = zeros(size(components,1),1);

end

