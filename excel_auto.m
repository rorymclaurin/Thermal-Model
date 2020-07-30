function [components,component_names,conductances,view_factors] = ...
    excel_auto(component_count,sheet_name)
%Converts imported excel data into the relevent forms for this model

component_name_range = strcat("C4:C",num2str(3+component_count));

component_data_range = strcat("D4:K",num2str(3+component_count));


component_names = readmatrix(sheet_name,'Sheet','Component Values','Range',component_name_range,'OutputType','string');

numeric_data = readmatrix(sheet_name,'Sheet','Component Values','Range',component_data_range);

components = zeros(size(numeric_data,1),7);

components(:,1:2) = numeric_data(:,1:2);

components(:,3) = numeric_data(:,3).*numeric_data(:,4);

components(:,4:5) = numeric_data(:,5:6);

components(:,6:7) = numeric_data(:,7:8)*(2*pi/360);

components(1,3) = inf;
components(2,3) = inf;



conductance_range = strcat("D3:",excel_col(3+component_count),...
    num2str(2+component_count));

conductances = readmatrix(sheet_name,'Sheet','Conductance Matrix','Range',conductance_range);


view_range = strcat("D3:",excel_col(3+component_count),...
    num2str(2+component_count));

view_factors = readmatrix(sheet_name,'Sheet','View Factor Matrix','Range',view_range);

view_factors(:,1) = view_factors(:,1)-view_factors(:,2);

end

