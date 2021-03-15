% prepare the desktop
close all; clear; clc;

%% initialize parameters
%% initialize parameters
n_sim = 10;            % Total number of simulations
n = 337000;            % Total number of particles
n_e = 10;              % Initial number of exposed particles
sim_len = 200;         % Length of the simulation in days

mean_dst = 1/sqrt(n);               % Mean distance between particles 
init_x_thr = mean_dst/20;           % Contact distance threshold
init_v_max = 0.02;                  % Maximum allowed speed of particles
init_lambda = init_v_max/10;        % Speed gain 
delta_t = init_x_thr/init_v_max;    % Sampling time in days
num_iter = ceil(sim_len/delta_t);   % Num of iterations in the simulation

save_plt = 0;          % 0: don't save plots, 1: save plots.
plt_freq = 1000;       % frequency of visualizing plots
kdt_freq = 10;         % frequency of running the KdtTree algorithm 
load_init_states = 1;  % 1: Load initial positions x, velocities v, and indicies of exposed particles ind_exposed
                       % 0: generate random initial positions x, velocities v, and indicies of exposed particles ind_exposed

t_inf = 14;                 % Infection time in days
t_exp = 5;                  % Exposure time in days

sir = 0.02;                 % Daily rate of Infected to Severe Infected Transition
gamma_mor = 0.15;           % Ratio of Severe Infected who die. The rest transition to the Recovered state.

tracking_rate = 0;          % Percentage of population using tracking app
testing_rate = 5e-4;        % Daily tests per thousand people
test_sn = 0.95;             % Test sensitivity
test_sp = 0.99;             % Test specificity

eps_exp = 0.7;      % Disease transmission rate of exposed compared to the infected
eps_qua = 0.3;      % Disease transmission rate of quarantined compared to the infected
eps_sev = 0.3;      % Disease transmission rate of severe infected compared to the infected

% to store results of n simulations
tot_sus_n = zeros(num_iter, n_sim);
tot_exp_n = zeros(num_iter, n_sim);
tot_inf_n = zeros(num_iter, n_sim);
tot_rec_n = zeros(num_iter, n_sim);
tot_dead_n = zeros(num_iter, n_sim);
tot_qua_t_n = zeros(num_iter, n_sim);
tot_qua_f_n = zeros(num_iter, n_sim);
tot_qua_n = zeros(num_iter, n_sim);
tot_iso_t_n = zeros(num_iter, n_sim);
tot_iso_f_n = zeros(num_iter, n_sim);
tot_iso_n = zeros(num_iter, n_sim);
tot_sev_inf_n = zeros(num_iter, n_sim);
tot_cases_n = zeros(num_iter, n_sim);

% load actual data for Lecco
load('actual_data.mat');
lombardy_region_population = 10078012;
tot_cases_act = actual_data.total_cases;
act_date = actual_data.date;
tot_dead_act = ceil(actual_data.lombardy_death * n/ lombardy_region_population);

