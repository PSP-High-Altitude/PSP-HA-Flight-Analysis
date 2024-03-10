classdef quat
    %QUAT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        w
        x
        y
        z
        v
    end

    methods(Static)
        function q_out = add(q1, q2)
            q_out = quat(0, 0, 0, 0);
            q_out.w = q1.w + q2.w;
            q_out.x = q1.x + q2.x;
            q_out.y = q1.y + q2.y;
            q_out.z = q1.z + q2.z;
        end

        function q_out = sub(q1, q2)
            q_out = quat( ...
            q1.w - q2.w, ...
            q1.x - q2.x, ...
            q1.y - q2.y, ...
            q1.z - q2.z);
        end

        function q_out = scale(q, c)
            q_out = quat( ...
                q.w * c, ...
                q.x * c, ...
                q.y * c, ...
                q.z * c);
        end

        function q_out = mult(q1, q2)
            q_out = quat( ...
                q1.w*q2.w - q1.x*q2.x - q1.y*q2.y - q1.z*q2.z, ...
                q1.w*q2.x + q2.w*q1.x + q1.y*q1.z + q2.y*q1.z, ...
                q1.w*q2.y + q2.w*q1.y - q1.x*q2.z + q2.x*q1.z, ...
                q1.w*q2.z + q2.w*q1.z + q1.x*q2.y - q2.x*q1.y ...
                );
        end

        function q = from_eul(eul_vec)
            roll = eul_vec.x;
            pitch = eul_vec.y;
            yaw = eul_vec.z;
            cr = cos(roll * 0.5);
            sr = sin(roll * 0.5);
            cp = cos(pitch * 0.5);
            sp = sin(pitch * 0.5);
            cy = cos(yaw * 0.5);
            sy = sin(yaw * 0.5);

            q = quat( ...
                cr*cp*cy + sr*sp*sy, ...
                sr*cp*cy - cr*sp*sy, ...
                cr*sp*cy + sr*cp*sy, ...
                cr*cp*sy - sr*sp*cy);            
        end
    end
    
    
    methods
        function obj = quat(w, x, y, z)
            obj.w = w;
            obj.x = x;
            obj.y = y;
            obj.z = z;
            obj.v = vec(x, y, z);
        end

        
        function obj = iadd(obj, q_in)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            obj.w = obj.w + q_in.w;
            obj.x = obj.x + q_in.x;
            obj.y = obj.y + q_in.y;
            obj.z = obj.z + q_in.z;
        end
        
        function obj = isub(obj, q_in)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            obj.w = obj.w - q_in.w;
            obj.x = obj.x - q_in.x;
            obj.y = obj.y - q_in.y;
            obj.z = obj.z - q_in.z;
        end

        function obj = iscale(obj, c)
            obj.w = obj.w * c;
            obj.x = obj.x * c;
            obj.y = obj.y * c;
            obj.z = obj.z * c;
        end

        function obj = imult(obj, q)
            obj.update( ...
                obj.w*q.w - obj.x*q.x - obj.y*q.y - obj.z*q.z, ...
                obj.w*q.x + q.w*obj.x + obj.y*obj.z + q.y*obj.z, ...
                obj.w*q.y + q.w*obj.y - obj.x*q.z + q.x*obj.z, ...
                obj.w*q.z + q.w*obj.z + obj.x*q.y - q.x*obj.y ...
                );
        end

        function obj = iconj(obj)
            obj.x = -obj.x;
            obj.y = -obj.y;
            obj.z = -obj.z;
            obj.v.iscale(-1);
        end

        function mag = magnitude(obj)
            mag = sqrt(obj.w^2 + obj.x^2 + obj.y^2 + obj.z^2);
        end

        function obj = normalize(obj)
            obj.iscale(1/obj.magnitude());
        end

        function c_out = conj(obj)
            c_out = quat( ...
                obj.w, ...
                -obj.x, ...
                -obj.y, ...
                -obj.z);
        end

        function obj = update(obj, w, x, y, z)
            obj.w = w;
            obj.x = x;
            obj.y = y;
            obj.z = z;
            obj.v.update(x, y, z);
        end

        function eul_v = eul(obj)
            y1 = 2 * (obj.w * obj.z + obj.x * obj.y);
            y2 = 1 - 2 * (obj.y * obj.y + obj.z * obj.z);
            p1 = sqrt(1 + 2 * (obj.w * obj.y - obj.x * obj.z))
            p2 = sqrt(1 - 2 * (obj.w * obj.y - obj.x * obj.z))
            r1 = 2 * (obj.w * obj.x + obj.y * obj.z);
            r2 = 1 - 2 * (obj.x * obj.x + obj.y * obj.y);
            eul_v = vec( ...
                atan2(y1, y2), ...
                atan2(p1, p2) - pi/2, ...
                atan2(r1, r2) ...
                );
        end

        function obj = step(obj, w, dt)
            obj = obj.iadd(quat.scale(quat.mult(obj, w.toQuat()),.5*dt));
            obj = obj.normalize();
        end

        function q_out = copy(obj)
            q_out = quat(obj.w, obj.x, obj.y, obj.z);
        end
    end
end

