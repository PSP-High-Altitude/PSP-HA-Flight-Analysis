% Reads acceleration and rotation data from a file, then plots the rocket's
% trajectory, position, and other values
clc; clear all;

%% Figuring out pal9000

disp("Starting Importing");

% data_range = 109354:113894; % Full launch
% data_range = 109354:109954; % Launch to pre parachute
data_range = 109480:109974; % Launch through parachute
% data_range = 109480:110074; % Launch through parachute +


options = odeset('RelTol',1E-12,'AbsTol',1e-12);

imu_in = readtable("dat_dm3.csv");
gps_in = readtable("gps_dm3.csv");
data_range = 79564:length(imu_in.('Timestamp'));
data_range = 71509:length(imu_in.('Timestamp'));
data_range = data_range(10667:23670);
data_range = data_range(232:1357);
times = imu_in.('Timestamp')(data_range);
t_data = (times - times(1)) / 1000;
Az_in = imu_in.('Ax')(data_range);
Ax_in = imu_in.('Ay')(data_range);
Ay_in = imu_in.('Az')(data_range);
A = [Ax_in Ay_in Az_in] * 9.81;

Rz_in = imu_in.('Rx')(data_range);
Rx_in = imu_in.('Ry')(data_range);
Ry_in = imu_in.('Rz')(data_range);
w_data = deg2rad([Rx_in Ry_in Rz_in]);

baro = imu_in.('Pressure')(data_range);

% figure(10); clf;
% hold on;
% plot(Ax_in);
% plot(Ay_in);
% plot(Az_in);
% legend('Ax', 'Ay', 'Az');
% hold off;
% 
% figure(11); clf;
% hold on;
% plot(t_data, Rx_in);
% plot(t_data, Ry_in);
% plot(t_data, Rz_in);
% legend('Rx', 'Ry', 'Rz');
% hold off;


disp("Finished Importing");

%% Computations

disp("Starting Processing")

% Run vector rotation correction using the input vectors, angular
% velocities, time data, and base rotation [yaw, pitch, roll]
[a_i, BN_out, EP_hist] = vecRotCorrect(A, w_data, t_data, [0, 90, 0]);

% Add gravity to the z direction
a_i(:,3) = a_i(:,3) + 9.81;

% Calculate pitch, roll, and yaw from the output of the vector correction
pitch = permute(real(-asin(BN_out(1,3,:))), [3, 1, 2])';
roll = permute(real(atan2(BN_out(2,3,:), BN_out(3,3,:))), [3, 1, 2])';
yaw = permute(real(atan2(BN_out(1,2,:), BN_out(1,1,:))), [3, 1, 2])';

% Use trapezoidal Riemann sums to calculate velocity from acceleration
vx_i = cumtrapz(t_data, a_i(:,1));
vy_i = cumtrapz(t_data, a_i(:,2));
vz_i = cumtrapz(t_data, a_i(:,3));
vmag_i = (vx_i.^2 + vy_i.^2 + vz_i.^2).^0.5;

% Use trapezoidal Riemann sums to calulate position from velocity
dx_i = cumtrapz(t_data, vx_i);
dy_i = cumtrapz(t_data, vy_i);
dz_i = cumtrapz(t_data, vz_i);
dmag_i = (dx_i.^2 + dy_i.^2 + dz_i.^2).^0.5;

% Calculate horizontal distance from launch using Pythagorean theorem
horiz_dist = (dx_i .^ 2 + dy_i .^ 2) .^ 0.5;

% Calculate inclination
inclination = atan(sqrt(tan(yaw) .^ 2 + tan(pitch) .^ 2));

disp("Finished Processing");

%% Processing/Plotting

fig_ct = 1;

% Plot rocket position in 3D
figure(fig_ct);
fig_ct = fig_ct + 1;
clf;
plot3(dx_i, dy_i, -dz_i);
hold on;
grid on;
% plot3(fdx_i, fdy_i, -fdz_i);
% legend('unsmoothed', 'smoothed');
axis equal;
xlabel('X (m)');
ylabel('Y (m)');
zlabel('Altitude (m)');
title('Rocket Trajectory');

% Clear figure for next plots
figure(fig_ct);
fig_ct = fig_ct + 1;
clf;
plot(t_data, [dx_i dy_i -dz_i]);
legend('Dx', 'Dy', 'Dz');
title('Rotation Correction Algorithm');

% Clear figure for next plots
figure(fig_ct);
fig_ct = fig_ct + 1;
clf;
plot(-dz_i, baro);
title('Altitude vs Pressure');
xlabel('Height (m)');
ylabel('Pressure (?)');

