function [column_letter] = excel_col(column_num)

%converts column number to alphabetical to allow referencing in Excel
%fails on column_num<=0


n = 1;

while 26^n<=column_num
    
    n = n+1;
    
end

seperate_letters = zeros(n,1);

for i = n:-1:1
    
    seperate_letters(i,1) = rem(column_num,26);
    
    column_num = (column_num - seperate_letters(i,1))/26;
    
end

if n>1
    
    for i = n:-1:2

        if seperate_letters(i,1) <= 0

            seperate_letters(i,1) = seperate_letters(i,1) + 26;

            seperate_letters(i-1,1) = seperate_letters(i-1,1) - 1;

        end

    end
    
end

if seperate_letters(1,1) == 0
    
    not_final = seperate_letters(2:size(seperate_letters,1),1);
    
else
    
    not_final = seperate_letters;
    
end

symbols = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

final = char(not_final);

for i = 1:size(not_final,1)
    final(i,1) = symbols(not_final(i,1));
end

final = string(final);
column_letter = join(final,'',1);


end

