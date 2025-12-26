function position = bin2decPosition( digit, first,last )
position=0;
sum=0;
while first<=last
  if digit(first)==1
      position = position+2.^sum;
  end
  sum=sum+1;
  first=first+1;
end

end
