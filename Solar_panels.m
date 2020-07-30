%Solar panel effectiveness model
%Utilises solar motion function from thermal model


%Input solar panel positions and sizes:
%[Azimuth, Elevation, Area]

panels = [0,0,1;45,0,1;90,0,1;135,0,1;180,0,1;-135,0,1;-90,0,1;-45,0,1];

panel_efficiency = 0.3*0.68*0.8;

sim_time = 12; %measured in Lunar days

latitude = -50; %latitude of landing site

longitude = -141.7; %longitude of landing site - can be faked to set start time of sim - has no other effect
%higher longitude = start later in the day

initial_season_angle = 135; %Defines the season at the start of the sim
%0 is northern summer
%Seasons aren't that significant unless your latitude is extreme!!

horizon_elevation = -20;  %represents the position of the local horizon in the sky
%if you are at the top of a hill, 
%this is -asin("moon radius"/"elevation + moon radius")
%if you are in a crater this is atan("crater height"/"crater radius")
%to guarantee PSR set as 90 degrees
%IMPORTANT: the program assumes you have entered your value in degrees and
%will convert to radians later. If you type a formula as above in directly,
%convert using formula horizon_elevation = 180*atan(...)/pi


%convert to radian

latitude = latitude*(pi/180);
longitude = longitude*(pi/180);
initial_season_angle = initial_season_angle*(pi/180);
horizon_elevation = horizon_elevation*(pi/180);


panels(:,1:2) = panels(:,1:2)*pi/180;


results = zeros(size(panels,1)+2,sim_time*(3600*672)/100+1);

for i = 0:672*36*sim_time
    
    results(1,i+1) = i*100/(672*3600);
    
    panel_power = solar_panel_power(panels,panel_efficiency,i*100,latitude,longitude,initial_season_angle,horizon_elevation);

    results(2:size(panel_power,1)+1,i+1) = panel_power;
    
    results(size(panels,1)+2,i+1) = sum(panel_power);
    
end

plot(results(1,:),results(size(panels,1)+2,:))

figure

hold on

for i = 1:size(panels,1)
    
    plot(results(1,:),results(i+1,:))
    
end

figure

bar(sum(results(2:size(panels,1)+1,:),2)/(672*36*sim_time))
