function EKF(time,measurements,X0, P0, meas_types)

    X_hat = zeros(length(time), 10);
    X_hat(1,:) = X0.';

    P_hist = zeros(length(time), 100);
    P_hist(1,:) = reshape(P0, 100, 1);

    three_sigma = zeros(length(time), 10);
    
    
    for i = 2:length(time)
        %% Update Reference Trajectory


        dt = time(i) - time(i-1);

        %% Unpack meauserements

        %% Time Update
        STM = calcSTM(dt,w);
        X_bar = STM * X_hat(i-1,:).';
        P_prev = reshape(P_hist(i-1,:), 10, 10);
        P_bar = STM * P_prev * STM.' + Q;

        %% Calc H and G
        Y = [];
        G = [];
        H = [];
        R_array = [];

        if meas_types(1)  % IMU

            G_accIMU = G_accIMU(Vx,Vx_prev,Vy,Vy_prev,Vz,Vz_prev,dt,q1,q2,q3,q4);
            G_angIMU = G_angIMU(dt,q1,q2,q3,q4,q1_prev,q2_prev,q3_prev,q4_prev);
    
            G = [G;G_accIMU;G_angIMU];
    
            H_accIMU = H_accIMU(Vx,Vx_prev,Vy,Vy_prev,Vz,Vz_prev,dt,q1,q2,q3,q4);
            H_angIMU = H_angIMU(dt,q1,q2,q3,q4,q1_prev,q2_prev,q3_prev,q4_prev);
            
            H = [H;H_accIMU;H_angIMU];
    
            R_array = [R_array,juyg];
    
            Y = [Y;PLACEHOLDER];
        end

        if meas_types(2)  % Barometer
            G_baro = G_baro(z);
            G = [G;G_baro];

            H_baro = H_baro();
            H = [H;H_baro];

            Y = [Y;PLACEHOLDER];
        end

        if meas_tyoes(3)  % GPS
            G_GPS = G_GPS(Vx,Vy,Vz,x,y,z);
            G = [G;G_GPS];

            H_GPS = H_GPS();
            H = [H;H_GPS];

            Y = [Y;PLACEHOLDER];
        end
       
        R = diag(R_array);
        y = Y - G;

        K = P_bar * H.' * (H * P * H.' + R)^-1;

        X_hat(i,:) = (X_bar + K * (y - H * X_bar)).';

        P_i = (eye(10) - K * H) * P_bar * (eye(10) - K * H).' + K*R*K.';

        P_hist(i,:) = reshape(P_i, 100, 1);

        three_sigma(i,:) = 3*sqrt(diag(P_i));
    end
end