% Clear figure for next plots
figure(fig_ct);
fig_ct = fig_ct + 1;
clf;
plot(rad2deg(pitch), rad2deg(yaw));
title('Vertical Orientation');
xlabel('Pitch');
ylabel('Yaw');
axis equal;

% Clear figure for next plots
figure(fig_ct);
fig_ct = fig_ct + 1;
clf;
hold on;
plot(t_data, vx_i);
plot(t_data, vy_i);
plot(t_data, -vz_i);
title('Velocity');
xlabel('Time');
ylabel('Velocity');
legend('x', 'y', 'z');

% Clear figure for next plots
figure(fig_ct);
fig_ct = fig_ct + 1;
clf;

% Plot pitch
subplot(2, 3, 1);
hold on;
plot(t_data, rad2deg(pitch));
plot(t_data, rad2deg(roll));
plot(t_data, rad2deg(yaw));
legend('pitch','roll','yaw');
title('Rotation');
xlabel('Time (s)');
ylabel('Rotation (deg)');
hold off;

% Plot altitude (using -z due to NED coordinates)
subplot(2, 3, 2);
hold on;
plot(t_data, -dz_i);
title('Altitude');
xlabel('Time (s)');
ylabel('Distance (m)');
hold off;

% Plot horizontal distance traveled
subplot(2, 3, 3);
hold on;
plot(dx_i, dy_i);
title('Horizontal Position');
xlabel('X Distance (m)');
ylabel('Y Distance (m)');
hold off;

% Plot inclination
subplot(2, 3, 4);
hold on;
plot(t_data, 90 - rad2deg(inclination));
title('Inclination from Vertical');
xlabel('Time (s)');
ylabel('Inclination (deg)');

% Plot raw acceleration data
subplot(2, 3, 5);
hold on;
plot(t_data, A);
% plot(t_data, A_mag);
legend('x', 'y', 'z');
title('Body Acceleration');
xlabel('Time (s)');
ylabel('Acceleration (m/s^2)');
hold off;

% Plot unsmoothed corrected acceleration data in ENU coords
subplot(2, 3, 6);
hold on;
plot(t_data, [a_i(:,1) a_i(:,2) -a_i(:,3)]);
legend('x', 'y', 'z');
title('Inertial Acceleration');
xlabel('Time (s)');
ylabel('Acceleration (m/s^2)');
hold off;

% % Plot roll in 3D
% figure(fig_ct);
% fig_ct = fig_ct + 1;
% clf;
% plot3(cos(yaw), sin(yaw), dz_i);
% title("Yaw");
% hold on;
% grid on;
% xlim([-1 1]);
% ylim([-1 1]);
% % axis equal;
% hold off;

% Output max altitude, max horizontal distance, and max inclination
fprintf("-=-=-=-\n");
fprintf("Maximum altitude: %.2f m\n", max(-dz_i));
fprintf("Maximum distance from launchpad (before apogee): %.2f m\n", max(horiz_dist));
fprintf("Maximum velocity: %.2f m/s\n", max(vmag_i));
fprintf("Approximate maximum Mach value: Mach %.2f\n", max(vmag_i)/343);
fprintf("-=-=-=-\n\n");

%% Old stuff

