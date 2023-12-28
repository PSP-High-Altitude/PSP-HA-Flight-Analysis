%{
We're going to write a program to find the apogee of a rocket based on
accelerometer and gyroscope data.
%}
% is roll axis = up

%% SETUP
% this section loads the data from a csv. It's already done for you.

clearvars % clear any existing variable in the workspace
filename = "l1 flight data 2023-02-11 trimmed.csv"; % csv containing our data
data = readtable(filename); % read slight data into a table called "data"

%{
The data from the flight is now in a table called data. Our flight computer
was oriented such that the positive x axis is pointing out the nose of the
rocket. 
%}
% These are some of the data fields you can access from the data table:
data.Timestamp; % the time that the data was taken at, in miliseconds. This does not start at zero
data.Ax; % acceleration in the x ("up") direction, in Gs. 
data.Ay; % acceleration in the y direction, in Gs. 
data.Az; % acceleration in the z direction, in Gs.
data.Rx; % rotation rate about the x (roll) axis, in dps.
data.Ry; % rotation rate about the y (pitch?) axis, in dps.
data.Rz; % rotation rate about the z (yaw?) axis, in dps.

% flight.Properties.VariableNames

%% RAW DATA PLOTTING
%{
First let's plot the data we have:
%}

figure() % create a new figure

hold on % allows adding multiple lines to one plot

% plot each axis on the same plot
plot(data.Timestamp/1000, data.Ax, DisplayName="Ax"); % plot the x values
plot(data.Timestamp/1000, data.Ay, DisplayName="Ay"); % plot the y values
plot(data.Timestamp/1000, data.Az, DisplayName="Az"); % plot the z values
hold off

% make the graph pretty
xlabel("time (s)")
ylabel("accel (g)")
title("Acceleration" + " vs Time")
legend("show")
grid("on")

%{
Note that the x acceleration starts at 1g. How would you fix this?
%}

%% Math time!
points = length(data.Timestamp); % the number of data points (rows) we have
vSum = [0,0,0];
xSum = [0,0,0];
velocity = zeros(points, 3); % this is an empty matrix for velocity
position = zeros(points, 3); % this is an empty matrix for position
g = 9.81;
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% put some math here to get velocity and position

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 3 plot figure

% set up figure
figure()

%% Acceleration plot
subplot(3,1,1) % create the graphs on one figure, and work on the first graph

% Use the code above to plot acceleration here

% plot formatting
xlabel("time (s)")
ylabel("accel (m/s)")
title("Acceleration" + " vs Time")
legend("show")
grid("on")

%% Velocity plot
subplot(3,1,2)
hold on
names = ["vx", "vy", "vz"];
for c = 1:3
    varName = names(c);
    plot(data.Timestamp / 1000, velocity(:,c), "Displayname", char(varName))
end
hold off
xlabel("time (s)")
ylabel("velocity (m/s)")
title("Velocity" + " vs Time")
legend("show")
grid("on")

%% Displacement Plot
subplot(3,1,3)
hold on
names = ["Xx", "Xy", "Xz"];
for c = 1:3
    varName = names(c);
    plot(data.Timestamp / 1000, position(:,c), "Displayname", char(varName))
end
xlabel("time (s)")
ylabel("displacement (m)")
title("Displacement" + " vs Time")
legend("show")
grid("on")

print("done")