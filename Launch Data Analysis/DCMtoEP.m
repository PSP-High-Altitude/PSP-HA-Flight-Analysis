function EP = DCMtoEP(BN)
    syms e1 e2 e3 e4

    EPGuess(1) = sqrt(0.25*(1+2*BN(1,1)-trace(BN)));
    EPGuess(2) = sqrt(0.25*(1+2*BN(2,2)-trace(BN)));
    EPGuess(3) = sqrt(0.25*(1+2*BN(3,3)-trace(BN)));
    EPGuess(4) = sqrt(0.25*(1+trace(BN)));

    [~,ind] = max(abs(EPGuess));
    EPGuessMax = EPGuess(ind);

    if ind == 1
        emax = e1 == EPGuessMax; 
        eqns = [e1*e2 == (BN(1,2)+BN(2,1))/4, e3*e1 == (BN(3,1)+BN(1,3))/4, e1*e4 == (BN(2,3)-BN(3,2))/4, emax];
    elseif ind == 2
        emax = e2 == EPGuessMax; 
        eqns = [e1*e2 == (BN(1,2)+BN(2,1))/4, e2*e3 == (BN(2,3)+BN(3,2))/4, e2*e4 == (BN(3,1)-BN(1,3))/4, emax];
    elseif ind == 3
        emax = e3 == EPGuessMax; 
        eqns = [e3*e1 == (BN(3,1)+BN(1,3))/4, e3*e4 == (BN(1,2)-BN(2,1))/4, e2*e3 == (BN(2,3)+BN(3,2))/4, emax];
    elseif ind == 4
        emax = e4 == EPGuessMax; 
        eqns = [e1*e4 == (BN(2,3)-BN(3,2))/4, e2*e4 == (BN(3,1)-BN(1,3))/4, e3*e4 == (BN(1,2)-BN(2,1))/4, emax];
    end

    S = solve(eqns,[e1,e2,e3,e4]);
    
    EP = [round(double(S.e1),5,'significant'); round(double(S.e2),5,'significant'); round(double(S.e3),5,'significant'); round(double(S.e4),5,'significant')];

    if EP(4) < 0
        EP = EP * -1;
    end
end