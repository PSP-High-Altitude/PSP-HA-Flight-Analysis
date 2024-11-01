function G_angIMU = G_angIMU(dt,q1,q2,q3,q4,q1_prev,q2_prev,q3_prev,q4_prev)
%G_angIMU
%    G_angIMU = G_angIMU(DT,Q1,Q2,Q3,Q4,Q1_PREV,Q2_PREV,Q3_PREV,Q4_PREV)

%    This function was generated by the Symbolic Math Toolbox version 9.2.
%    28-Mar-2023 18:27:42

t2 = 1.0./dt;
t3 = -q1_prev;
t4 = -q2_prev;
t5 = -q3_prev;
t6 = -q4_prev;
t7 = q1+t3;
t8 = q2+t4;
t9 = q3+t5;
t10 = q4+t6;
G_angIMU = [q1.*t2.*t10.*-2.0-q2.*t2.*t9.*2.0+q3.*t2.*t8.*2.0+q4.*t2.*t7.*2.0;q1.*t2.*t9.*2.0-q3.*t2.*t7.*2.0-q2.*t2.*t10.*2.0+q4.*t2.*t8.*2.0;q1.*t2.*t8.*-2.0+q2.*t2.*t7.*2.0-q3.*t2.*t10.*2.0+q4.*t2.*t9.*2.0];
