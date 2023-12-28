%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Write some important stuff here
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% SETUP
clearvars
filename = "dm3_PAL_dat.csv"; % name of file here!
dataStream = readtable(filename);

% Set t
tMin = 2240e3; % ms
tMax = 2269e3;

% or use entire data set
% tmin = 0;
% tMax = max(flight.Timestamp);

iMin = interp1(dataStream.Timestamp,1:length(dataStream.Timestamp),tMin,'nearest');
iMax = interp1(dataStream.Timestamp,1:length(dataStream.Timestamp),tMax,'nearest');

est1 = accel_integration(iMax-iMin);

%% LOOP
i = iMin;
while (i <= iMax)
    % Get next data sample
    sample = PALDataSample(dataStream.Timestamp(i), ...
        [dataStream.Ax(i), dataStream.Ay(i), dataStream.Az(i)], ...
        [dataStream.Rx(i), dataStream.Ry(i), dataStream.Rz(i)], ...
        dataStream.Pressure, dataStream.Temp);
    
    % do estimations
    est1 = est1.integrate(sample); % update self, idk why

    % increment i
    i = i + 1;
end

%% POST PROCESS / GRAPHS
est1.makegraphs()
% figure(1)
% hold off
% subplot(3,1,1)
% plot(est1.times-tMin/1000, est1.states.AccBodyY)
% grid
% xlabel("time (s)")
% ylabel("acc x (m/s^2)")
% 
% subplot(3,1,2)
% plot(est1.times-tMin/1000, est1.VelUp())
% grid
% xlabel("time (s)")
% ylabel("vel up (m/s)")
% 
% subplot(3,1,3)
% plot(est1.times-tMin/1000, est1.PosUp())
% grid
% xlabel("time (s)")
% ylabel("pos up (m)")
% 
disp("done")

