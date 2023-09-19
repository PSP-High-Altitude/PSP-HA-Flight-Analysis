function v_out = QuatRot(v,q)
qv = q(2:4);
qw = q(1);
v_out = qv * 2 * dot(qv, v) + v * (qw * qw - dot(qv, qv)) + cross(qv, v) * 2 * qw;
end

