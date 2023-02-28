function [Velocity,Position] = TrapInt(timestamp,Ax,Ay,Az)
% Integrate acceleration to velocity, then velocity to position using
% trapezoidal integration

%% Integration of Acceleration to Velocity
for i = 1:(numel(timestamp)-1)
    % x-Velocity
    areav_x(i) = ((Ax(i)+Ax(i+1))/2)*(timestamp(i+1)-timestamp(i));
    Velocity_x(i) = sum(areav_x);

    % y-Velocity
    areav_y(i) = ((Ay(i)+Ay(i+1))/2)*(timestamp(i+1)-timestamp(i));
    Velocity_y(i) = sum(areav_y);

    % z-Velocity
    areav_z(i) = ((Az(i)+Az(i+1))/2)*(timestamp(i+1)-timestamp(i));
    Velocity_z(i) = sum(areav_z);
end


%% Integration of Velocity to Position

for i = 1:(numel(timestamp)-2)
    % x-position
    areap_x(i) = ((Velocity_x(i)+Velocity_x(i+1))/2)*(timestamp(i+1)-timestamp(i));
    Position_x(i) = sum(areap_x);

    % y-position
    areap_y(i) = ((Velocity_y(i)+Velocity_y(i+1))/2)*(timestamp(i+1)-timestamp(i));
    Position_y(i) = sum(areap_y);

    % z-position
    areap_z(i) = ((Velocity_z(i)+Velocity_z(i+1))/2)*(timestamp(i+1)-timestamp(i));
    Position_z(i) = sum(areap_z);
end


Velocity = [transpose(Velocity_x), transpose(Velocity_y), transpose(Velocity_z)];

Position = [transpose(Position_x), transpose(Position_y), transpose(Position_z)];
