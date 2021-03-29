% prepare the desktop
close all; clear; clc;

%% initialize parameters
n_sim = 5;         % Total number of simulations
n = 337088;        % Total number of particles
n_e = 10;          % Initial number of exposed particles
sim_len = 200;     % Simulation length in days

init_v_max = 0.02;  % Maximum allowed speed of particles 

% estimate initial values of the contact threshold distance, 
% speed gain, sampling time, and total number of iterations
kt = 20; ka = 10; 
[init_x_thr, init_lambda, delta_t, n_its] = config(n, sim_len, init_v_max, kt, ka);

save_plt = 0;     % 0: don't save plots, 1: save plots.   
plt_freq = 5000;  % frequency of visualizing plots
kdt_freq = 10;    % frequency of running the KdtTree algorithm 
load_states = 1;  % 1: load random initial positions, velocities, and indices of exposed particles
                  % 0: generate randomly new initial positions, velocities, and indices of exposed particles 

t_inf = 14;  % Infection period in days
t_exp = 5;   % Exposure period in days

gamma_mor = 0.14;    % Ratio of severely infected particles who die. 

tracing_ratio = 0;   % Ratio of population with the contact tracing app
testing_rate = 0;    % Number of daily tests per thousand people
test_sn = 0.95;      % Test sensitivity
test_sp = 0.98;      % Test specificity

eps_exp = 0.7;  % Disease transmission rate of exposed compared to the infected
eps_qua = 0.3;  % Disease transmission rate of quarantined compared to the infected
eps_sev = 0.3;  % Disease transmission rate of severe infected compared to the infected

% 1: 0-9; 2: 10-19; 3: 20-29; 4: 30:39; 5: 40-49;
% 6: 50-59; 7: 60-69; 8: 70-79; 9: 80+
age_groups = [1, 2, 3, 4, 5, 6, 7, 8, 9];
% number of particles in each age group
age_distrs = [28403, 32682, 33613, 37921, 48520, 51366, 43717, 28055, 32811];
% Rate of Infected/Isolated particles getting severely infected based on
% ages
sir = [0, 0.01, 0.03, 0.08, 0.15, 0.6, 2.2, 5.1, 9.3]/100;

% to store results of n simulations
tot_sus_n = zeros(n_its,n_sim);
tot_exp_n = zeros(n_its,n_sim);
tot_inf_n = zeros(n_its,n_sim);
%------------------------------
tot_imm_n = zeros(n_its,n_sim);
%------------------------------
tot_dead_n = zeros(n_its,n_sim);
%------------------------------
tot_qua_t_n = zeros(n_its,n_sim);
tot_qua_f_n = zeros(n_its,n_sim);
tot_qua_n = zeros(n_its,n_sim);
%------------------------------
tot_iso_t_n = zeros(n_its,n_sim);
tot_iso_f_n = zeros(n_its,n_sim);
tot_iso_n = zeros(n_its,n_sim);
%------------------------------
tot_sev_inf_n = zeros(n_its,n_sim);
%------------------------------
tot_cases_n = zeros(n_its,n_sim);
%------------------------------
tot_sev_inf_age_n = zeros(n_its, length(age_groups), n_sim);
tot_dead_age_n = zeros(n_its, length(age_groups), n_sim);

% load actual data for the province of Lecco
load('actual_data.mat');
lombardy_population = 10078012;
tot_cases_act = actual_data.total_cases;
date_act = actual_data.date;
tot_dead_act = ceil(actual_data.lombardy_death * n / lombardy_population);
% load data of daily tests per thousand people
load('test_data.mat');