%figure(1);
%plot(t_data, (Ax.^2 + Ay.^2 + Az.^2).^.5);
% 
% rotAngles = deg2rad([0,90,0]);
% DCM0 = eulerANGLEStoDCM([3,2,1],rotAngles);
% EP0 =  DCMtoEP(DCM0);
% [t_data,EP_hist] = ode45(@(t, x) KDE_qauternions(t, x, t_data,w_data),t_data,EP0,options);
% 
% pitch_unsmoothed = zeros(length(t_data),1);
% roll_unsmoothed = zeros(length(t_data),1);
% yaw_unsmoothed = zeros(length(t_data),1);
% acc_inertial = zeros(length(t_data),3);
% for i = 1:length(t_data)
%     BN = EPtoDCM(EP_hist(i,:));
% 
%     acc_inertial(i,:) = (BN.'*[Ax(i);Ay(i);Az(i)]).'+[0;0;9.81].';
% 
%     pitch_unsmoothed(i) = real(-asin(BN(1,3)));
%     roll_unsmoothed(i) = real(atan2(BN(2,3),BN(3,3)));
%     yaw_unsmoothed(i) = real(atan2(BN(1,2),BN(1,1)));
% end
% 
% 
% 
% figure_counter = 1
% figure(1);
% clf
% subplot(2, 3, figure_counter);
% figure_counter = figure_counter + 1;
% % clf;
% hold on;
% plot(t_data,acc_inertial);
% %plot(t_data, [Ax, Ay, Az]);
% %legend('x','y','z','Ax','Ay','Az');
% legend('x','y','z')
% hold off;
% 
% subplot(2, 3, figure_counter);
% figure_counter = figure_counter + 1;
% % clf;
% xi = cumtrapz(t_data, cumtrapz(t_data, acc_inertial(:,1)));
% yi = cumtrapz(t_data, cumtrapz(t_data, acc_inertial(:,2)));
% zi = cumtrapz(t_data, cumtrapz(t_data, acc_inertial(:,3)));
% plot3(xi, yi, zi);
% axis off;
% % xlim([-250,250]);
% % ylim([-250,250]);
% % legend('x','y','z');
% 
% figure(1);
% subplot(2, 3, figure_counter);
% figure_counter = figure_counter + 1;
% % clf;
% plot(t_data, [Ax, Ay, Az]);
% legend('Ax','Ay','Az');
% 
% subplot(2, 3, figure_counter);
% figure_counter = figure_counter + 1;
% % clf;
% plot(Ax_all);
% 
% subplot(2, 3, figure_counter);
% figure_counter = figure_counter + 1;
% % clf;
% plot(pressure_all);
% 
% subplot(2, 3, figure_counter);
% figure_counter = figure_counter + 1;
% plot(t_data, cumtrapz(t_data, cumtrapz(t_data, (Ax + 9.81))));
% 
% 
% w_data = [Rxx, Ryy, Rzz];
% [t_data,EP_hist] = ode45(@(t, x) KDE_qauternions(t, x, t_data,w_data),t_data,EP0,options);
% 
% pitch_smoothed = zeros(length(t_data),1);
% roll_smoothed = zeros(length(t_data),1);
% yaw_smoothed = zeros(length(t_data),1);
% for i = 1:length(t_data)
%     BN = EPtoDCM(EP_hist(i,:));
% 
%     pitch_smoothed(i) = real(-asin(BN(1,3)));
%     roll_smoothed(i) = real(atan2(BN(2,3),BN(3,3)));
%     yaw_smoothed(i) = real(atan2(BN(1,2),BN(1,1)));
% end
% 
% %% Plot angular velocity
% figure(5);
% clf;
% plot(t_data, w_data);
% legend('Rx','Ry','Rz');
% 
% %% Plot data
% figure(1)
% clf;
% 
% subplot(3, 1, 1);
% hold on
% plot(t_data,rad2deg(pitch_smoothed))
% plot(t_data,rad2deg(roll_smoothed))
% plot(t_data,rad2deg(yaw_smoothed))
% legend('pitch','roll','yaw');
% title('smoothed Rotation')
% hold off;
% 
% subplot(3, 1, 2);
% hold on;
% plot(t_data, rad2deg(pitch_unsmoothed))
% plot(t_data, rad2deg(roll_unsmoothed))
% plot(t_data,rad2deg(yaw_unsmoothed))
% title('Unsmoothed Rotation')
% legend('pitch', 'roll', 'yaw');
% hold off;
% 
% subplot(3, 1, 3);
% hold on;
% plot(t_data, a_mag);
% legend('Acceleration');
% title('Acceleration')
% hold off;
% 
% %% Plot smoothed vs unsmoothed
% figure(2)
% clf
% hold on
% plot(t_data, rad2deg(pitch_smoothed));
% plot(t_data, rad2deg(pitch_unsmoothed));
% title('smoothed and Unsmoothed Pitch')
% legend('smoothed', 'unsmoothed')
% 
% %% Check time differences
% figure(3)
% t_diffs = zeros(length(t_data) - 1, 1);
% for i=1:length(t_data) - 1
%     t_delta = t_data(i + 1) - t_data(i);
%     if round(t_delta, 3) ~= .010
%         fprintf("Change at %f: delta of %f\n", t_data(i), t_delta);
%     end
%     t_diffs(i) = t_data(i + 1) - t_data(i);
% end
% plot(t_diffs);
% 
% %% FFT time
% T = t_data(2);
% freq = 1 / T
% L = length(t_data);
% f = freq * (0:(L/2)) / L;
% 
% fft_in = fft(pitch_smoothed);
% P2 = abs(fft_in/L);
% P1_smoothed = P2(1:L/2+1);
% P1_smoothed(2:end-1) = 2*P1_smoothed(2:end-1);
% 
% fft_in = fft(pitch_unsmoothed);
% P2 = abs(fft_in/L);
% P1_unsmoothed = P2(1:L/2+1);
% P1_unsmoothed(2:end-1) = 2*P1_unsmoothed(2:end-1);
% 
% figure(4)
% clf
% hold on;
% plot(f, P1_smoothed,'o--')
% plot(f, P1_unsmoothed)
% title("Single-Sided Amplitude Spectrum of Data")
% legend('smoothed', 'unsmoothed')
% xlabel("f (Hz)")
% ylabel("|P1(f)|")
% hold off;
