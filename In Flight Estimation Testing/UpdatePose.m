function [v_ac, v_v, v_d, q_rot] = UpdatePose(va, vw, dt, vac, vv, vd, qrot)

q_rot = QuatStep(qrot, vw, dt, 1);
aprev = vac;
v_ac = QuatRot(va, q_rot);
v_ac(3) = v_ac(3) + 9.81;

vprev = vv;
v_v = TrapInt(vv, v_ac, aprev, dt);
v_d = TrapInt(vd, v_v, vprev, dt);

end

