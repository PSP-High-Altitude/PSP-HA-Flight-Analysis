clear

% States
syms x y z Vx Vy Vz q1 q2 q3 q4 Vx_prev Vy_prev Vz_prev q1_prev  q2_prev  q3_prev  q4_prev 

% Measurements
syms axb ayb azb w1 w2 w3 dt baro GPS

state = [x y z Vx Vy Vz q1 q2 q3 q4].';

%% G functions 
% Barometer
G_baro = -z;

H_baro = jacobian(G_baro,state);

% GPS
G_GPS = [x y -z Vx Vy -Vz].';
H_GPS = jacobian(G_GPS,state);

% Acceleration
axN = (Vx-Vx_prev)/dt;
axE = (Vy-Vy_prev)/dt;
axD = (Vz-Vz_prev)/dt;

a_NED = [axN;axE;axD];

BN = [1-2*q2^2-2*q3^2, 2*(q1*q2+q3*q4), 2*(q1*q3-q2*q4);
      2*(q1*q2-q3*q4), 1-2*q1^2-2*q3^2, 2*(q2*q3+q1*q4);
      2*(q1*q3+q2*q4), 2*(q2*q3-q1*q4), 1-2*q1^2-2*q2^2]; 

G_accIMU = BN*a_NED;
H_accIMU = jacobian(G_accIMU,state);

% Gryo
qdot1 = (q1-q1_prev)/dt;
qdot2 = (q2-q2_prev)/dt;
qdot3 = (q3-q3_prev)/dt;
qdot4 = (q4-q4_prev)/dt;

qdot = [qdot1;qdot2;qdot3;qdot4];
q_matrix = [q4,    q3,    -q2,   -q1;
            -q3,   q4,    q1,    -q2;
            q2,    -q1,   q4,    -q3;
            q1,    q2,    q3,    q4];

w_vec = 2*q_matrix*qdot;
G_angIMU = w_vec(1:3);
H_angIMU  = jacobian(G_angIMU,state);