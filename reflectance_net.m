function [network_list,network_matrices,network_area_inputs,network_absorptions] = reflectance_net(components, view_factors, vf_compact)

%Generates component lists and inverted matrices for each radiation
%network

network_list = zeros(size(components,1));

merged_tracker = zeros(size(components,1),1);

network_count = 0;

%run through view factors to check each one is being included

for current_vf = 1:size(vf_compact,1)
    
    %check each existing network
    
    network_tracker = 1;
    
    while network_tracker<=network_count
        
        if and(sum((network_list(network_tracker,:)==vf_compact(current_vf,1)),2)==1,...
                sum((network_list(network_tracker,:)==vf_compact(current_vf,2)),2)==1)
            
            %both components belong to the network, so their connection is
            %used and we are happy
            
            network_tracker = network_count + 2;
            
        else
            
            network_tracker = network_tracker+1;
            
        end
        
    end
    
    %now we check if we found a network, and if not create a new one
    
    if network_tracker == network_count+1
        
        network_count = network_count+1;
        
        network_list(network_count,1:2) = vf_compact(current_vf,1:2);
        
        %now we populate the new network
        
        %we have to loop through all components more than once in case
        %later additions open more 
        
        stability_check = 0; %tracks whether the network has stayed the same this iteration
        
        net_comp_count = 2; %tracks number of components in network
        
        while stability_check == 0 %if this is 1 then no more can be added
            
            stability_check = 1; %will get reset when a component is added
            
            for component_tracker = 1:size(components,1)
                
                if sum((network_list(network_count,:)==component_tracker))==1
                    
                    %component already in network, so we don't worry about
                    %it
                    
                else
                    
                    link_count = 0; %number of network components that share a vf with the one being considered
                    
                    for comparison_tracker = 1:net_comp_count %network component currently being considered
                        
                        if not(view_factors(component_tracker,network_list(network_count,comparison_tracker))==0)
                            
                            link_count = link_count+1;
                            
                        end
                        
                    end
                    
                    if link_count>1
                        
                        %if link_count is less than net_comp_count, then
                        %there is a component the new one does not 'see'
                        %this implies that the network is a merged network
                        
                        if link_count<net_comp_count
                            
                            merged_tracker(network_count,1) = 1;
                            
                        end
                        
                        net_comp_count = net_comp_count + 1;
                        
                        network_list(network_count,net_comp_count) = component_tracker;
                        
                        stability_check = 0;
                        
                    end
                    
                end

            end

        end
  
    end

end

%at this point we should have a complete list of networks
%first we trim the matrix to remove unnessecary rows and columns

network_sizes = sum((network_list>0),2);

network_max_size = max(network_sizes);

network_list = network_list(1:network_count,1:network_max_size);

merged_tracker = merged_tracker(1:network_count,1);


%This section aims to generate a matrix (representing the system of linear equations) for each network

network_matrices = zeros(network_max_size,network_max_size,network_count);

network_area_inputs = zeros(network_max_size,network_count);

network_absorptions = network_matrices;

for current_network = 1:network_count
    
    %step 1: create matrix of view factors
    
    for i = 1:network_sizes(current_network,1)-1
        
        for j = i+1:network_sizes(current_network,1)
            
            %note here the mirroring of the matrix: for most components
            %this is irrelevant by symmetry
            
            %In the case of the vacuum, element i,1 represents vf from
            %component TO vacuum (rather than anything else) so this needs
            %to go in the matrix at 1,i as heat travelling to the vacuum
            
            %This could be left unmirrored if the spreadsheet were edited
            %the other way round, but this is consistent with current code
            %in solar_improved
            
            network_matrices(i,j,current_network) = view_factors(network_list(current_network,j),...
                network_list(current_network,i));
            
            network_matrices(j,i,current_network) = view_factors(network_list(current_network,i),...
                network_list(current_network,j));
            
        end
        
    end
    
    %side step 1: create constant part of h (initial input)
    
    network_area_inputs(:,current_network) = sum(network_matrices(:,:,current_network),2);
    
    
    %step 2: scale view factors to proportions of heat recieved (column
    %wise)
    
    for j = 1:network_sizes(current_network,1)
        
        network_matrices(:,j,current_network) = network_matrices(:,j,current_network)./sum(network_matrices(:,j,current_network),1);
        
    end
     
    
    
    %step 3: multiply by reflectivities (row wise) 
    %combined with side step 2: create absorption matrices
    
    for i = 1:network_sizes(current_network,1)
        
        network_absorptions(i,:,current_network) = network_matrices(i,:,current_network).*(components(network_list(current_network,i),5));
        
        network_matrices(i,:,current_network) = network_matrices(i,:,current_network).*(1-components(network_list(current_network,i),5));
        
    end
    
    %step 4: subtract from the identity
    
    network_matrices(1:network_sizes(current_network,1),1:network_sizes(current_network,1),current_network) = ...
        eye(network_sizes(current_network,1))-...
        network_matrices(1:network_sizes(current_network,1),1:network_sizes(current_network,1),current_network);

    
end

%we print which networks are merged so that we can identify which
%components might be worth splitting or where sources of (small) error may
%be

%this is also useful for tracking how often the networks are updated

merged_network_numbers = num2str(find(merged_tracker));

if size(merged_network_numbers,1)>0

    merged_message = 'Networks ';

    for i = 1:size(merged_network_numbers,1)

        merged_message = strcat(merged_message,merged_network_numbers,', ');

    end
    
    merged_message = strcat(merged_message,'are merged networks');
    
else
    
    merged_message = 'There are no merged networks';
    
end

disp(merged_message)

end

