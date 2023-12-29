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
tMax = 2271e3;

% or use entire data set
% tmin = 0;
% tMax = max(flight.Timestamp);

iMin = interp1(dataStream.Timestamp,1:length(dataStream.Timestamp),tMin,'nearest');
iMax = interp1(dataStream.Timestamp,1:length(dataStream.Timestamp),tMax,'nearest');

est1 = accel_integration(iMax-iMin + 1); % accleration based estimation (pre-apo)
pal = flightAlg_v1(iMax-iMin + 1); % Full flight program
gps = readGpsStates("dm3_PAL_gpa.csv", 217); % gps state, used as reference/"true" state

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LOOP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i = iMin;
while (i <= iMax)
    % Get next data sample
    sample = PALDataSample(dataStream.Timestamp(i), ...
        [dataStream.Ax(i), dataStream.Ay(i), dataStream.Az(i)], ...
        [dataStream.Rx(i), dataStream.Ry(i), dataStream.Rz(i)], ...
        dataStream.Pressure, dataStream.Temp);
    
    % do estimations
    est1 = est1.integrate(sample); % update self, idk why its stupid
    pal = pal.update(sample);

    % increment i
    i = i + 1;
end

%% POST PROCESS / GRAPHS
est1.makegraphs(1, tMin)
pal.makegraphs(2, tMin)
gps.makegraphs(3)
state_estimator.compareGraphs(4, gps, pal, tMin)

disp("done")

