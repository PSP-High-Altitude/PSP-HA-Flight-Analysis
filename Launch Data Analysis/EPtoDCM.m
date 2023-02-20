function dcm = EPtoDCM(EP)

    dcm = [1-2*EP(2)^2-2*EP(3)^2, 2*(EP(1)*EP(2)+EP(3)*EP(4)), 2*(EP(1)*EP(3)-EP(2)*EP(4));
           2*(EP(1)*EP(2)-EP(3)*EP(4)), 1-2*EP(1)^2-2*EP(3)^2,2*(EP(2)*EP(3)+EP(1)*EP(4));
           2*(EP(1)*EP(3)+EP(2)*EP(4)), 2*(EP(2)*EP(3)-EP(1)*EP(4)), 1-2*EP(1)^2-2*EP(2)^2];
end