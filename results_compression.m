%super custom results

increment = input('How many steps between data points?');

point_count = 1+floor((size(results,2)-1)/increment);

compressed_results = zeros(size(results,1),point_count);

compressed_results(:,1) = results(:,1);

for i = 1:point_count-1
    
    compressed_results(:,1+i) = results(:,1+(i*increment));
    
end


figure

hold on

for i = 4:size(compressed_results,1)
    
    plot(compressed_results(1,:),compressed_results(i,:),'LineWidth',2)
    
    plotter = num2str(i);
    
    disp(strcat('plotted ',plotter,' components'))
    
end

component_strings = component_names;

legend(component_strings(3:size(component_strings,1)),'Location','bestoutside');

title('Temperature variation of all components');

xlabel('Time (Lunar Days)')

ylabel('Temperature (Kelvin)')

xlim([0, sim_time/672])