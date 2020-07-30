function [heat] = conductive_flow(cond_compact,temperatures)

%calculates heat flows by conduction 

heat = zeros(size(temperatures,1),1);

for i = 1:size(cond_compact,1)
    
    a = cond_compact(i,1);
    b = cond_compact(i,2);
    
    if temperatures(a,1)>temperatures(b,1)
        
        transfer = cond_compact(i,3)*...
            (temperatures(a,1)-temperatures(b,1));

        heat(b,1) = heat(b,1) + transfer;

        heat(a,1) = heat(a,1) - transfer;
        
    end
    
end



end

