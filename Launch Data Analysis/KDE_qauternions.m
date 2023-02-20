function EPdot = KDE_qauternions(t,EP,t_data,w_data)
    w1 = interp1(t_data, w_data(:,1), t);
    w2 = interp1(t_data, w_data(:,2), t);
    w3 = interp1(t_data, w_data(:,3), t);

    EPdotMatrix = [EP(4) -EP(3) EP(2) EP(1)
                   EP(3) EP(4) -EP(1) EP(2)
                   -EP(2) EP(1) EP(4) EP(3)
                   -EP(1) -EP(2) -EP(3) EP(4)];
    EPdot = 0.5 * EPdotMatrix * [w1; w2; w3; 0];
end

