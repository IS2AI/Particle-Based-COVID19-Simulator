function [x_thr, lambda, delta_t, n_its] = config(num_population, sim_length, max_vel, kt, ka)
mean_dst = 1/sqrt(num_population);   % Mean distance between particles
x_thr = mean_dst/kt;                 % Contact distance threshold
lambda = max_vel/ka;                 % Speed gain of particles
delta_t = x_thr/max_vel;             % Sampling time in days
n_its = ceil(sim_length/delta_t);    % Total number of iterations
end
