classdef flightAlg_v1 < state_estimator
    %FLIGHTALG_V1 First attempt at a full flight process
    %   Detailed explanation goes here

    properties (Constant)
        %% FLIGHT CONSTANTS
        phaseNames = ["Pad", "Boost", "Fast", "Coast", "Drogue", "Main", "Landed"]
        BOOST_ACCEL = 10; % m/s^2
        FAST_SPEED = 200; % m/s
        DROGUE_SPEED = 0; % m/s
        MAIN_ALT = 250; % m
        upAxis = 2; % {1, 2, 3} = {x, y, z}
    end
    properties
        phase = 1;
        i = 1;
        g = -9.81; % m/s

        gx = 0; % g
        gy = 0;
        gz = 0;

        % placeholders for state estimation algs
        acc_est;
        bar_est;

    end

    methods
        function obj = flightAlg_v1(size)
            %UNTITLED Construct an instance of this class
            %   Detailed explanation goes here
            obj@state_estimator(size); % call parent constructor

            % create an acceleration integrator (update to a better one
            % later)
            obj.acc_est = accel_integration(size);
            switch obj.upAxis
                case 1
                    obj.gx = 1;
                case 2
                    obj.gy = 1;
                case 3
                    obj.gz = 1;
            end

            %TODO: barometric estimation here
        end

        function obj = update(obj, sample)
            %METHOD1 Summary of this method goes here
            %   This is the "main" of this algorithm. Call it for every
            %   data sample in main

            %% stuff that happens every time
            
            obj.times(obj.i) = double(sample.t / 1000); % convert to s

            % acceleration
            obj.states.AccBodyX(obj.i) = (sample.ax - obj.gx) * -1*obj.g; % convert to m/s^2 and correct 1g
            obj.states.AccBodyY(obj.i) = (sample.ay - obj.gy) * -1*obj.g; % convert to m/s^2 and correct 1g
            obj.states.AccBodyZ(obj.i) = (sample.az - obj.gz) * -1*obj.g; % convert to m/s^2 and correct 1g
            % phase dependent functions
            
            switch obj.phase
                case 1 % pad
                    obj.states.VelNorth(obj.i) = 0;
                    obj.states.VelEast(obj.i) = 0;
                    obj.states.VelDown(obj.i) = 0;
                    obj.states.PosNorth(obj.i) = 0;
                    obj.states.PosEast(obj.i) = 0;
                    obj.states.PosDown(obj.i) = 0;
                    
                    avec = obj.accBodyVec();
                    if (avec(obj.upAxis) > obj.BOOST_ACCEL)
                        obj.phase = 2;
                        % obj.acc_est.i = 
                    end
                case 2 % boost
                case 3 % fast
                case 4 % coast
                case 5 % drogue
                case 6 % main
            end

            obj.i = obj.i + 1; % update i
        end
    end
end