%% loop over the number of simulations
for i_sim = 1:n_sim
    x_thr = init_x_thr;     % Initial contact distance threshold
    v_max = init_v_max;     % Initial maximum speed of particles
    lambda = init_lambda;   % Initial speed gain
    
   % load initial values of x and v
    if load_states == 1
        load('initialization/x.mat')
        load('initialization/v.mat')
    % otherwise initialize them randomly
    else
        x = 2 * (rand(n,2) - 0.5);             % Random initial positions
        v = 2 * v_max * (rand(n,2) - 0.5);     % Random initial velocities
    end
    
    e = int8(zeros(n,1));   % 0: Susceptible, 1: Exposed, 2: Infected,
                            % 3: Recovered Immunized, 4: Dead, 5: True Quarantined
                            % 6: True Isolated, 7: Severely Infected, 8: False Quarantined
                            % 9: False Isolated
    
    app = rand(n,1) < tracing_ratio;         % Randomly install tracking app to the population
    ts = zeros(n,1);                         % COVID-19 test state
    vac = zeros(n,1);                        % Vaccination state
    
    % load age of particles
    if load_states == 1
        load('initialization/age.mat')
    % otherwise initialize randomly
    else
        age = age_state(age_distrs, age_groups); % Age state
    end
    
    contactCell = cell(n,2);      % Cell array to store the contacts,
                                  % 1st column for indices of particles, 2nd column for dates
    
    % vectors to store states
    tot_sus = zeros(n_its,1);
    tot_exp = zeros(n_its,1);
    tot_inf = zeros(n_its,1);
   
    tot_imm = zeros(n_its,1);
    
    tot_dead = zeros(n_its,1);
    
    tot_qua_t = zeros(n_its,1);
    tot_qua_f = zeros(n_its,1);
    tot_qua = zeros(n_its,1);
    
    tot_iso = zeros(n_its,1);
    tot_iso_t = zeros(n_its,1);
    tot_iso_f = zeros(n_its,1);
    tot_sev_inf = zeros(n_its,1);
    tot_cases = zeros(n_its,1);
    
    % temporal array 
    tot_sev_inf_age = zeros(n_its, length(age_groups));
    tot_dead_age = zeros(n_its, length(age_groups));
    
    % vectors to store indices
    ind_sus = zeros(n,1);
    % load exposed particles
    if load_states == 1
        load('initialization/ind_exp.mat')
    % otherwise randomly choose them
    else
        ind_exp = randi([1 n], 1, n_e);
    end
    e(ind_exp) = 1;
    ind_inf = zeros(n,1);
    ind_rec_imm = zeros(n,1);
    ind_dead = zeros(n,1);
    ind_qua_t = zeros(n,1);
    ind_qua_f = zeros(n,1);
    ind_iso_t = zeros(n,1);
    ind_iso_f = zeros(n,1);
    ind_sev_inf = zeros(n,1);
    
    % epidemic time state
    t = zeros(n,1);
    
    % start the simulation
    tic
    for ind = 1:n_its
        % extract indices for each epidemic state
        ind_sus = (e == 0);
        ind_exp = (e == 1);
        ind_inf = (e == 2);
        ind_rec_imm = (e == 3);
        ind_dead = (e == 4);
        ind_qua_t = (e == 5);
        ind_iso_t = (e == 6);
        ind_sev_inf = (e == 7);
        ind_iso_f = (e == 8);
        ind_qua_f = (e == 9);
        
        % extract a total number of particles in each state
        % for the current iteration
        tot_sus(ind) = sum(ind_sus);
        tot_exp(ind) = sum(ind_exp);
        tot_inf(ind) = sum(ind_inf);
        tot_imm(ind) = sum(ind_rec_imm);
        tot_dead(ind) = sum(ind_dead);
        tot_qua_t(ind) = sum(ind_qua_t);
        tot_qua_f(ind) = sum(ind_qua_f);
        tot_qua(ind) = tot_qua_t(ind) + tot_qua_f(ind);
        tot_iso_t(ind) = sum(ind_iso_t);
        tot_iso_f(ind) = sum(ind_iso_f);
        tot_iso(ind) = tot_iso_t(ind) + tot_iso_f(ind);
        tot_sev_inf(ind) = sum(ind_sev_inf);
        tot_cases(ind) = tot_inf(ind) + tot_imm(ind) + tot_dead(ind) + tot_iso(ind) + tot_qua(ind) + tot_sev_inf(ind);
        
        % separate total number of severely infected and dead
        % particles by age
        for k=1:length(age_groups)
            tot_sev_inf_age(ind, k) = sum((e == 7) & (age == age_groups(k)));
            tot_dead_age(ind, k) = sum((e == 4) & (age == age_groups(k)));
        end
        
        % calculate the current simulation time in days
        day = ind * delta_t;
        
        % check whether to start testing or not
        if day >= test_data.date(1)
            idx = ceil(day-test_data.date(1));
            if idx == 0
                idx = 1;
            end
            testing_rate = test_data.daily_tests(idx) * 1e-3;
        end
        
        % change the max speed and alpha based on days
        if day >= 55 && day < 71
            v_max = init_v_max * 0.6;
            lambda = v_max/ka;
        elseif day >= 71 && day < 82
            v_max = init_v_max * 0.3;
            lambda = v_max/ka;
        elseif day >= 82 && day < 122
            v_max = init_v_max * 0.2;
            lambda = v_max/ka;
        elseif day >= 122 && day < 154
            v_max = init_v_max * 0.1;
            lambda = v_max/ka;
        elseif day >= 154
            v_max = init_v_max;
            lambda = init_lambda;
            contact_thres = init_x_thr * 0.8;   
        end
                                
        % plot current epidemic states
        if mod(ind, plt_freq) == 0
            close all;
            plot_current_states_lecco(delta_t, ind, tot_exp, tot_inf, tot_imm, tot_dead, ...
                tot_qua_t, tot_iso_t, tot_sev_inf, tot_cases, tot_cases_act, ...
                tot_dead_act, date_act, save_plt)
            
            plot_map(ind, tot_exp, ind_exp, tot_inf, ind_inf, tot_imm, ind_rec_imm, tot_dead, ind_dead,...
                tot_qua_t, ind_qua_t, tot_iso_t, ind_iso_t, tot_sev_inf, ind_sev_inf, ...
                tot_sus, ind_sus, x, save_plt)
                                    
            plot_sev_inf_age(delta_t, ind, tot_sev_inf_age, tot_sev_inf)
            plot_dead_age(delta_t, ind, tot_dead_age, tot_dead)
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
        v(ind_dead | ind_qua_t | ind_qua_f | ...
            ind_iso_t | ind_iso_f | ind_sev_inf, :) = 0;
        
        % update positions based on the new velocities
        x = x + v * delta_t;  
        
        % Teleportation to contain the particles within the boundaries
        x(x > 1) = -1;
        x(x < -1) = 1;
        
        t = t + delta_t;  % Increment the state timer
        
        % Computationally efficient distance computation
        temp = rand(n,1);
        temp_ind = (ind_inf | ind_exp.*(temp < eps_exp) | ...
                    ind_qua_t.*(temp < eps_qua) | ...
                    ind_iso_t.*(temp < eps_qua) | ...
                    ind_sev_inf.*(temp < eps_sev));
        
        if mod(ind, kdt_freq) == 0 || ind == 1
            ns = createns(x, 'nsmethod', 'kdtree', 'distance', 'cityblock');
        end
        [ind_contacts, dst] = rangesearch(ns, x(temp_ind,:), x_thr, 'SortIndices', false);
        
        % Store contacts of susceptible, exposed, infected and severe infected
        % particles (who also have app installed) in contactCell
        for i = 1:numel(ind_contacts)
            if isempty(ind_contacts{i})
                continue
            end
            % index of the current contact
            curr_ind = ind_contacts{i}(1);
            % Dead, quarantined, isolated and recovered don't contact
            if app(curr_ind) == 1 && (e(curr_ind) == 0 || e(curr_ind) == 1 || e(curr_ind) == 2 || e(curr_ind) == 7)
                % loop starting from the second element because
                % the first is curr_ind element itself
                for j = 2:numel(ind_contacts{i})
                    m = numel(contactCell{curr_ind});
                    cont_ind = ind_contacts{i}(j);
                    if app(cont_ind) == 1 && (e(cont_ind) == 0 || e(cont_ind) == 1 || e(cont_ind) == 2 || e(cont_ind) == 7)
                        contactCell{curr_ind, 1}(m + 1) = cont_ind;        % Particle ID
                        contactCell{curr_ind, 2}(m + 1) = ind * delta_t;   % Contact time
                    end
                end
            end
        end
        
        % Finding the contacted particles
        ind_contacts = [ind_contacts{:}];
        temp = zeros(n,1);
        temp(ind_contacts) = 1;
        ind_contacts = temp & ind_sus;
        
        % Move the susceptible particles to the Exposed 
        % state and reset their epidemic time
        e(ind_contacts) = 1;    
        t(ind_contacts) = 0;   
                
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
        
        % True Quarantined to Isolated Transition
        ind_end_quarantined = ((t >= t_exp) & (e == 5));
        e(ind_end_quarantined) = 6;
        t(ind_end_quarantined) = 0;
        
        % False Quarantined to Susceptible Transition
        ind_end_quarantined = ((t >= t_exp) & (e == 9));
        e(ind_end_quarantined) = 0;
        t(ind_end_quarantined) = 0;
        
        % Infected to Recovered Transition
        ind_end_infection = ((t >= t_inf) & (e == 2));
        e(ind_end_infection) = 3;  
        
        % Infected to Severe Infected Transition
        for ind_age=1:length(sir)
            sir_ind = find(e == 2 & age == age_groups(ind_age));
            temp = rand(length(sir_ind),1);
            ts(sir_ind(temp < sir(ind_age) * delta_t)) = ind;
            e(sir_ind(temp < sir(ind_age) * delta_t)) = 7;
        end
        
        % False Isolated to Susceptible Transition
        ind_end_isolation = ((t >= t_inf) & (e == 8));
        e(ind_end_isolation) = 0;
        t(ind_end_isolation) = 0;
        
        % True Isolated to Recovered Transition
        ind_end_isolation = ((t >= t_inf) & (e == 6));
        e(ind_end_isolation) = 3;
        
        % True Isolated to Severe Infected Transition
        for ind_age=1:length(sir)
            sir_ind = find(e == 6 & age == age_groups(ind_age));
            temp = rand(length(sir_ind),1);
            ts(sir_ind(temp < sir(ind_age) * delta_t)) = ind;
            e(sir_ind(temp < sir(ind_age) * delta_t)) = 7;
        end
                        
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
        disp(['simulation: ', num2str(i_sim), ', iteration: ', num2str(ind)  ...
            ', day: ', num2str(ind * delta_t), ', sim time (sec): ', num2str(toc)]);
    end
    % store states of this simulation
    tot_sus_n(:, i_sim) =  tot_sus;
    tot_exp_n(:, i_sim) = tot_exp;
    tot_inf_n(:, i_sim) = tot_inf;
    tot_imm_n(:, i_sim) = tot_imm;
    tot_dead_n(:, i_sim) = tot_dead;
    tot_qua_t_n(:, i_sim) = tot_qua_t;
    tot_qua_f_n(:, i_sim) = tot_qua_f;
    tot_qua_n(:, i_sim) = tot_qua;
    tot_iso_t_n(:, i_sim) = tot_iso_t;
    tot_iso_f_n(:, i_sim) = tot_iso_f;
    tot_iso_n(:, i_sim) = tot_iso;
    tot_sev_inf_n(:, i_sim) = tot_sev_inf;
    tot_cases_n(:, i_sim) = tot_cases;
    
    tot_sev_inf_age_n(:, :, i_sim) = tot_sev_inf_age;
    tot_dead_age_n(:, :, i_sim) = tot_dead_age;
