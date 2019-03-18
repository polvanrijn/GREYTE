function wasClicked = checkClick(x,y, rect) 
%CHECKCLICK checks if the user clicked in the specified rectangle
if x >= rect(1) && x <= rect(3) && y >= rect(2) && y<=rect(4)
    wasClicked = true;
else
    wasClicked = false;
end

end