function [v_ac, v_v, v_d, q_rot] = UpdatePose(va, va_prev, vw, vw_prev, dt, vac, vv, vd, qrot)

q_rot = QuatStep(qrot, (vw + vw_prev) / 2, dt, 1);
aprev = vac;
v_ac = QuatRot((va + va_prev) / 2, q_rot);
v_ac(3) = v_ac(3) - 9.81;

vprev = vv;
v_v = TrapInt(vv, v_ac, aprev, dt);
v_d = TrapInt(vd, v_v, vprev, dt);

end

