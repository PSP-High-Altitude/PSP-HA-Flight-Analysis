function [corrected_vecs, BN_out, EP_hist] = vecRotCorrect(vec_array_in, ang_vels_in, t_data, r_0)
%vecRotCorrect Transforms a vector to inertial coordinates given angular
%              velocity over time
% 
%   r_0 is in degrees
% 
%   both vec_array_in and ang_vels_in are of the form:
%   [x1 y1 z1
%    x2 y2 z2
%    ...
%    xn yn zn]

rotAngles = deg2rad(r_0);
DCM0 = eulerANGLEStoDCM([3,2,1], rotAngles);
EP0 =  DCMtoEP(DCM0);
options = odeset('RelTol',1E-12,'AbsTol',1e-12);
ode_func = @(t, x) KDE_qauternions(t, x, t_data, ang_vels_in);
[t_data,EP_hist] = ode45(ode_func, t_data, EP0, options);
corrected_vecs = zeros(length(t_data), 3);
BN_out = zeros(3, 3, length(t_data));

for i=1:length(t_data)
    BN = EPtoDCM(EP_hist(i,:));
    corrected_vecs(i,:) = (BN.' * vec_array_in(i,:).').';
    BN_out(:,:,i) = BN;
end