%% loop over the number of simulations
for num_sim = 1:n_sim
    x_thr = init_x_thr;                % Initial contact distance threshold
    v_max = init_v_max;                % Initial maximum speed of particles
    lambda = init_lambda;              % Initial speed gain
    
    % load initial x and v
    if load_init_states == 1
        load('initialization/x.mat')
        load('initialization/v.mat')
    % otherwise initialize randomly
    else
        x = 2 * (rand(n, 2) - 0.5);       % Random initial positions
        v = v_max * (rand(n, 2) - 0.5);   % Random initial velocities
    end
    e = int8(zeros(n, 1));                % Epidemic status:
                                          % 0 -> Susceptible, 1 -> Exposed, 2 -> Infected, 3 -> Recovered,
                                          % 4 -> Dead, 5 -> True Quarantined, 6 -> True Isolated, 7 -> Severe Infected
                                          % 8 -> False Quarantined, 9 -> False Isolated,
    
    app = rand(n, 1) < tracking_rate;     % Randomly install tracking app to the population
    ts = zeros(n, 1);                     % COVID-19 test results
    contactCell = cell(n, 2);             % Cell array to store the contacts,
                                          % 1st column for indexes of particles, 2nd column for dates
    
    % vectors to store states
    tot_sus = zeros(num_iter, 1);
    tot_exp = zeros(num_iter, 1);
    tot_inf = zeros(num_iter, 1);
    tot_rec = zeros(num_iter, 1);
    tot_dead = zeros(num_iter, 1);
    tot_qua_t = zeros(num_iter, 1);
    tot_qua_f = zeros(num_iter, 1);
    tot_qua = zeros(num_iter, 1);
    tot_iso = zeros(num_iter, 1);
    tot_iso_t = zeros(num_iter, 1);
    tot_iso_f = zeros(num_iter, 1);
    tot_sev_inf = zeros(num_iter, 1);
    tot_cases = zeros(num_iter, 1);
    
    % vectors to store indices
    ind_sus = zeros(n, 1);
    ind_inf = zeros(n, 1);
    ind_rec = zeros(n, 1);
    ind_dead = zeros(n, 1);
    ind_qua_t = zeros(n, 1);
    ind_qua_f = zeros(n, 1);
    ind_iso_t = zeros(n, 1);
    ind_iso_f = zeros(n, 1);
    ind_sev_inf = zeros(n, 1);
    
    % load indices of exposed particles
    if load_init_states == 1
        load('initialization/ind_exp.mat')
    % otherwise choose randomly
    else
        ind_exp = randi([1 n], 1 , n_e);
    end
    e(ind_exp) = 1;
    
    % epidemic time state
    t = zeros(n,1);

    % start the simulation
    tic
    for ind = 1:num_iter
        % extract indices for each state
        ind_sus = (e == 0);
        ind_exp = (e == 1);
        ind_inf = (e == 2);
        ind_rec = (e == 3);
        ind_dead = (e == 4);
        ind_qua_t = (e == 5);
        ind_iso_t = (e == 6);
        ind_sev_inf = (e == 7);
        ind_iso_f = (e == 8);
        ind_qua_f = (e == 9);
        
        % extract the total number of particles in each state
        tot_sus(ind) = sum(ind_sus);
        tot_exp(ind) = sum(ind_exp);
        tot_inf(ind) = sum(ind_inf);
        tot_rec(ind) = sum(ind_rec);
        tot_dead(ind) = sum(ind_dead);
        tot_qua_t(ind) = sum(ind_qua_t);
        tot_qua_f(ind) = sum(ind_qua_f);
        tot_qua(ind) = tot_qua_t(ind) + tot_qua_f(ind);
        tot_iso_t(ind) = sum(ind_iso_t);
        tot_iso_f(ind) = sum(ind_iso_f);
        tot_iso(ind) = tot_iso_t(ind) + tot_iso_f(ind);
        tot_sev_inf(ind) = sum(ind_sev_inf);
        tot_cases(ind) = tot_inf(ind) + tot_rec(ind) + tot_dead(ind) + tot_iso(ind) + tot_qua(ind) + tot_sev_inf(ind);
        
        % calculate the current simulation time in days
        day = ind * delta_t;
        
        % change the max speed and alpha according 
        % to the epidemic timeline
        if day >= 55 && day < 71
            v_max = init_v_max * 0.6;
            lambda = v_max/10;
        elseif day >= 71 && day < 82
            v_max = init_v_max * 0.3;
            lambda = v_max/10;
        elseif day >= 82 && day < 122
            v_max = init_v_max * 0.2;
            lambda = v_max/10;
        elseif day >= 122 && day < 154
            v_max = init_v_max * 0.1;
            lambda = v_max/10;
        elseif day >= 154
            v_max = init_v_max;
            lambda = init_lambda;
            x_thr = init_x_thr * 0.8;    
        end
                        
        % plot the current states
        if mod(ind, plt_freq) == 0
            close all;
            plot_current_states_lecco(delta_t, ind, tot_exp, tot_inf, tot_rec, tot_dead, ...
                tot_qua_t, tot_iso_t, tot_sev_inf, tot_cases, tot_cases_act, tot_dead_act, act_date, save_plt)
            
            plot_map(ind, tot_exp, ind_exp, tot_inf, ind_inf, tot_rec, ind_rec, tot_dead, ind_dead,...
                tot_qua_t, ind_qua_t, tot_iso_t, ind_iso_t, tot_sev_inf, ind_sev_inf, ...
                tot_sus, ind_sus, x, save_plt)
            
            pause(0.01)
        end
        
        % change the velocities randomly
        if mod(ind, kdt_freq * 2) == 0 || ind == 1
            v = v + lambda * (rand(n, 2) - 0.5);
        end
        
        % If max speed is reached, stop to allow direction change.
        v(v > v_max) = 0;
        v(v < -v_max) = 0;
        % Dead, quarantined, isolated, severe infected (in hospital) don't move
        v(ind_dead | ind_qua_t | ind_qua_f | ind_iso_t | ind_iso_f | ind_sev_inf, :) = 0;
        
        % update positions based on the new velocities
        x = x + v * delta_t;  
        
        % Teleportation to contain the particles within the boundaries
        x(x > 1) = -1;
        x(x < -1) = 1;
        
        t = t + delta_t;   % Increment the state timer
        
        % Computationally efficient distance computation
        temp = rand(n,1);
        temp_ind = (ind_inf | ind_exp.*(temp < eps_exp) | ...
                    ind_qua_t.*(temp < eps_qua) | ...
                    ind_iso_t.*(temp < eps_qua) | ...
                    ind_sev_inf.*(temp < eps_sev));
        
        if mod(ind, kdt_freq) == 0 || ind == 1
            ns = createns(x, 'nsmethod', 'kdtree', 'distance', 'cityblock');
        end
        [ind_contacts, dst] = rangesearch(ns, x(temp_ind,:), x_thr);
        
        % Storing the contacts of susceptible, exposed, infected and severe infected
        % individuals (who also have app installed) in contactCell
        for i = 1:numel(ind_contacts)
            % index of the current contact
            if isempty(ind_contacts{i})
                continue
            end
            curr_ind = ind_contacts{i}(1);
            % Dead, quarantined, isolated and recovered don't contact
            if app(curr_ind) == 1 && (e(curr_ind) == 0 || e(curr_ind) == 1 || e(curr_ind) == 2 || e(curr_ind) == 7)
                % loop starting from the second element
                % because the first is curr_ind element
                for j = 2:numel(ind_contacts{i})
                    m = numel(contactCell{curr_ind});
                    cont_ind = ind_contacts{i}(j);
                    if app(cont_ind) == 1 && (e(cont_ind) == 0 || e(cont_ind) == 1 || e(cont_ind) == 2 || e(cont_ind) == 7)
                        contactCell{curr_ind, 1}(m + 1) = cont_ind;        % Particle ID
                        contactCell{curr_ind, 2}(m + 1) = ind * delta_t;   % Date
                    end
                end
            end
        end
        
        % Finding the contacted particles
        ind_contacts = [ind_contacts{:}];
        temp = zeros(n,1);
        temp(ind_contacts) = 1;
        ind_contacts = temp & ind_sus;
        
        % Susceptible to Exposed transition
        e(ind_contacts) = 1;    % Change their epidemic status to Exposed = 1
        t(ind_contacts) = 0;    % Reset state timer
                
        % Trace contacts of the positive tested particles
        ind_recent_inf = (ts >= (ind - 1));
        for i = 1:numel(ind_recent_inf)
            % if the recently infected particle has installed app
            if ind_recent_inf(i) == 1 && app(i) == 1
                % get the number of contacts of the particle
                m = numel(contactCell{i,1});
                for j = 1:m
                    % if they were in contact within the last 14 days
                    if (contactCell{i,2}(j) >= (ind * delta_t - t_inf))
                        % if the contacted particle is susceptible
                        % then it is a contact of false positive tested particle
                        % quarantine it and reset the time
                        if e(contactCell{i,1}(j)) == 0
                            e(contactCell{i,1}(j)) = 9;
                            t(contactCell{i,1}(j)) = 0;
                        % else if it is exposed then quarantine it
                        % without changing the time
                        elseif e(contactCell{i,1}(j)) == 1
                            e(contactCell{i,1}(j)) = 5;
                        % else if it is infected then isolate
                        elseif e(contactCell{i,1}(j)) == 2
                            e(contactCell{i,1}(j)) = 6;
                        end
                    end
                end
            end
        end
                
        % Exposed to Infected Transition
        ind_end_exposed = ((t >= t_exp) & (e == 1));
        e(ind_end_exposed) = 2;
        t(ind_end_exposed) = 0;
        
        % True Quarantined to True Isolated Transition
        ind_end_quarantined = ((t >= t_exp) & (e == 5));
        e(ind_end_quarantined) = 6;
        t(ind_end_quarantined) = 0;
        
        % False Quarantined to Susceptible Transition
        ind_end_quarantined = ((t >= t_exp) & (e == 9));
        e(ind_end_quarantined) = 0;
        t(ind_end_quarantined) = 0;
        
        % Infected to Recovered Transition
        ind_end_infection = ((t >= t_inf) & (e == 2));
        e(ind_end_infection) = 3;  % Recovered
        
        % Infected to Severe Infected Transition
        temp = rand(n,1);
        ts(e == 2 & (temp < sir * delta_t)) = ind; % COVID-19 Positive Tested --> Store the positive test date
        e(e == 2 & (temp < sir * delta_t)) = 7;
        
        % False Isolated to Susceptible Transition
        ind_end_isolation = ((t >= t_inf) & (e == 8));
        e(ind_end_isolation) = 0;
        t(ind_end_isolation) = 0;
        
        % True Isolated to Recovered Transition
        ind_end_isolation = ((t >= t_inf) & (e == 6));
        e(ind_end_isolation) = 3;
        
        % True Isolated to Severe Infected Transition
        temp = rand(n, 1);
        e(e == 6 & (temp < sir * delta_t)) = 7;
                        
        % Random test for COVID-19 taking into account the
        % test sensitivity and specificity
        temp = rand(n,1);
        ts(ts == 0 & (e == 1 | e == 2) & (temp < testing_rate * test_sn * delta_t)) = ind;  % true positive tests
        ts(ts == 0 & e == 0 & (temp < testing_rate * (1 - test_sp) * delta_t)) = ind;       % false positive tests
        
        % Move true Positive tested particles to True Quarantined 
        % and True Isolated states accordingly
        e(ts == ind & e==1 & (temp < testing_rate * test_sn * delta_t)) = 5;
        e(ts == ind & e==2 & (temp < testing_rate * test_sn * delta_t)) = 6;
        
        % False Positive tested particles move to False Isolated state
        t(ts == ind & e == 0 & (temp < testing_rate * (1 - test_sp) * delta_t)) = 0;
        e(ts == ind & e == 0 & (temp < testing_rate * (1 - test_sp) * delta_t)) = 8;
                        
        % Severe Infected to Death/Recovered Transition
        temp = rand(n,1);
        ind_end_severe_inf = ((t >= t_inf) & (e == 7));
        e(ind_end_severe_inf & (temp > gamma_mor)) = 3;  % Recovered
        e(ind_end_severe_inf & (temp < gamma_mor)) = 4;  % Death
                
        % display the current simulation, iteration, day, and simulations
        % time
        disp(['simulation: ', num2str(num_sim), ', iteration: ', num2str(ind)  ...
            ', day: ', num2str(ind * delta_t), ', sim time (sec): ', num2str(toc)]);
    end
    % store states of this simulation
    tot_sus_n(:, num_sim) =  tot_sus;
    tot_exp_n(:, num_sim) = tot_exp;
    tot_inf_n(:, num_sim) = tot_inf;
    tot_rec_n(:, num_sim) = tot_rec;
    tot_dead_n(:, num_sim) = tot_dead;
    tot_qua_t_n(:, num_sim) = tot_qua_t;
    tot_qua_f_n(:, num_sim) = tot_qua_f;
    tot_qua_n(:, num_sim) = tot_qua;
    tot_iso_t_n(:, num_sim) = tot_iso_t;
    tot_iso_f_n(:, num_sim) = tot_iso_f;
    tot_iso_n(:, num_sim) = tot_iso;
    tot_sev_inf_n(:, num_sim) = tot_sev_inf;
    tot_cases_n(:, num_sim) = tot_cases;
end

%% if number of simulations is more than one
if num_sim > 1
    % then average states
    tot_sus_avg =  mean(tot_sus_n, 2);
    tot_exp_avg = mean(tot_exp_n, 2);
    tot_inf_avg = mean(tot_inf_n, 2);
    tot_rec_avg = mean(tot_rec_n, 2);
    tot_dead_avg = mean(tot_dead_n, 2);
    tot_qua_avg = mean(tot_qua_n, 2);
    tot_iso_avg = mean(tot_iso_n, 2);
    tot_sev_inf_avg = mean(tot_sev_inf_n, 2);
    tot_cases_avg = mean(tot_cases_n, 2);
    
    % caclulate the std dev for total and dead cases
    std_dev_dead = std(tot_dead_n, 0, 2);
    std_dev_tot = std(tot_cases_n, 0, 2);
    
    % plot averaged values with std devs
    plot_average(delta_t, num_iter, tot_exp_avg, tot_inf_avg, tot_rec_avg, tot_dead_avg, tot_qua_avg, ...
        tot_iso_avg, tot_sev_inf_avg, tot_cases_avg, std_dev_dead, std_dev_tot)
    
    % save data
    save 'output/lecco_simulation.mat'
end

