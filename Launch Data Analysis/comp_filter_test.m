figNum = 1;

comp_filter = complementaryFilter('HasMagnetometer', false);
%     'OrientationFormat', 'Rotation matrix');

data_range = 109354:113894; % Full launch
data_range = 109354:109954; % Launch to pre parachute
data_range = 109480:109974; % Launch through parachute

plotstuff = (109480-100):109480;

imu_in = readtable("dat_dm3.csv");
data_range = 71509:length(imu_in.('Timestamp'));
data_range = data_range(10667:23670);
data_range = data_range(232:1357);
data_range = data_range(216:end);
times = imu_in.('Timestamp')(data_range);
t_data = (times - times(1)) / 1000;
Ax_in = imu_in.('Ax')(data_range);
Ay_in = imu_in.('Ay')(data_range);
Az_in = imu_in.('Az')(data_range);
A = [Ax_in Ay_in Az_in] * 9.81;

% max(cumtrapz(cumtrapz(Ay_in * 9.81)))

tP = imu_in.('Timestamp')(plotstuff);
t_plot = (tP - tP(1)) / 1000;
tAx = imu_in.('Ax')(plotstuff);
tAy = imu_in.('Ay')(plotstuff);
tAz = imu_in.('Az')(plotstuff);

atAx = sum(tAx) / length(tAx);
atAy = sum(tAy) / length(tAy);
atAz = sum(tAz) / length(tAz);

atAxz = sqrt(atAx ^ 2 + atAz ^ 2);
% vert_ang = rad2deg(atan(atAy/atAxz));
rot_init = [90 0 0];


% plot(t_plot, [tAx tAy tAz]);
% legend('x', 'y', 'z');
% %%

Rx_in = imu_in.('Rx')(data_range);
Ry_in = imu_in.('Ry')(data_range);
Rz_in = imu_in.('Rz')(data_range);
w_data = deg2rad([Rx_in Ry_in Rz_in]);

[orientation, w_out] = comp_filter(A, w_data);
orientation_rotm = quat2rotm(orientation);

A_i = zeros(size(A));
rot_init_rotm = eul2rotm(deg2rad(rot_init), 'XYZ');


for i=1:length(t_data)
    A_i(i,:) = orientation_rotm(:,:,i) * A(i,:)';
    A_i(i,:) = rot_init_rotm * A_i(i,:)';
end

A_i(:,3) = A_i(:,3) - 9.81; % add gravity

vx_i = cumtrapz(t_data, A_i(:,1));
vy_i = cumtrapz(t_data, A_i(:,2));
vz_i = cumtrapz(t_data, A_i(:,3));
vmag_i = (vx_i.^2 + vy_i.^2 + vz_i.^2).^0.5;
V_i = [vx_i vy_i vz_i];

dx_i = cumtrapz(t_data, vx_i);
dy_i = cumtrapz(t_data, vy_i);
dz_i = cumtrapz(t_data, vz_i);
dmag_i = (dx_i.^2 + dy_i.^2 + dz_i.^2).^0.5;
D_i = [dx_i dy_i dz_i];

figure(figNum); clf; figNum = figNum + 1;
plot(A);
legend('Ax', 'Ay', 'Az');
title("Raw Acceleration");

figure(figNum); clf; figNum = figNum + 1;
plot(t_data, D_i);
legend('Dx', 'Dy', 'Dz');
title("Complementary Filter");

figure(figNum); clf; figNum = figNum + 1;
plot3(dx_i, dy_i, dz_i);
axis equal;
title("Complementary Filter");

fprintf("Max altitude: %f m\n", max(dz_i));

% these no longer apply
% Old code: 1348.50m
% New code: 1337.30m
% New code + initial angle: 1320.45m
