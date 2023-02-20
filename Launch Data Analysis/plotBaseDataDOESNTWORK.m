clc; clear all;

file_in = readtable("data_02.csv");
options = odeset('RelTol',1E-12,'AbsTol',1e-12);
indeces = 797:2527;
Ax_in = file_in.('Ax')(indeces);
Ay_in = file_in.('Ay')(indeces);
Az_in = file_in.('Az')(indeces);

A = [Ax_in, Ay_in, Az_in] * 9.81;
A_mag = (A(:,1) .^ 2 + A(:,2) .^ 2 + A(:,3) .^ 2) .^ .5;

t_data = (file_in.('Timestamp')(indeces)) - (file_in.('Timestamp')(indeces(1))) / 1000;

Rx = deg2rad(file_in.('Rx')(indeces));
Ry = deg2rad(file_in.('Ry')(indeces));
Rz = deg2rad(file_in.('Rz')(indeces));

temperature = file_in.('Temp')(indeces);
pressure = file_in.('Pressure')(indeces);
pressure_all = file_in.('Pressure');

w_data = [Rx, Ry, Rz];

[a_i, BN_out] = vecRotCorrect(A, w_data, t_data, [0, 90, 0]);
a_i(:,3) = a_i(:,3) + 9.81;
pitch = permute(real(-asin(BN_out(1,3,:))), [3, 1, 2])';
roll = permute(real(atan2(BN_out(2,3,:), BN_out(3,3,:))), [3, 1, 2])';
yaw = permute(real(atan2(BN_out(1,2,:), BN_out(1,1,:))), [3, 1, 2])';

vx_i = cumtrapz(t_data, a_i(:,1));
vy_i = cumtrapz(t_data, a_i(:,2));
vz_i = cumtrapz(t_data, a_i(:,3));

dx_i = cumtrapz(t_data, vx_i);
dy_i = cumtrapz(t_data, vy_i);
dz_i = cumtrapz(t_data, vz_i);

horiz_dist = (dx_i .^ 2 + dy_i .^ 2) .^ 0.5;

inclination = atan(sqrt(tan(roll) .^ 2 + tan(pitch) .^ 2));

%% Plot

figure(3);
clf;

subplot(3, 3, 1);
hold on;
plot(t_data, A);
legend('x', 'y', 'z');
title('Raw Acceleration');
hold off;

subplot(3, 3, 2);
hold on;
plot(t_data, w_data);
title("Angular Velocity");
hold off;

subplot(3, 3, 3);
hold on;
plot(t_data, [vx_i, vy_i, vz_i]);
legend('x', 'y', 'z');
title("Corrected Velocity (maybe)");
hold off;

subplot(3, 3, 4);
hold on;
plot(t_data, rad2deg(pitch));
title("Pitch")
hold off;

subplot(3, 3, 5);
hold on;
plot(t_data, rad2deg(roll));
title("Roll")
hold off;

subplot(3, 3, 6);
hold on;
plot(t_data, rad2deg(yaw));
title("Yaw")
hold off;

subplot(3, 3, 7);
hold on;
plot(t_data, [dx_i, dy_i, dz_i]);
legend('x', 'y', 'z');
title('Correct Position');
hold off;
