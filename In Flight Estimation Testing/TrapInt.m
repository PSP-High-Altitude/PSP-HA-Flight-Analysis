function v_out = TrapInt(vint, v, vprev, dt)

v_out = vint + (v + vprev) * dt * .5;

end

