function [stdArray] = getAbsMean(compTT, TT)
%return absolute mean
for i = 1:size(TT,1)
    stdArray(i) = mean(abs(compTT - TT(i,:)));
    
end
end