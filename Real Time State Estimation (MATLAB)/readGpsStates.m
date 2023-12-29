function gpsStates = readGpsStates(filename, groundlevel)
%READGPSSTATES Reads data from gps csv into a state_estimator object
%   This is intended for a post-flight comparison, not "real time" use
%   For estimation use, gps needs to be added to PALDataSample
    data = readtable(filename);
    length = size(data, 1);
    gpsStates = state_estimator(length);

    % copy gps data into states
    gpsStates.times = data.Timestamp/1000;
    gpsStates.states.VelNorth = data.VelN(:);
    gpsStates.states.VelEast = data.VelE(:);
    gpsStates.states.VelDown = data.VelD(:);
    if (nargin < 2)
        gpsStates.states.PosDown = -1*data.Alt(:);
    else
        gpsStates.states.PosDown = -1*(data.Alt(:) - groundlevel);

end