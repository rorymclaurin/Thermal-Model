%uses node data from excel to produce a transient thermal model of the
%spacecraft
%Remember to import the data from excel!

component_count = 20; %number of components in the excel file - used to import data

sim_time = 0.005; %length of simulation measured in Lunar days

run_time = 10; %measured in minutes - maximum acceptable runtime

spin_rate = 1; %measured in RPM
                     
%convert imported data
[components,component_names,conductances,view_factors] = ...
    excel_auto(component_count,"Matlab Thermal Model Data Entry.xlsx");

temperatures = components(:,1);

%double check run

simstr = num2str(sim_time);
runstr = num2str(run_time);

check_message = strcat("Are you sure you want to start a run with sim time ",simstr,...
    " Lunar days, a maximum runtime of ",runstr,...
    " minutes? (Y/N)");

confirm = input(check_message);

if confirm == "Y"
    
    sim_time = sim_time*672;
        
    tic %start the stopwatch

    %initialise the heat matrix
    heat_flow = 0*temperatures;
       
    time = 0;%current simulation time
    
    %first solar intensity - assume off
    solar_intensity = 0;
    
    %first set of intrinsic changes so that timestep includes heat pipes
    %step does not yet exist - do not write changes that rely on timestep
    %during first iteration - or choose a sensible value if you must!
    [components,conductances,view_factors,temperatures] = intrinsic_changes(components,conductances,view_factors,temperatures,time,1000,solar_intensity);
    
    %extract relevant data - significantly improves runtime
    [cond_rows,cond_cols,cond_vals] = find(conductances);
    [vf_rows,vf_cols,vf_vals] = find(view_factors(2:size(view_factors,1),2:size(view_factors,2)));     
            
    cond_compact =[cond_rows,cond_cols,cond_vals];

    vf_compact = [vf_rows+1,vf_cols+1,vf_vals];
    
    %Create radiation networks
    
    [network_list,network_matrices,network_area_inputs,network_absorptions] = ...
        reflectance_net(components, view_factors, vf_compact);
    
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
    
    rejection_results = zeros(2,floor(step_total));



    %%%%%%%%%%%%% iteration %%%%%%%%%%%%%%%

    while and(time<sim_time*3600,clock<run_time_s)

        %find heat
        
        [solar,solar_phi,solar_theta,solar_intensity] = solar_improved(components,view_factors,time,spin_rate);
        rad_heat = network_rad(components,temperatures,network_list,network_matrices,network_area_inputs,network_absorptions);
        control_heat = control(temperatures,time,solar_intensity);
        vacuum_heat = vacuum_loss(components,view_factors,temperatures); %this is a loss, so outputs negative values
        
        heat_flow = step*(conductive_flow(cond_compact,temperatures)+control_heat+...
            components(:,2)+solar+rad_heat+vacuum_heat); 
        
        
        %update temps
        temperatures = temperatures + heat_flow./components(:,3);
        
        
        time = time+step;%increment simulation time 
        step_count = step_count+1;

        clock = toc;%real time elapsed

        
        results(1,1+step_count) = time;

        results(2:size(results,1),1+step_count) = temperatures;
        
        rejection_results(1,step_count) = time;

        rejection_results(2,step_count) = -sum(vacuum_heat,1);
        
        %solar_results(1,step_count) = time;
        
        %solar_results(2,step_count) = solar_phi;
        
        %solar_results(3,step_count) = solar_theta;

        %solar_results(4:size(solar_results,1),step_count) = solar;
        
        
        if floor(time*100/(sim_time*3600))-floor((time-step)*100/(sim_time*3600))>0

            percentage = num2str(floor(time*100/(sim_time*3600)));

            disp(strcat(percentage,"% complete"))

        end
        
        
        
        [new_components,new_conductances,new_view_factors,temperatures] = intrinsic_changes(components,conductances,view_factors,temperatures,time,step,solar_intensity);
        
        if not(and(isequal(new_components,components),...
                and(isequal(new_conductances,conductances),isequal(new_view_factors,view_factors))))

            components=new_components;
            conductances=new_conductances;
            view_factors=new_view_factors;
            
            [cond_rows,cond_cols,cond_vals] = find(conductances);
            [vf_rows,vf_cols,vf_vals] = find(view_factors(2:size(view_factors,1),2:size(view_factors,2)));
            
            cond_compact = ...
                [cond_rows,cond_cols,cond_vals];
            
            vf_compact = ...
                [vf_rows+1,vf_cols+1,vf_vals];  % we add 1 because we trimmed a row/column off view_factors
            
            %updating rad networks
                
            [network_list,network_matrices,network_area_inputs,network_absorptions] = ...
            reflectance_net(components, view_factors, vf_compact);
                
            
            %calculate timestep (seconds)
            step = timestep(conductances,components,view_factors);
            
        end


    end
    
results(1,:) = results(1,:)/(3600*672);
%solar_results(1,:) = solar_results(1,:)/(3600*672);
rejection_results(1,:) = rejection_results(1,:)/(3600*672);
    
clocks = num2str(clock);
    
disp(strcat('run time was ',clocks))
    
else
    
    disp("run cancelled")
    
end


