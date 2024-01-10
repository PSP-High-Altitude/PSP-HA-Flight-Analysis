function quat = QuatStep(q,w,dt,k)
% w = rad2deg(w);
wx = w(1);
wy = w(2);
wz = w(3);
qw = q(1);
qx = q(2);
qy = q(3);
qz = q(4);
W = [0 -wx -wy -wz; wx 0 wz -wy; wy -wz 0 wx; wz wy -wx 0];
quat = [
-w(1) * q(2) - w(2) * q(3) - w(3) * q(4) + q(1)
w(1) * q(1) - w(2) * q(4) + w(3) * q(3) + q(2)
w(1) * q(4) + w(2) * q(1) - w(3) * q(2) + q(3)
-w(1) * q(3) + w(2) * q(2) + w(3) * q(1) + q(4)
] * dt / 2;
qsum = zeros(size(W));
for i=0:k
    qsum = qsum + (dt * W / 2) ^ k / factorial(k);

quat = (dt / 2) * [1 -wx -wy -wz; wx 1 wz -wy; wy -wz 1 wx; wz wy -wx 1] * q;
quat = quat / norm(quat);
end

