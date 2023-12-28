classdef state_estimator
    
    %% PROPERTIES
    
    properties (Access = private) % just for setup purposes
    end
    properties
        size;
        times =[]
        statesCalculated = [""]
        states; % table, unitialized
%         states = table(Size=[1, 21], ... % includes all possible states. Not all will be used in all estimations
%             VariableTypes=["double" "double" "double" ...
%                            "double" "double" "double" ...
%                            "double" "double" "double" ...
%                            "double" "double" "double" ...
%                            "double" "double" "double" ...
%                            "double" "double" "double" ...
%                            "double" "double" "double" ...
%                             ], ...
%             VariableNames=["PosNorth" "PosEast" "PosDown" ...
%                            "VelNorth" "VelEast" "VelDown" ...
%                            "AccNorth" "AccEast" "AccDown" ...
%                            "VelBodyX" "VelBodyY" "VelBodyZ" ...
%                            "AccBodyX" "AccBodY" "AccBodyZ" ...
%                            "PitchAngle" "YawAngle" "RollAngle" ...
%                            "PitchRate" "YawRate" "RollRate"]);
% %             VariableUnits=["m" "m" "m" "m/s" "m/s" "m/s" "m/s^2" "m/s^2" "m/s^2" ...
% %                            "m/s" "m/s" "m/s" "m/s^2" "m/s^2" "m/s^2" ...
% %                            "rad" "rad" "rad" "rad/s" "rad/s" "rad/s"]
% %                         );
    
    end
    properties (Dependent)
        PosUp % the opposite of down
        VelUp
        
    end

    %% METHODS

    methods

        function obj = state_estimator(size) % constructor
            obj = obj.setup_states(size);
            %  constructor
        end
%         function new_estimator = state_estimator(obj, samples)
%             obj.size = samples;
% %             obj.times = zeros(samples)';
% %             obj.states.PosDown(:) = zeros(samples, 1);
%         end
        
        function obj = setup_states(obj, size) % setup state table
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
                           "AccBodyX" "AccBodY" "AccBodyZ" ...
                           "PitchAngle" "YawAngle" "RollAngle" ...
                           "PitchRate" "YawRate" "RollRate"]);
%             VariableUnits=["m" "m" "m" "m/s" "m/s" "m/s" "m/s^2" "m/s^2" "m/s^2" ...
%                            "m/s" "m/s" "m/s" "m/s^2" "m/s^2" "m/s^2" ...
%                            "rad" "rad" "rad" "rad/s" "rad/s" "rad/s"]
%                         );
            disp("state table setup done")
        end
        function vec = accBodyVec(i1, i2)
            if (nargin > 1)
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
    end
end