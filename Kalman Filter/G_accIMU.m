function G_accIMU = G_accIMU(Vx,Vx_prev,Vy,Vy_prev,Vz,Vz_prev,dt,q1,q2,q3,q4)
%G_accIMU
%    G_accIMU = G_accIMU(Vx,Vx_prev,Vy,Vy_prev,Vz,Vz_prev,DT,Q1,Q2,Q3,Q4)

%    This function was generated by the Symbolic Math Toolbox version 9.2.
%    28-Mar-2023 18:27:42

t2 = q1.^2;
t3 = q2.^2;
t4 = q3.^2;
t5 = q1.*q2.*2.0;
t6 = q1.*q3.*2.0;
t7 = q1.*q4.*2.0;
t8 = q2.*q3.*2.0;
t9 = q2.*q4.*2.0;
t10 = q3.*q4.*2.0;
t11 = -Vx_prev;
t12 = -Vy_prev;
t13 = -Vz_prev;
t14 = 1.0./dt;
t15 = t2.*2.0;
t16 = t3.*2.0;
t17 = t4.*2.0;
t18 = Vx+t11;
t19 = Vy+t12;
t20 = Vz+t13;
G_accIMU = [t14.*t19.*(t5+t10)-t14.*t18.*(t16+t17-1.0)+t14.*t20.*(t6-t9);t14.*t20.*(t7+t8)-t14.*t19.*(t15+t17-1.0)+t14.*t18.*(t5-t10);t14.*t18.*(t6+t9)-t14.*t20.*(t15+t16-1.0)-t14.*t19.*(t7-t8)];
