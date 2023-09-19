clc; close all;
data_range = 109480:109974; % Launch through parachute

imu_in = readtable("dm2_dat_04.csv");
gps_in = readtable("dm2_gps_04.csv");
times = imu_in.('Timestamp')(data_range);
t_data = (times - times(1)) / 1000;
Az_in = imu_in.('Ax')(data_range);
Ax_in = imu_in.('Ay')(data_range);
Ay_in = imu_in.('Az')(data_range);
A = ([Ax_in Ay_in Az_in] * 9.81)';

Rz_in = imu_in.('Rx')(data_range);
Rx_in = imu_in.('Ry')(data_range);
Ry_in = imu_in.('Rz')(data_range);
w_data = deg2rad([Rx_in Ry_in Rz_in])';
% w_data = rad2deg([Rx_in Ry_in Rz_in])';

qrot = eul2quat([90 0 0])';

v0 = [0;0;0];

va = v0;
vw = va;
dt = 30e-3;
vac = v0;
vv = v0;
vd = v0;

vd_all = zeros(size(A));
d_all = zeros([length(t_data),1])';
q_all = zeros([length(t_data), 4])';
eul_all = zeros([length(t_data), 3])';
w_prev = v0;
a_prev = v0;

for i=1:length(t_data)
    w = w_data(:,i)';
    a = A(:,i);
    [vac, vv, vd, qrot] = UpdatePose(a, a_prev, w*0, w_prev*0, dt, vac, vv, vd, qrot);
    w_prev = w;
    a_prev = a;
    vd_all(:,i) = vd;
    d_all(i) = norm(vd);
    q_all(:,i) = qrot';
    eul_all(:,i) = quat2eul(qrot', 'XYZ');
end

figct = 1;

figure(figct); figct = figct + 1;
plot(t_data, q_all);
legend('w', 'x', 'y', 'z');
title("Quats");

figure(figct); figct = figct + 1;
plot(t_data, vd_all);
legend('x','y','z');
title("Position");

figure(figct); figct = figct + 1;
plot(t_data, d_all);

figure(figct); figct = figct + 1;
plot(t_data, eul_all);
legend('roll','pitch','yaw');

figure(figct); fogct = figct + 1;
plot(t_data, A);