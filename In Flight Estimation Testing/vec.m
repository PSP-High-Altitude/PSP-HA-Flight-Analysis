classdef vec
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        x
        y
        z
    end

    methods(Static)
        function v_out = add(v1, v2)
            v_out = vec( ...
            v1.x + v2.x, ...
            v1.y + v2.y, ...
            v1.z + v2.z);
        end

        function v_out = sub(v1, v2)
            v_out = vec( ...
            v1.x - v2.x, ...
            v1.y - v2.y, ...
            v1.z - v2.z);
        end

        function v_out = scale(v, c)
            v_out = quat( ...
                v.x * c, ...
                v.y * c, ...
                v.z * c);
        end

        function v_out = fromQuat(q)
            v_out = vec(q.x, q.y, q.z);
        end
    end
    
    methods
        function obj = vec(x, y, z)
            %UNTITLED Construct an instance of this class
            %   Detailed explanation goes here
            obj.x = x;
            obj.y = y;
            obj.z = z;
        end
        
        function obj = iadd(obj, v_in)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            obj.x = obj.x + v_in.x;
            obj.y = obj.y + v_in.y;
            obj.z = obj.z + v_in.z;
        end
        
        function obj = isub(obj, v_in)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            obj.x = obj.x - v_in.x;
            obj.y = obj.y - v_in.y;
            obj.z = obj.z - v_in.z;
        end

        function obj = iscale(obj, c)
            obj.x = obj.x * c;
            obj.y = obj.y * c;
            obj.z = obj.z * c;
        end

        function q_out = toQuat(obj)
            q_out = quat(0, obj.x, obj.y, obj.z);
        end

        function obj = update(obj, x, y, z)
            obj.x = x;
            obj.y = y;
            obj.z = z;
        end

        function r_out = iqrot(obj, q)
            r_out = fromQuat(quat.mult(quat.mult(q,obj.toQuat), q.conj()));
        end

        function obj = qrot(obj, q)
            q_out = quat.mult(quat.mult(q,obj.toQuat), q.conj());
            obj = fromQuat(q_out);
        end
    end
end

