classdef state_history
    
    %% PROPERTIES
    
    properties (Access = private) % just for setup purposes
    end
    properties
        size;
        times =[]
        statesCalculated = [""]
        states; % table, unitialized
        name = "";
    end
    properties (Dependent)
        PosUp % the opposite of down
        VelUp
        
    end

    %% METHODS

    methods

        function obj = state_history(size, name) % constructor
            if (nargin == 1)
                obj = obj.setup_states(size);
            else
                obj = obj.setup_states(size, name);
            end
        end
%         function new_estimator = state_estimator(obj, samples)
%             obj.size = samples;
% %             obj.times = zeros(samples)';
% %             obj.states.PosDown(:) = zeros(samples, 1);
%         end
        
        function obj = setup_states(obj, size, name) % setup state table
            obj.size = size;
            obj.times = zeros(size, 1);
            obj.states = table(Size=[size, 21], ... % includes all possible states. Not all will be used in all estimations
            VariableTypes=["double" "double" "double" ...
                           "double" "double" "double" ...
                           "double" "double" "double" ...
                           "double" "double" "double" ...
                           "double" "double" "double" ...
                           "double" "double" "double" ...
                           "double" "double" "double" ...
                            ], ...
            VariableNames=["PosNorth" "PosEast" "PosDown" ...
                           "VelNorth" "VelEast" "VelDown" ...
                           "AccNorth" "AccEast" "AccDown" ...
                           "VelBodyX" "VelBodyY" "VelBodyZ" ...
                           "AccBodyX" "AccBodyY" "AccBodyZ" ...
                           "PitchAngle" "YawAngle" "RollAngle" ...
                           "PitchRate" "YawRate" "RollRate"]);
%             VariableUnits=["m" "m" "m" "m/s" "m/s" "m/s" "m/s^2" "m/s^2" "m/s^2" ...
%                            "m/s" "m/s" "m/s" "m/s^2" "m/s^2" "m/s^2" ...
%                            "rad" "rad" "rad" "rad/s" "rad/s" "rad/s"]
%                         );
            disp("state table setup done")
            if (nargin == 3)
                obj.name = name;
            end
        end
        function vec = accBodyVec(obj, i1, i2)
            if (nargin > 2)
                vec = zeros(i1-i2 + 1, 3);
                vec(:,1) = obj.states.AccBodyX(i1:i2);
                vec(:,2) = obj.states.AccBodyY(i1:i2);
                vec(:,3) = obj.states.AccBodyZ(i1:i2);
            else
                vec = [obj.states.AccBodyX(i1), obj.states.AccBodyY(i1), obj.states.AccBodyZ(i1)]; 
            end
        end
    %% Dependent Property functions
        % Convert down to up
        function up = get.PosUp(obj)
            up = -1 * obj.states.PosDown;
        end
        function up = get.VelUp(obj)
            up = -1 * obj.states.VelDown;
        end
        
%% GRAPHS

        function makegraphs(obj, varargin)
        % makegraphs Plots state of this state estimator
        %   optional args:
        %   figNum
        %   tMin (ms)

            % input parser (for optional inputs)
            p = inputParser;
            validNum = @(x) isnumeric(x) && isscalar(x) && (x >= 0); % function handle
            addOptional(p, 'figNum', 0, validNum)
            addOptional(p, 'tMin', 0, validNum)
            parse(p,varargin{:});

            figNum = p.Results.figNum;
            tMin = p.Results.tMin;

            if (figNum > 0)
                figure(figNum)
                clf
            else
                figure()
            end

            hold off
            subplot(3,1,1)
            plot(obj.times-tMin/1000, obj.states.AccBodyX, DisplayName="X")
            hold on
            plot(obj.times-tMin/1000, obj.states.AccBodyY, DisplayName="Y")
            plot(obj.times-tMin/1000, obj.states.AccBodyZ, DisplayName="Z")
            hold off
            grid; legend;
            xlabel("time (s)"); ylabel("acc y (m/s^2)");
            
            subplot(3,1,2)
            plot(obj.times-tMin/1000, obj.VelUp())
            grid
            xlabel("time (s)"); ylabel("vel up (m/s)");
            
            subplot(3,1,3)
            plot(obj.times-tMin/1000, obj.PosUp())
            grid
            xlabel("time (s)")
            ylabel("pos up (m)")
                    
        end

        function hist = hist(obj)
            %HIST creates a state history object from a child state
            %estimator. Used for comparing graphs from multiple different
            %state estimator classes.
            hist = state_history(obj.size, obj.name);
            hist.times = obj.times;
            hist.states = obj.states;
        end

    end
    methods (Static)
        function compareGraphs(varargin)
            % COMPAREGRAPHS
            % input: fig numper (opt), reference state, second state
            % Plots multiple states sets on one graph
            % first state is assumed to be reference
            % by default only plots pos and vel
            
            % input parser
            p = inputParser;
            validNum = @(x) isnumeric(x) && isscalar(x) && (x >= 0); % function handle
            validState = @(s) isa(s, 'state_history'); 
            addRequired(p, 'figNum', validNum)
            addRequired(p, 's1', validState)
            addRequired(p, 's2', validState)
            addOptional(p, 'tMin', 0, validNum)
            addOptional(p, 'tMax', -1, validNum)

            parse(p,varargin{:});

            figNum = p.Results.figNum;
            ref = p.Results.s1;
            ests = p.Results.s2; % array of one or more estimations to plot
            tMin = p.Results.tMin/1000; % convert to s
            tMax = p.Results.tMax/1000;

            if (figNum > 0)
                figure(figNum)
                clf
            else
                figure()
            end

            hold off
            
            % velocity plot
            subplot(2,1,1)
            for est = ests % plot each est
                plot(est.times-tMin, est.VelUp(), DisplayName=est.name)
                hold on;
            end

            % set limits and plot ref
            lim = xlim();
            plot(ref.times-tMin, ref.VelUp(), "--m", DisplayName="reference")
            hold off
            grid; legend;
            xlabel("time (s)"); ylabel("vel up (m/s)");
            if (tMin ~= 0) % set x limit
                if (tMax > 0)
                    xlim([tMin, tMax])
                else
                    xlim([lim(1), lim(2)])
                end
            end
            
            % altitude plot
            subplot(2,1,2)
            for est = ests % plot each est
                plot(est.times-tMin, est.PosUp(), DisplayName=est.name)
                hold on;
            end
            
            % set limits and plot ref
            lim = xlim();
            hold on;
            plot(ref.times-tMin, ref.PosUp(), "--m", DisplayName="reference")
            hold off
            grid; legend;
            xlabel("time (s)"); ylabel("pos up (m)");
            if (tMin ~= 0) % set x limit
                if (tMax > 0)
                    xlim([tMin, tMax])
                else
                    xlim([lim(1), lim(2)])
                end
            end
        end
    end
end