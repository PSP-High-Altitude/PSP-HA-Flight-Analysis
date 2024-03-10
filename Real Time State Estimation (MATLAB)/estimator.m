classdef estimator
    %ESTIMATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        eul0
        q0
        state
        dt
        state_hist
    end
    
    methods
        function obj = estimator(eul0, dt, state_hist)
            obj.eul0 = eul0;
            obj.q0 = quat.from_eul(eul0);
            obj.state = rocket_state(vec.zero(), obj.q0, vec.zero, ...
                vec.zero(), vec.zero());
            obj.dt = dt;
            obj.state_hist = state_hist;
        end

        function obj = update_history(obj, i)
            obj.state_hist.states.PosNorth(i) = obj.state.d.x;
            obj.state_hist.states.PosEast(i) = obj.state.d.y;
            obj.state_hist.states.PosDown(i) = obj.state.d.z;
            obj.state_hist.states.VelNorth(i) = obj.state.v.x;
            obj.state_hist.states.VelEast(i) = obj.state.v.y;
            obj.state_hist.states.VelDown(i) = obj.state.v.z;
            obj.state_hist.states.AccNorth(i) = obj.state.a.x;
            obj.state_hist.states.AccEast(i) = obj.state.a.y;
            obj.state_hist.states.AccDown(i) = obj.state.a.z;
            obj.state_hist.states.YawAngle(i) = obj.state.yaw;
            obj.state_hist.states.PitchAngle(i) = obj.state.pitch;
            obj.state_hist.states.RollAngle(i) = obj.state.roll;
            obj.state_hist.states.YawRate(i) = obj.state.w.z;
            obj.state_hist.states.PitchRate(i) = obj.state.w.y;
            obj.state_hist.states.RollRate(i) = obj.state.w.x;
            obj.state_hist.times(i) = i;            
        end

        function obj = update_state(obj, w, a, i)
            obj.state.w = w;
            obj.state.q = obj.state.q.step(w, obj.dt);
            obj.state.a = a.qrot(obj.state.q);
            obj.state.v = obj.state.v.iadd(vec.scale(obj.state.a, obj.dt));
            obj.state.d = obj.state.d.iadd(vec.scale(obj.state.v, obj.dt));
%             obj.state.eul = obj.state.q.eul();
            obj = obj.update_history(i);
        end

        function obj = update_from_sample(obj, sample, i)
            w_vec = vec(sample.rx, sample.ry, sample.rz);
            a_vec = vec(sample.ax, sample.ay, sample.az);
            w_vec = w_vec.iscale(pi/180);
            a_vec = a_vec.iscale(9.81);
            obj = obj.update_state(w_vec, a_vec, i);
        end
    end
end

