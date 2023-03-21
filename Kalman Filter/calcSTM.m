function STM = calcSTM(dt,w)
% State NOTES:
% NED Coords, q1:3 vector, q4 constant
% [x,Vx,y,Vy,z,Vz,q1,q2,q3,q4] 

    % 1-axis STM
    STM_dyn = [1 dt;
               0  1]; % *[x;Vx];

    w_matrix = 0.5*[0,      w(3),   -w(2),  w(1);
                    -w(3),  0,      w(1),   w(2);
                    w(2),   -w(1),  0,      w(3);
                    -w(1),  -w(2),  -w(3),  0];

    STM_quat = eye(4)+dt*w_matrix;

    STM = blkdiag(STM_dyn,STM_dyn,STM_dyn,STM_quat);
end