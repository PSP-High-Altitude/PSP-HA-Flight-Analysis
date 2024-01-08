classdef baro_est < state_history
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here

    properties
        i = 1;
        heights
        T
        a
        P
        rho
        h0 = 0;
    end

    methods
        function obj = baro_est(size, max_height, step)
            %UNTITLED Construct an instance of this class
            %   Detailed explanation goes here
            %   max_height - of atmosphere table to generate (m)
            %   step - atmos table step size (m)
            obj@state_history(size, "baro est"); % call parent constructor;
            obj.heights = 0:step:max_height;
            [obj.T, obj.a, obj.P, obj.rho] = atmosisa(obj.heights);
        end

        function h = atmosHeight(obj, P, T)
            %METHOD1 Summary of this method goes here
            %   P and T must be in Pa and K

            if (nargin > 2) % use temp
                % convert to Pa and K
                h = tablelookup(obj.P, obj.T, obj.heights, P, T);
            else
                h = interp1(obj.P, obj.heights, P);
            end
        end

        function obj = update(obj, sample, useTemp)
            obj.times(obj.i) = double(sample.t / 1000); % convert to s
            if (useTemp)
%                 obj.states.PosDown(obj.i) = -1 * obj.atmosHeight(sample.p * 100, sample.T + 273.15) - obj.h0;
            else
                obj.states.PosDown(obj.i) = -1 * obj.atmosHeight(sample.p * 100) - obj.h0;                
            end

            % 0 initial height
            if (obj.i == 1) 
                % this just takes the firest point, should probably use an
                % average
                obj.h0 = obj.states.PosDown(obj.i);
                obj.states.PosDown(obj.i) = 0;
            end

            % differentiate to get velocity
            if (obj.i <= 1)
                obj.states.VelDown(obj.i) = 0;
            else
                obj.states.VelDown(obj.i) = ...
                    (obj.states.PosDown(obj.i) - obj.states.PosDown(obj.i-1)) / (obj.times(obj.i) - obj.times(obj.i-1));
            end

            % increment i
            obj.i = obj.i + 1;
        end
    end
end