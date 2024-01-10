read_pal_data;
close all;

rocket_scale = 30;

rocket_radius = .5;
rocket_height = 10;
theta_steps = 250;
rocket_height_steps = 5;

cap_steps = 3;

cone_height = 2;
cone_height_steps = 3;

fin_height = 1;
fin_tip_height = 1;
fin_length = 1;
fin_steps = 5;

t_factor = 1;
height_ratio = 40/293; % Ratio of (board distance from top) / (total rocket height)
filename = 'dm3.gif';

% Obtained from https://gml.noaa.gov/grad/solcalc/azel.html
az = 302.04;
el = -8.53;

% Obtained from https://gml.noaa.gov/grad/solcalc/azel.html
az = 197.28;
el = 30.06;

total_height = rocket_height + cone_height;
theta = linspace(0, 2*pi, theta_steps);
height = linspace((1 - height_ratio) * rocket_height, height_ratio * rocket_height,rocket_height_steps);
bodyY = cos(theta)' * (ones(size(height))) * rocket_radius;
bodyZ = sin(theta)' * (ones(size(height))) * rocket_radius;
bodyX = (ones(size(theta)))' * height;

cap_r = linspace(0, rocket_radius, cap_steps);
capY = cos(theta)' * cap_r;
capZ = sin(theta)' * cap_r;
capX = zeros(theta_steps, cap_steps);

height = linspace(0,cone_height,cone_height_steps);
coneY = cos(theta)' * ((cone_height - height) / cone_height) * rocket_radius;
coneZ = sin(theta)' * ((cone_height - height) / cone_height) * rocket_radius;
coneX = (ones(size(theta)))' * height;

coneX = coneX + rocket_height;

heights = linspace((1 - height_ratio) * fin_height, height_ratio * fin_height, fin_steps);
tip_heights = linspace((1 - height_ratio) * fin_tip_height, height_ratio * fin_tip_height, fin_steps);
lengths = linspace(0, fin_length, fin_steps);

theta = 0;
fin1Y = (rocket_radius + ones(size(heights))' * lengths) * cos(theta);
fin1Z = (rocket_radius + ones(size(heights))' * lengths) * sin(theta);
fin1X = heights' * ones(size(lengths));
fintip1Y = (rocket_radius + tip_heights(end:-1:1)' * lengths) * cos(theta);
fintip1Z = (rocket_radius + tip_heights(end:-1:1)' * lengths) * sin(theta);
fintip1X = tip_heights' * ones(size(lengths)) + fin_height;

theta = 2*pi/3;
fin2Y = (rocket_radius + ones(size(heights))' * lengths) * cos(theta);
fin2Z = (rocket_radius + ones(size(heights))' * lengths) * sin(theta);
fin2X = heights' * ones(size(lengths));
fintip2Y = (rocket_radius + tip_heights(end:-1:1)' * lengths) * cos(theta);
fintip2Z = (rocket_radius + tip_heights(end:-1:1)' * lengths) * sin(theta);
fintip2X = tip_heights' * ones(size(lengths)) + fin_height;

theta = 4*pi/3;
fin3Y = (rocket_radius + ones(size(heights))' * lengths) * cos(theta);
fin3Z = (rocket_radius + ones(size(heights))' * lengths) * sin(theta);
fin3X = heights' * ones(size(lengths));
fintip3Y = (rocket_radius + tip_heights(end:-1:1)' * lengths) * cos(theta);
fintip3Z = (rocket_radius + tip_heights(end:-1:1)' * lengths) * sin(theta);
fintip3X = tip_heights' * ones(size(lengths)) + fin_height;

fig = figure(fig_ct);
fig_ct = fig_ct + 1;
sl_body = surf(bodyX, bodyY, bodyZ);
hold on;
sl_cone = surf(coneX, coneY, coneZ);
sl_cap = surf(capX, capY, capZ);
sl_fin1 = surf(fin1X, fin1Y, fin1Z);
sl_fin2 = surf(fin2X, fin2Y, fin2Z);
sl_fin3 = surf(fin3X, fin3Y, fin3Z);
sl_fintip1 = surf(fintip1X, fintip1Y, fintip1Z);
sl_fintip2 = surf(fintip2X, fintip2Y, fintip2Z);
sl_fintip3 = surf(fintip3X, fintip3Y, fintip3Z);
hold off;
% xlim([-rocket_height*2 2*rocket_height]);
% ylim([-rocket_height*2 2*rocket_height]);
% zlim([-rocket_height*2 2*rocket_height]);
objs = [sl_body sl_cone sl_cap sl_fin1 sl_fin2 sl_fin3 sl_fintip1 sl_fintip2 sl_fintip3];
tf = hgtransform();
set(objs, 'Parent', tf);
t_quats = quat2tform(EP_hist);

transforms = zeros(size(t_quats));

for i=1:size(t_quats,3)
    transforms(:,:,i) = makehgtform('translate', [dx_i(i) dy_i(i) -dz_i(i)]) * makehgtform('translate', [-total_height*(1-height_ratio)*rocket_scale 0 0]);
%     transforms(:,:,i) = makehgtform('translate', [0 0 0]) * makehgtform('translate', [-total_height*(1-height_ratio)*rocket_scale 0 0]);
    transforms(:,:,i) = transforms(:,:,i) * t_quats(:,:,i);
    transforms(:,:,i) = transforms(:,:,i) * makehgtform('scale', [rocket_scale rocket_scale rocket_scale]);
end


lightangle(az,el)
shading interp;
colormap gray;

axis equal;
% xlim([-total_height total_height] / 2);
% ylim([-total_height total_height] / 2);
% zlim([-total_height total_height] / 2);

% xlim([-500 100]);
% ylim([-300 300]);
% zlim([-200 400]);
axis off;

% xlabel('x');
% ylabel('y');
% zlabel('z');

% xlim([min(dx_i)-rocket_height*rocket_scale max(dx_i)+rocket_height*rocket_scale]);
% ylim([min(dy_i)-rocket_height*rocket_scale max(dy_i)+rocket_height*rocket_scale]);
% zlim([min(-dz_i)-rocket_height*rocket_scale max(-dz_i)+rocket_height*rocket_scale]);

t = [timer()];
tdiff = diff(t_data);
tdiff(end+1) = tdiff(end);
% close all;
for i=1:max(size(t_quats))
%     t(i) = timer('TimerFcn',@(~,~)animFUNC(tf, transforms(:,:,i), filename, i, tdiff(i)), 'StartDelay',0);
    t(i) = timer('TimerFcn',@(~,~)animFUNC(tf, transforms(:,:,i), filename, i, tdiff(i), 0), 'StartDelay',t_data(i)/t_factor);

end
start(t);
pause(t_data(end)/t_factor)
% pause(10*60)
delete(t);