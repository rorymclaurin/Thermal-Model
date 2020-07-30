%custom results

%input row vector of component numbers e.g
%[1,5,7,10]

%Over 7 components and colours will repeat

comp_nums = input('Enter a row of component numbers');

legend_vec = strings(size(comp_nums,2),1);

figure

hold on

for i = 1:size(comp_nums,2)
    
    plot(results(1,:),results(comp_nums(1,i)+1,:),'LineWidth',2)
    
    legend_vec(i,1) = component_names(comp_nums(1,i),1);
    
end

legend(legend_vec(:,1),'Location','bestoutside');

title('Temperature variation of selected components');

xlabel('Time (Lunar Days)')

ylabel('Temperature (Kelvin)')

xlim([0, sim_time/672])