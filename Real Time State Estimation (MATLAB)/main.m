%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Write some important stuff here
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SETUP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clearvars
filename = "dm3_PAL_dat.csv"; % name of file here!
dataStream = readtable(filename);

% Set t
tMin = 2230e3; % ms
tMax = 2600e3;

% or use entire data set
% tmin = 0;
% tMax = max(flight.Timestamp);

iMin = interp1(dataStream.Timestamp,1:length(dataStream.Timestamp),tMin,'nearest');
iMax = interp1(dataStream.Timestamp,1:length(dataStream.Timestamp),tMax,'nearest');
samples = iMax-iMin + 1;

est1 = accel_integration(samples); % accleration based estimation (pre-apo)
pal = flightAlg_v1(samples); % Full flight program
gps = readGpsStates("dm3_PAL_gpa.csv", 217); % gps state, used as reference/"true" state
% baro1 = baro_est(samples, 15e3, 10);
baro2 = baro_est(samples, 15e3, 10);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LOOP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i = iMin;
while (i <= iMax)
    % Get next data sample
    sample = PALDataSample(dataStream.Timestamp(i), ...
        [dataStream.Ax(i), dataStream.Ay(i), dataStream.Az(i)], ...
        [dataStream.Rx(i), dataStream.Ry(i), dataStream.Rz(i)], ...
        dataStream.Pressure(i), dataStream.Temp(i));
    
    % do estimations
    est1 = est1.integrate(sample); % update self, idk why its stupid
    pal = pal.update(sample);
%     baro1 = baro1.update(sample, true); % with temp
    baro2 = baro2.update(sample, false); % without temp

    % increment i
    i = i + 1;
end

%% POST PROCESS / GRAPHS
est1.makegraphs(1, tMin)
pal.makegraphs(2, tMin)
gps.makegraphs(3)
state_estimator.compareGraphs(4, gps, pal, tMin)
% state_estimator.compareGraphs(5, gps, baro1, tMin)
state_estimator.compareGraphs(5, gps, baro2, tMin)
state_estimator.compareGraphs(6, gps, [baro2.hist(), pal.hist()], tMin)

disp("done")

