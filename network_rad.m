function [heat] = network_rad(components,temperatures,network_list,network_matrices,network_area_inputs,network_absorptions)

%Calculates heat movement in radiation/reflection networks

%useful constants

network_count = size(network_list,1);

network_sizes = sum((network_list>0),2);


%calculate heat inputs to each network

network_heat_inputs = 0*network_area_inputs;

for current_network = 1:network_count
    
    for i = 1:network_sizes(current_network,1)
        
        network_heat_inputs(i,current_network) = network_area_inputs(i,current_network)*...
            components(network_list(current_network,i),4)*...
            (temperatures(network_list(current_network,i),1)^4)*...
            5.669*(10^-8);
        
    end
    
end

%Solve system of linear equations to create H (total heat 'shining' from each
%component)

network_solutions = 0*network_area_inputs;

for current_network = 1:network_count
    
    extracted_matrix = network_matrices(1:network_sizes(current_network,1),...
        1:network_sizes(current_network,1),current_network);
    
    network_solutions(1:network_sizes(current_network,1),current_network) = ...
        extracted_matrix\network_heat_inputs(1:network_sizes(current_network,1),current_network);
    
end

%find actual flows for each network element

heat = 0*temperatures;

network_heat_out = 0*network_area_inputs;

for current_network = 1:network_count
    
    extracted_matrix = network_absorptions(1:network_sizes(current_network,1),...
        1:network_sizes(current_network,1),current_network);
    
    network_heat_out(1:network_sizes(current_network,1),current_network) = ...
        extracted_matrix*...
        network_solutions(1:network_sizes(current_network,1),current_network);

end

%subtract for final totals (heat into component is positive now)

network_heat_totals = network_heat_out - network_heat_inputs;

%recombine per component

for current_network = 1:network_count
    
    for i = 1:network_sizes(current_network,1)
        
        heat(network_list(current_network,i),1) = ...
            heat(network_list(current_network,i),1)+...
            network_heat_totals(i,current_network);
        
    end
    

end


end

