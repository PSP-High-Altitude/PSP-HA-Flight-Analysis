classdef rocket_state
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        w
        q
        a
        v
        d
        eul
    end

    properties (Dependent)
        wx
        wy
        wz
        qw
        qx
        qy
        qz
        ax
        ay
        az
        vx
        vy
        vz
        dx
        dy
        dz
        yaw
        pitch
        roll
    end

    methods
        function obj = rocket_state(w, q, a, v, d)
            obj.w = w;
            obj.q = q;
            obj.d = d;
            obj.v = v;
            obj.a = a;
            obj.eul = obj.q.eul();
        end

        function wx = get.wx(obj)
            wx = obj.w.x;
        end

        function wy = get.wy(obj)
            wy = obj.w.y;
        end

        function wz = get.wz(obj)
            wz = obj.w.z;
        end

        function qw = get.qw(obj)
            qw = obj.q.w;
        end

        function qx = get.qx(obj)
            qx = obj.q.x;
        end

        function qy = get.qy(obj)
            qy = obj.q.y;
        end

        function qz = get.qz(obj)
            qz = obj.q.z;
        end

        function ax = get.ax(obj)
            ax = obj.a.x;
        end

        function ay = get.ay(obj)
            ay = obj.a.y;
        end

        function az = get.az(obj)
            az = obj.a.z;
        end

        function vx = get.vx(obj)
            vx = obj.v.x;
        end

        function vy = get.vy(obj)
            vy = obj.v.y;
        end

        function vz = get.vz(obj)
            vz = obj.v.z;
        end

        function dx = get.dx(obj)
            dx = obj.dx;
        end

        function dy = get.dy(obj)
            dy = obj.d.y;
        end

        function dz = get.dz(obj)
            dz = obj.d.z;
        end
        function yaw = get.yaw(obj)
            yaw = obj.eul.x;
        end

        function pitch = get.pitch(obj)
            pitch = obj.eul.y;
        end

        function roll = get.roll(obj)
            roll = obj.eul.z;
        end

    end
end

