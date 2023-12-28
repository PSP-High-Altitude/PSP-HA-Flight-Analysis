classdef PALDataSample
    properties
        % accel in body frame - g
        t % timestamp, ms
        ax
        ay
        az
        rx % dps
        ry
        rz
        p % pressure (milibar)
        T % temperature
    end
    properties (Dependent)
        avec
        rvec
    end
    methods
        function sample = PALDataSample(t, avec, rvec, p, T)
            sample.t = t;
            sample.ax = avec(1);
            sample.ay = avec(2);
            sample.az = avec(3);
            sample.rx = rvec(1);
            sample.ry = rvec(2);
            sample.rz = rvec(3);
            sample.p = p;
            sample.T = T;
        end
        function avec = get.avec(obj)
            avec = [obj.ax; obj.ay; obj.az];
        end
        function rvec = get.rvec(obj)
            rvec = [obj.rx; obj.ry; obj.rz];
        end
    end
end