end
%% if number of simulations is more than one
if n_sim > 1
    % then average states
    tot_sus_avg =  mean(tot_sus_n,2);
    tot_exp_avg = mean(tot_exp_n,2);
    tot_inf_avg = mean(tot_inf_n,2);
    tot_imm_avg = mean(tot_imm_n,2);
    tot_dead_avg = mean(tot_dead_n,2);
    tot_qua_avg = mean(tot_qua_n,2);
    tot_iso_avg = mean(tot_iso_n,2);
    tot_sev_inf_avg = mean(tot_sev_inf_n,2);
    tot_cases_avg = mean(tot_cases_n,2);
    tot_sev_inf_age_avg = mean(tot_sev_inf_age_n, 3);
    tot_dead_age_avg = mean(tot_dead_age_n, 3);
    
    % caclulate std devs for total and death cases
    std_dev_dead = std(tot_dead_n, 0, 2);
    std_dev_tot = std(tot_cases_n, 0, 2);
    
    % plot averaged values with std devs
    plot_average_lecco(delta_t, n_its, tot_exp_avg, tot_inf_avg, tot_imm_avg, tot_dead_avg, tot_qua_avg, ...
        tot_iso_avg, tot_sev_inf_avg, tot_cases_avg, tot_cases_act, tot_dead_act, date_act, std_dev_dead, std_dev_tot)
    
    plot_sev_inf_age(delta_t, n_its, tot_sev_inf_age_avg, tot_sev_inf_avg)
    plot_dead_age(delta_t, n_its, tot_dead_age_avg, tot_dead_avg, tot_dead_act, date_act)
    
end
% save data
save 'output/calibration_0_200.mat'

