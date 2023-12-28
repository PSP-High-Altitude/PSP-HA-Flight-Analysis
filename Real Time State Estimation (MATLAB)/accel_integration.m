classdef  accel_integration < state_estimator
    properties
        i = 1;
        g = -9.81;
        p = 0;
    end

    methods
        function obj = accel_integration(size)
            % constructor
            obj@state_estimator(size); % call parent constructor

            disp(size);
%             obj.setup_states(size);
            obj
        end

        function obj = integrate(obj, sample)
            % y is up
            obj.times(obj.i) = double(sample.t / 1000); % convert to s
            obj.states.AccBodyY(obj.i) = (sample.ay - 1) * -1*obj.g; % convert to m/s^2 and correct 1g
            obj.states.AccDown(obj.i) = -1 * obj.states.AccBodyY(obj.i);
            if (obj.i <= 1)
                obj.states.VelDown(obj.i) = 0;
                obj.states.PosDown(obj.i) = 0;
            else
                timestep = [obj.times(obj.i-1), sample.t/1000];
                obj.states.VelDown(obj.i) = obj.states.VelDown(obj.i - 1) + trapz(timestep, [obj.states.AccDown(obj.i-1), obj.states.AccDown(obj.i)]);
                obj.states.PosDown(obj.i) = obj.states.PosDown(obj.i - 1) + trapz(timestep, [obj.states.VelDown(obj.i-1), obj.states.VelDown(obj.i)]);
            end
            obj.i = obj.i + 1;
        end

        function inc(obj, n)
            obj.p = obj.p + n;
        end
    end
end