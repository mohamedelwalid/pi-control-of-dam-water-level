function p = init_params()
%INIT_PARAMS Parameters recovered from the TTK4105 project report.

p.A = 10;                 % m^2
p.k = 2.5;                % outlet-flow coefficient
p.Kp = -2;                % proportional controller gain
p.Ki = -0.1;              % integral controller gain
p.h_ref = 5;              % m
p.Q_in_nominal = 0.5;     % m^3/s
p.h_initial = 5;          % m
p.u_min = 0;              % normalised actuator command
p.u_max = 1;
p.stop_time = 1000;       % s
p.dt = 0.1;               % s
p.disturbance_period = 120; % s
p.noise_std = 0.02;       % m, reconstruction assumption
p.noise_hold = 1.0;       % s, reconstruction assumption
end
