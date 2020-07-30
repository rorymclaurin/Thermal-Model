%results processing

figure

hold on

for i = 4:size(results,1)
    
    plot(results(1,:),results(i,:),'LineWidth',2)
    
    plotter = num2str(i);
    
    disp(strcat('plotted ',plotter,' components'))
    
end

component_strings = component_names;

legend(component_strings(3:size(component_strings,1)),'Location','bestoutside');

title('Temperature variation of all components');

xlabel('Time (Lunar Days)')

ylabel('Temperature (Kelvin)')

xlim([0, sim_time/672])





