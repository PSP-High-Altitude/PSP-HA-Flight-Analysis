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
        phaseCutoffs;
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
            obj.phaseCutoffs = zeros(1, length(obj.phaseNames));
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
                    
                    avec = obj.accBodyVec(obj.i);
                    if (avec(obj.upAxis) > obj.BOOST_ACCEL) % movev to next phase
                        obj.phase = 2;
                        obj.phaseCutoffs(obj.phase) = obj.times(obj.i); % save phase transition time
                        % initialize accel integrator
                        obj.acc_est.times(obj.i) = obj.times(obj.i);
                        obj.acc_est.i = obj.i + 1; 
                    end

                case 2 % boost
                    obj.acc_est = obj.acc_est.integrate(sample);

                    % copy over everything excpt body acceleration
                    obj.states(obj.i, 1:12) = obj.acc_est.states(obj.i, 1:12);
                    obj.states(obj.i, 16:21) = obj.acc_est.states(obj.i, 16:21);
                    
                    avec = obj.accBodyVec(obj.i);
                    if (avec(obj.upAxis) < 0) % move to next phase
                        obj.phase = 3;
                        obj.phaseCutoffs(obj.phase) = obj.times(obj.i); % save phase transition time
                    end

                case 3 % fast
                    obj.acc_est = obj.acc_est.integrate(sample);

                    % copy over everything excpt body acceleration
                    obj.states(obj.i, 1:12) = obj.acc_est.states(obj.i, 1:12);
                    obj.states(obj.i, 16:21) = obj.acc_est.states(obj.i, 16:21);
                    
                    if (-1 * obj.states.VelDown(obj.i) > obj.FAST_SPEED) % move to next phase
                        obj.phase = 4;
                        obj.phaseCutoffs(obj.phase) = obj.times(obj.i); % save phase transition time
                    end

                case 4 % coast
                    obj.acc_est = obj.acc_est.integrate(sample);

                    % copy over everything excpt body acceleration
                    obj.states(obj.i, 1:12) = obj.acc_est.states(obj.i, 1:12);
                    obj.states(obj.i, 16:21) = obj.acc_est.states(obj.i, 16:21);
                    
                    if (-1 * obj.states.VelDown(obj.i) < obj.DROGUE_SPEED) % move to next phase
                        obj.phase = 5;
                        obj.phaseCutoffs(obj.phase) = obj.times(obj.i); % save phase transition time
                    end

                case 5 % drogue
                    % switch to baro only
                case 6 % main
            end

            obj.i = obj.i + 1; % update i
        end
    end
end