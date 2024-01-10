syms q1w q1x q1y q1z q2w q2x q2y q2z ax ay az axi ayi azi wx wy wz real
syms yaw pitch roll dt real

q1 = struct( ...
    'w',q1w, ...
    'x',q1x, ...
    'y',q1y, ...
    'z',q1z);
q2 = struct( ...
    'w',q2w, ...
    'x',q2x, ...
    'y',q2y, ...
    'z',q2z);

w = [wx;wy;wz];

qnorm = @(q) norm([q.w,q.x,q.y,q.z]);
qscale = @(q,c) struct('w', q.w*c, 'x', q.x*c, 'y', q.y*c, 'z', q.z*c);
qnormal = @(q) qscale(q, 1/qnorm(q));
qv = @(q) [q.x;q.y;q.z];
qmult = @(q1,q2) struct( ...
    'w', q1.w*q2.w - q1.x*q2.x - q1.y*q2.y - q1.z*q2.z, ...
    'x',q1.w*q2.x + q2.w*q1.x + q1.y*q1.z + q2.y*q1.z, ...
    'y',q1.w*q2.y + q2.w*q1.y - q1.x*q2.z + q2.x*q1.z, ...
    'z',q1.w*q2.z + q2.w*q1.z + q1.x*q2.y - q2.x*q1.y);
qadd = @(q1,q2) struct('w', q1.w+q2.w, 'x', q1.x+q2.x, 'y', q1.y+q2.y, 'z', q1.z+q2.z);

qconj = @(q) struct( ...
    'w',q.w, ...
    'x',-q.x, ...
    'y',-q.y, ...
    'z',-q.z);

vec2quat = @(v) struct('w',0,'x',v(1),'y',v(2),'z',v(3));

qrot = @(r,q) qmult( ...
    qmult(q, vec2quat(r)), ...
    qconj(q));



% cr = cos(roll * 0.5);
% sr = sin(roll * 0.5);
% cp = cos(pitch * 0.5);
% sp = sin(pitch * 0.5);
% cy = cos(yaw * 0.5);
% sy = sin(yaw * 0.5);

eul2quatsymsimplified = @(cr, sr, cp, sp, cy, sy) struct( ...
    'w', cr * cp * cy + sr * sp * sy, ...
    'x', sr * cp * cy - cr * sp * sy, ...
    'y', cr * sp * cy + sr * cp * sy, ...
    'z', cr * cp * sy - sr * sp * cy);
eul2quatsym = @(yaw, pitch, roll) eul2quatsymsimplified( ...
    cos(roll * 0.5), ...
    sin(roll * 0.5), ...
    cos(pitch * 0.5), ...
    sin(pitch * 0.5), ...
    cos(yaw * 0.5), ...
    sin(yaw * 0.5));
quat2eulsym = @(q) struct( ...
    'roll', atan2( ...
    2 * (q.w * q.x + q.y * q.z), ...
    1 - 2 * (q.x * q.x + q.y * q.y)), ...
    'pitch', 2*atan2( ...
    sqrt(1 + 2 * (q.w * q.y - q.x * q.z)), ...
    sqrt(1 - 2 * (q.w * q.y - q.x * q.z))) - pi/2, ...
    'yaw', atan2( ...
    2 * (q.w * q.z + q.x * q.y), ...
    1 - 2 * (q.y * q.y + q.z * q.z)));

qexp = @(q) vec2quat(exp(q.w)*(cos(norm(qv(q)))+qv(q)* ...
    sin(norm(qv(q)))/norm(qv(q))));

quatstep = @(q,w,dt) qmult(qexp(qscale(vec2quat(w),dt * 0.5)), q);

disp(quatstep(q1, w, dt).w);
disp(quatstep(q1, w, dt).x);
disp(quatstep(q1, w, dt).y);
disp(quatstep(q1, w, dt).z);

% data_range = 109480:109974; % Launch through parachute
% 
% imu_in = readtable("dm2_dat_04.csv");
% gps_in = readtable("dm2_gps_04.csv");
% times = imu_in.('Timestamp')(data_range);
% t_data = (times - times(1)) / 1000;
% Az_in = imu_in.('Ax')(data_range);
% Ax_in = imu_in.('Ay')(data_range);
% Ay_in = imu_in.('Az')(data_range);
% A = ([Ax_in Ay_in Az_in] * 9.81)';
% 
% Rz_in = imu_in.('Rx')(data_range);
% Rx_in = imu_in.('Ry')(data_range);
% Ry_in = imu_in.('Rz')(data_range);
% w_data = deg2rad([Rx_in Ry_in Rz_in])';


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
A = [Ax_in Ay_in Az_in]' * 9.81;

Rz_in = imu_in.('Rx')(data_range);
Rx_in = imu_in.('Ry')(data_range);
Ry_in = imu_in.('Rz')(data_range);
w_data = deg2rad([Rx_in Ry_in Rz_in])';

baro = imu_in.('Pressure')(data_range);

q = eul2quatsym(yaw, pitch, roll);
qsym = qadd(q,qscale(qmult(q, vec2quat(w)),0.5*dt));
qsym.x
qsym.y
qsym.z

q = eul2quatsym(pi/2,0,0);
eulangles = zeros(size(w_data));
ai = zeros(size(A));

for i=1:size(w_data,2)
%     q = qadd(q,quatstep(q,w_data(:,i),30e-3));
    q = qadd(q,qscale(qmult(q, vec2quat(w_data(:,i))),0.5*30e-3));
%     q = quatstep(q,w_data(:,i),30e-3);
    q = qnormal(q);
    euls = quat2eulsym(q);
    a_r = qrot(A(:,i),q);
    ai(:,i) = [a_r.x;a_r.y;a_r.z];
    eulangles(:,i) = [euls.yaw;euls.pitch;euls.roll];
end
close all;
figure(1);
plot(t_data, rad2deg(eulangles));
legend('yaw','pitch','roll');
grid on;
figure(2);
plot(t_data, rad2deg(w_data));
figure(3);
plot(t_data, ai);
legend('x','y','z');