% is roll axis = up


% clearvars
filename = "l1 data 2023-02-11.csv";
flight = readtable(filename);
% flight.Properties.VariableNames


tMin = 1880000; % ms
tMax = 1965000;

% iMin = find(uint32(flight.Timestamp) == tMin);
% iMax = find(uint32(flight.Timestamp) == tMax);
iMin = interp1(flight.Timestamp,1:length(flight.Timestamp),tMin,'nearest');
iMax = interp1(flight.Timestamp,1:length(flight.Timestamp),tMax,'nearest');

col = 2;
% for col = 2:(length(flight.Properties.VariableNames))
%     figure(col - 1)
%     clf
%     varName = flight.Properties.VariableNames(col);
%     plot(flight.Timestamp(iMin:iMax)/1000, flight{iMin:iMax, varName}, "Displayname", char(varName))
%     xlabel("time s")
%     ylabel(varName)
%     title(varName + " vs Time")
% end

%% 3 axis accel
figure(col)
clf
subplot(2,1,1)
hold on
for a = 2:4
    varName = flight.Properties.VariableNames(a);
    plot(flight.Timestamp(iMin:iMax)/1000, flight{iMin:iMax, varName}, "Displayname", char(varName))
end
hold off
xlabel("time (s)")
ylabel("accel (g)")
title("Acceleration" + " vs Time")
legend("show")
grid("on")


% figure(col + 1)
subplot(2,1,2)
hold on
for r = 5:7
    varName = flight.Properties.VariableNames(r);
    plot(flight.Timestamp(iMin:iMax)/1000, flight{iMin:iMax, varName}, "Displayname", char(varName))
end
xlabel("time (s)")
ylabel("rotation (dps)")
title("Angular velocity" + " vs Time")
legend("show")
grid("on")

%% Integration time!
tMin = 1885000; % only before deployment 
iMin = interp1(flight.Timestamp,1:length(flight.Timestamp),tMin,'nearest');

tMax = 1895000; % only before deployment 
iMax = interp1(flight.Timestamp,1:length(flight.Timestamp),tMax,'nearest');


velocity = zeros(iMax-iMin+1, 3);
position = zeros(iMax-iMin+1, 3);
vSum = [0,0,0];
xSum = [0,0,0];
g = 9.81;
for i = 1:iMax-iMin+1
    velocity(i,:) = vSum;
    position(i,:) = xSum;
    dt = (flight.Timestamp(i+iMin) - flight.Timestamp(i+iMin-1)) / 1000; % s
    vSum = vSum + [flight.Ax(i+iMin) - 1, flight.Ay(i+iMin), flight.Az(i+iMin)] * g * dt;
    xSum = xSum + vSum * dt;
end

%% Integration Plot
g_offset = [0,-1,0,0];
col = col+1;
figure(col)
clf
subplot(3,1,1)
hold on
for a = 2:4
    varName = flight.Properties.VariableNames(a);
    plot(flight.Timestamp(iMin:iMax)/1000, (flight{iMin:iMax, varName} + g_offset(a)) * g, "Displayname", char(varName))
end
hold off
xlabel("time (s)")
ylabel("accel (m/s)")
title("Acceleration" + " vs Time")
legend("show")
grid("on")

% Velocity
subplot(3,1,2)
hold on
names = ["vx", "vy", "vz"];
for c = 1:3
    varName = names(c);
    plot(flight.Timestamp(iMin:iMax)/1000, velocity(:,c), "Displayname", char(varName))
end
hold off
xlabel("time (s)")
ylabel("velocity (m/s)")
title("Velocity" + " vs Time")
legend("show")
grid("on")

% Displacement
subplot(3,1,3)
hold on
names = ["Xx", "Xy", "Xz"];
for c = 1:3
    varName = names(c);
    plot(flight.Timestamp(iMin:iMax)/1000, position(:,c), "Displayname", char(varName))
end
xlabel("time (s)")
ylabel("displacement (m)")
title("Displacement" + " vs Time")
legend("show")
grid("on")
