%uses node data from excel to produce a transient thermal model of the
%spacecraft
%Remember to import the data from excel!


sim_time = 2; %measured in Lunar days

run_time = 120; %measured in minutes - maximum acceptable runtime

latitude = -80; %latitude of landing site

longitude = 0; %longitude of landing site - can be faked to set start time of sim - has no other effect
%higher longitude = start later in the day

initial_season_angle = 0; %Defines the season at the start of the sim
%0 is northern summer
%Seasons aren't that significant unless your latitude is extreme!!

horizon_elevation = 0; %represents the position of the local horizon in the sky
%if you are at the top of a hill, 
%this is -asin("moon radius"/"elevation + moon radius")
%if you are in a crater this is atan("crater height"/"crater radius")
%to guarantee PSR set as 90 degrees
%IMPORTANT: the program assumes you have entered your value in degrees and
%will convert to radians later. If you type a formula as above in directly,
%convert using formula horizon_elevation = 180*atan(...)/pi

%Change input angles to radians
latitude = latitude*(pi/180);
longitude = longitude*(pi/180);
initial_season_angle = initial_season_angle*(pi/180);
horizon_elevation = horizon_elevation*(pi/180);
                     



%convert imported data
[components,component_names,conductances,view_factors] = ...
    excel_auto(60,"Matlab Thermal Model Data Entry.xlsx");

temperatures = components(:,1);



%double check run

simstr = num2str(sim_time);
runstr = num2str(run_time);
eclipsestr = num2str(eclipse_fraction);
latstr = num2str(latitude);

check_message = strcat("Are you sure you want to start a run with sim time ",simstr,...
    " Lunar days, a maximum runtime of ",runstr,...
    " minutes, and an eclipse duration of ",eclipsestr,"at a latitude of ",latstr,"? (Y/N)");

confirm = input(check_message);

if confirm == "Y"
    
    sim_time = sim_time*672;
        
    tic %start the stopwatch

    %initialise the heat matrix
    heat_flow = 0*temperatures;
    

    
    time = 0;%current simulation time
    
    %first set of intrinsic changes so that timestep includes heat pipes
    %step does not yet exist - do not write changes that rely on timestep
    %during first iteration - or choose a sensible value if you must!
    [components,conductances,view_factors,temperatures] = intrinsic_changes(components,conductances,view_factors,temperatures,time,eclipse_fraction,1000);
    
    [cond_rows,cond_cols,cond_vals] = find(conductances);
    [vf_rows,vf_cols,vf_vals] = find(view_factors);      
            
    cond_compact =[cond_rows,cond_cols,cond_vals];

    vf_compact = [vf_rows,vf_cols,vf_vals];
    
    %calculate timestep (seconds)
    step = timestep(conductances,components,view_factors);

    %initialise times and steps
    step_count = 0;%number of steps completed
    clock = 0;%current run time
    run_time_s = run_time*60;%run time in seconds
    step_total = (sim_time*3600/step);%total steps to do
    
    

    results = zeros(1+size(components,1),1+floor(step_total));
    results(2:size(results,1),1) = temperatures;
    
    %solar_results = zeros(3+size(components,1),floor(step_total));
    
    %rejection_results = zeros(1+size(components,1),floor(step_total));
    
    %control_results = zeros(2+3,floor(step_total)); %change number of rows to 2+total systems tracked
    
    %control_track = zeros(size(control_results,1),1);
    control_track = zeros(5,1);



    %%%%%%%%%%%%% iteration %%%%%%%%%%%%%%%

    while and(time<sim_time*3600,clock<run_time_s)
        
        temperatures(2,1) = lunar_control(time,eclipse_fraction);

        %find heat
        
        [solar,solar_phi,solar_theta] = solar_improved(components,view_factors,time,latitude,longitude,initial_season_angle,horizon_elevation);
        [rad_gain,rad_loss] = radiative_flow(components,view_factors,temperatures,vf_compact);
        [control_heat,control_track] = control(temperatures,time,eclipse_fraction,control_track);
        
        heat_flow = step*(conductive_flow(cond_compact,temperatures)+control_heat+...
            components(:,2)+solar+(rad_gain-rad_loss)); 
        
        
        %check components column matches


        %update temps
        temperatures = temperatures + heat_flow./components(:,3);
        %check components column matches
        
        
        time = time+step;%increment simulation time 
        step_count = step_count+1;

        clock = toc;%real time elapsed

        
        results(1,1+step_count) = time;

        results(2:size(results,1),1+step_count) = temperatures;
        
        %rejection_results(1,step_count) = time;

        %rejection_results(2:size(rejection_results,1),step_count) = rad_loss;
        
        %solar_results(1,step_count) = time;
        
        %solar_results(2,step_count) = solar_phi;
        
        %solar_results(3,step_count) = solar_theta;

        %solar_results(4:size(solar_results,1),step_count) = solar;
        
        %control_results(:,step_count) = control_track;
        
        
        for i = 1:100
            
            if and(floor(time*100/(sim_time*3600))==i,...
                    not(floor((time-step)*100/(sim_time*3600))==i))
                
                percentage = num2str(1*i);
                
                disp(strcat(percentage,"% complete"))
                
            end
        end
        
        
        
        [new_components,new_conductances,new_view_factors,temperatures] = intrinsic_changes...
            (components,conductances,view_factors,temperatures,time,eclipse_fraction,step);
        
        if not(and(isequal(new_components,components),...
                and(isequal(new_conductances,conductances),isequal(new_view_factors,view_factors))))
            
            components=new_components;
            conductances=new_conductances;
            view_factors=new_view_factors;
            
            [cond_rows,cond_cols,cond_vals] = find(conductances);
            [vf_rows,vf_cols,vf_vals] = find(view_factors);
            
            
            cond_compact = ...
                [cond_rows,cond_cols,cond_vals];
            
            vf_compact = ...
                [vf_rows,vf_cols,vf_vals];
            
            %calculate timestep (seconds)
            step = timestep(conductances,components,view_factors);
            
        end
        
        
        

        




    end
    
results(1,:) = results(1,:)/(3600*672);
%solar_results(1,:) = solar_results(1,:)/(3600*672);
%rejection_results(1,:) = rejection_results(1,:)/(3600*672);
%control_results(1,:) = control_results(1,:)/(3600*672);
    
clocks = num2str(clock);
    
disp(strcat('run time was ',clocks))
    
else
    
    disp("run cancelled")
    
end


