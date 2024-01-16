%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Write some important stuff here
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SETUP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clearvars
filename = "dm3_PAL_dat.csv"; % name of file here!
gpsFilename = "dm3_PAL_gpa.csv"; % gps file
dataStream = readtable(filename);
gpsStream = readtable(gpsFilename);
% assume that data is sampled faster than gps

% Set t
tMin = 2230e3; % ms
tMax = 2600e3;

% or use entire data set
% tmin = 0;
% tMax = max(flight.Timestamp);

iMin = interp1(dataStream.Timestamp,1:length(dataStream.Timestamp),tMin,'nearest');
iMax = interp1(dataStream.Timestamp,1:length(dataStream.Timestamp),tMax,'nearest');
samples = iMax-iMin + 1;

% j = gps index
jMin = interp1(gpsStream.Timestamp,1:length(gpsStream.Timestamp),tMin,'nearest');
jMax = interp1(gpsStream.Timestamp,1:length(gpsStream.Timestamp),tMax,'nearest');

est1 = accel_est(samples); % accleration based estimation (pre-apo)
pal = flightAlg_v1(samples); % Full flight program
gps = readGpsStates("dm3_PAL_gpa.csv", 217); % gps state, used as reference/"true" state
baro2 = baro_est(samples, 15e3, 10);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LOOP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i = iMin;
j = jMin;

while (i <= iMax)
    % Get next data sample
    sample = PALDataSample(dataStream.Timestamp(i), ...
        [dataStream.Ax(i), dataStream.Ay(i), dataStream.Az(i)], ...
        [dataStream.Rx(i), dataStream.Ry(i), dataStream.Rz(i)], ...
        dataStream.Pressure(i), dataStream.Temp(i));
    if (gpsStream.Timestamp(j) >= dataStream.Timestamp(i)) % assumes that gps samples are slower than dataSamples
        gpsSamlpe = gpsDataSample(gpsStream.Timestamp(j), gpsStream.datetime(j), ...
            [gpsStream.lon(j), gpsStream.lat(j), gpsStream.alt(j)], ...
            [gpsStream.velN(j), gpsStream.velE(j), gpsStream.velD(j)], ...
            [gpsStream.accH(j), gpsStream.accV(j)], gpsStream.invalid(j));
    end
    
    % do estimations
    est1 = est1.update(sample); % update self, idk why its stupid
    pal = pal.update(sample);
    baro2 = baro2.update(sample, false); % without temp

    % increment i
    i = i + 1;
end

%% POST PROCESS / GRAPHS
est1.makegraphs(1, tMin)
pal.makegraphs(2, tMin)
% gps.makegraphs(3)
state_history.compareGraphs(4, gps, pal, tMin)
state_history.compareGraphs(5, gps, baro2, tMin)
state_history.compareGraphs(6, gps, [baro2.hist(), pal.hist()], tMin)

disp("done")

