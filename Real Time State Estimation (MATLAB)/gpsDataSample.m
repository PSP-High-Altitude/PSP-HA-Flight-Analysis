classdef gpsDataSample
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here

    properties
        t % timestamp, ms
        datetime
        lon
        lat
        alt % m, ASL
        accH % horz accuracy, m
        accV % vert accuracy, m
        velN % m/s
        velE
        velD
        invalid

    end

    methods
        function obj = gpsDataSample(t, datetime, LLA, vNED, acc, invalid)
            %GPSDATASAMPLE Construct an instance of this class
            %   Detailed explanation goes here
            obj.t = t;
            obj.datetime = datetime;
            obj.lon = LLA(1);
            obj.lat = LLA(2);
            obj.alt = LLA(3);
            obj.velN = vNED(1);
            obj.velE = vNED(2);
            obj.velD = vNED(3);
            obj.accH = acc(1);
            obj.accV = acc(2);
            obj.invalid = invalid;

        end

        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end