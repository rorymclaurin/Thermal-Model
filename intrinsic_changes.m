function [components,conductances,view_factors,temperatures] = intrinsic_changes(components,conductances,view_factors,temperatures,time,eclipse_fraction,step) %#ok<INUSL>

%Can be used to implement a louvre by editing the emissivitites of
%components

%Can also be used to represent a duty cycle altering internal heat loads


%louvre (day night)

if mod(time,672*3600)<(1-eclipse_fraction)*672*3600
    
    components(3,4) = 0.9;%daytime emmisivity
    
else
    
    components(3,4) = 0.5;%night emmisivity
    
end

%Regolith Control

if time == 0
    
    conductances(51,52) = 0;
    conductances(52,51) = 0;
    
    conductances(57,60) = 0;
    conductances(60,57) = 0;
    
elseif floor((time/3600)/10)-floor(((time-step)/3600)/10)==1
    
    %10 hours assumed rover delivery interval - can change
    
    if not(conductances(51,52)==0)
        
        conductances(57,60) = 0.5; %make this the real number ED!!!
        conductances(60,57) = 0.5;
        
    end
    
    conductances(51,52) = 0.936822929;
    conductances(52,51) = 0.936822929;
    
    temperatures(60,1) = temperatures(51,1); %hot regolith goes to cooling chamber
    temperatures(51,1) = 100; %entry temperature - can change
    
end


%one way heat pipes

%RHU to Furnace Core

if time == 0
    
    conductances(27,52) = conductances(27,51)+(10000*0.01/1);

end

%RHU to WEB

%if time == 0
    
 %   conductances(52,30) = conductances(52,30)+(10000*0.01/1);

%end

%if time == 0
    
 %   conductances(52,31) = conductances(52,31)+(10000*0.01/1);

%end

%RHU to Sensor Suite

%if time == 0
    
 %   conductances(52,32) = conductances(52,32)+(10000*0.01/1);
 
%end

%if time == 0
    
 %   conductances(52,33) = conductances(52,33)+(10000*0.01/1);

%end

%RHU to Descent Suite

%if time == 0
    
 %   conductances(52,33) = conductances(52,33)+(10000*0.01/1);

%end

%if time == 0
    
 %   conductances(52,34) = conductances(52,34)+(10000*0.01/1);

%end

%RHU to Instrument Payload

%if time == 0
    
 %   conductances(52,38) = conductances(52,38)+(10000*0.01/1);

%end

%Radiator Inputs

%if time == 0
    
 %   conductances(30,3) = conductances(30,3)+(10000*0.01/1);

%end

%if time == 0
    
 %   conductances(31,3) = conductances(31,3)+(10000*0.01/1);

%end

%if time == 0
    
 %   conductances(32,3) = conductances(32,3)+(10000*0.01/1);

%end

%if time == 0
    
 %   conductances(33,3) = conductances(33,3)+(10000*0.01/1);

%end

%if time == 0
    
 %   conductances(34,3) = conductances(34,3)+(10000*0.01/1);

%end

%if time == 0
    
 %   conductances(38,3) = conductances(38,3)+(10000*0.01/1);

%end

%two way heat pipes/heat bridges

%structure north to structure south 
%first number is component number

% if time == 0
    
%conductances(4,5) = conductances(4,5)+(10000*0.01/1);

%conductances(5,4) = conductances(5,4)+(10000*0.01/1);

% end


end

