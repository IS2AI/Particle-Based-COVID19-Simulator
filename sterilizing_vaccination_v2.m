% prepare the desktop
close all; clear; clc;

%% load calibrated model
model = load('output/lecco_calib_200_361.mat');

%% initialize parameters
n_sim = 5;                                                 % Total number of simulations
n = model.n;                                               % Total number of particles
delta_t = model.delta_t;                                   % Sampling time in days
num_daily_vacc = 2;                                        % Daily vaccination per 1000 people
vac_per_iter_float = num_daily_vacc * n / 1000 * delta_t;  % Number of vaccinations per iteration   
vac_per_iter_floor = floor(vac_per_iter_float);
vac_per_iter_ceil = ceil(vac_per_iter_float);

rand_vac = 1; % 0: no vaccination; 1: rand vaccination
vacc_all = 1; % 0: age based vaccinaton, 1: vaccinate all
if rand_vac == 1 && vacc_all == 0
    maps_path = sprintf('sterilizing_age_69/vac_rate_%d/maps', num_daily_vacc);
elseif rand_vac == 1 && vacc_all == 1
    maps_path = sprintf('sterilizing_all_69/vac_rate_%d/maps', num_daily_vacc);
else
    maps_path = 'no_vacc/maps';
end

sim_len = 450;                 % Simulation length in days     
n_its = ceil(sim_len/delta_t); % Num of iterations in the simulation

init_v_max = model.init_v_max;      % Maximum allowed speed of particles 
init_x_thr = model.init_x_thr;      % Contact threshold 
init_lambda = model.init_lambda;    % Speed gain
ka = model.ka;

% 0: don't save plots, 
% 1: save plots.
save_plt = 0;   
if save_plt == 1
    if not(exist(maps_path,'dir'))
        mkdir(maps_path);
    end
end
plt_freq = 5000;              % frequency of visualizing plots
kdt_freq = model.kdt_freq;    % frequency of running the KdtTree algorithm 

t_inf = model.t_inf;   % Infection time in days
t_exp = model.t_exp;   % Exposure time in days
t_im1 = ceil(12/delta_t) * delta_t;  % Immunization time after the first dose
t_im2 = ceil(28/delta_t) * delta_t;  % Immunization time in case of taking the second dose

gamma_mor = model.gamma_mor;  % Ratio of severely infected particles who die.
gamma_imm1 = 0.52; % Ratio of vaccinated immunized at t_im1
gamma_imm2 = 0.95; % Ratio of vaccinated immunized at t_im2

test_sn = model.test_sn;      % Test sensitivity
test_sp = model.test_sp;      % Test specificity

eps_exp = model.eps_exp;  % Disease transmission rate of exposed compared to the infected
eps_qua = model.eps_qua;  % Disease transmission rate of quarantined compared to the infected
eps_sev = model.eps_sev;  % Disease transmission rate of severe infected compared to the infected

% 1: 0-9; 2: 10-19; 3: 20-29; 4: 30:39; 5: 40-49; 
% 6: 50-59; 7: 60-69; 8: 70-79; 9: 80+
age_groups = model.age_groups;
age_distrs = model.age_distrs;
sir = model.sir;

% to store results of n simulations
tot_sus_n = zeros(n_its,n_sim);
tot_exp_n = zeros(n_its,n_sim);
tot_inf_n = zeros(n_its,n_sim);
%------------------------------
tot_rec_imm_n = zeros(n_its,n_sim);
tot_vac_imm_n = zeros(n_its,n_sim);
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

% load actual data for Lecco
load('actual_data.mat');
lombardy_population = 10078012;
tot_cases_act = actual_data.total_cases;
date_act = actual_data.date - floor(model.t(end));
tot_dead_act = ceil(actual_data.lombardy_death * n / lombardy_population);
% load daily tests per thousand people
load('test_data.mat');

%% loop over the number of simulations
for i_sim = 1:n_sim
    x_thr = model.x_thr;     % Contact distance threshold
    v_max = model.v_max;     % Maximum speed of particles
    lambda = model.lambda;   % Speed gain
    
    x = model.x;        % Position state
    v = model.v;        % Velocity state
    e = model.e;        % Epidemic state
    app = model.app;    % Application state
    ts = model.ts;      % Test state
    vac = model.vac;    % Vaccination state
    age = model.age;    % Age state
    
    contactCell = model.contactCell;  % Cell array to store the contacts,
                                      % 1st column for indexes of particles, 2nd column for dates
    
    % vectors to store states
    tot_sus = zeros(n_its,1);
    tot_exp = zeros(n_its,1);
    tot_inf = zeros(n_its,1);
    
    tot_rec_imm = zeros(n_its,1);
    tot_vac_imm = zeros(n_its,1);
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
    ind_exp = zeros(n,1);
    ind_inf = zeros(n,1);
    ind_rec_imm = zeros(n,1);
    ind_vac_imm = zeros(n,1);
    ind_dead = zeros(n,1);
    ind_qua_t = zeros(n,1);
    ind_qua_f = zeros(n,1);
    ind_iso_t = zeros(n,1);
    ind_iso_f = zeros(n,1);
    ind_sev_inf = zeros(n,1);
    
    % epidemic time state
    t = model.t;
    
    vac_groups = [0, 0, 0, 0, 0, 0, 0, 0, 0];

    % start the simulation
    tic
    for ind = 1:n_its
        % estimate the vaccinatin per iteration
        if rand > (vac_per_iter_float - vac_per_iter_floor)
            vac_per_iter = vac_per_iter_floor;
        else
            vac_per_iter = vac_per_iter_ceil;
        end
        % extract indices for each state
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
        ind_vac_imm = (e == 10);
        ind_imm = (ind_rec_imm | ind_vac_imm);
        
        % extract a total number of particles in each state
        % for the current iteration
        tot_sus(ind) = sum(ind_sus);
        tot_exp(ind) = sum(ind_exp);
        tot_inf(ind) = sum(ind_inf);
        tot_rec_imm(ind) = sum(ind_rec_imm);
        tot_vac_imm(ind) = sum(ind_vac_imm);
        tot_imm(ind) = tot_rec_imm(ind) + tot_vac_imm(ind);
        tot_dead(ind) = sum(ind_dead);
        tot_qua_t(ind) = sum(ind_qua_t);
        tot_qua_f(ind) = sum(ind_qua_f);
        tot_qua(ind) = tot_qua_t(ind) + tot_qua_f(ind);
        tot_iso_t(ind) = sum(ind_iso_t);
        tot_iso_f(ind) = sum(ind_iso_f);
        tot_iso(ind) = tot_iso_t(ind) + tot_iso_f(ind);
        tot_sev_inf(ind) = sum(ind_sev_inf);
        tot_cases(ind) = tot_inf(ind) + tot_rec_imm(ind) + tot_qua(ind) + tot_dead(ind) + tot_iso(ind) + tot_sev_inf(ind);
        
        for k=1:length(age_groups)
            tot_sev_inf_age(ind, k) = sum((e == 7) & (age == age_groups(k)));
            tot_dead_age(ind, k) = sum((e == 4) & (age == age_groups(k)));
        end
        
        % calculate the current simulation time in days
        day = ind * delta_t + model.t(end);
        
        if day < test_data.date(end)
            testing_rate = test_data.daily_tests(ceil(day-test_data.date(1))) * 1e-3;
        else
            testing_rate = test_data.daily_tests(end) * 1e-3;
        end
            
        % change the max speed and alpha based on days
        if day >= 375 && day < 382
            v_max = init_v_max * 0.5;
            lambda = v_max/ka;
        elseif day >= 382
            v_max = init_v_max * 0.6;
            lambda = v_max/ka;
        end
                                
        if ind == 1
            ind_exp_i = ind_exp;
            ind_inf_i = ind_inf;
            ind_dead_i = ind_dead;
            ind_sev_inf_i = ind_sev_inf;
            x_i = x;
        end
                                
        % plot current epidemic states
        if mod(ind, plt_freq) == 0 || ind == 1
            close all;
            plot_maps(ind, ind_exp, ind_inf, ind_vac_imm, ind_dead, ind_qua_t, ind_iso_t, ind_sev_inf, ...
                ind_sus, age, age_groups, vac, x, save_plt, maps_path, ind_exp_i, ind_inf_i, ind_dead_i, ...
                ind_sev_inf_i, x_i)
            plot_current_states_lecco(delta_t, ind, tot_exp, tot_inf, tot_imm, tot_dead, ...
                tot_qua_t, tot_iso_t, tot_sev_inf, tot_cases, tot_cases_act, ...
                tot_dead_act, date_act, save_plt)
            
%             plot_map(ind, tot_exp, ind_exp, tot_inf, ind_inf, tot_imm, ind_rec_imm, tot_dead, ind_dead,...
%                 tot_qua_t, ind_qua_t, tot_iso_t, ind_iso_t, tot_sev_inf, ind_sev_inf, ...
%                 tot_sus, ind_sus, x, save_plt)
            
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
            %sir_ind = sir_ind(randperm(numel(sir_ind)));
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
            %sir_ind = sir_ind(randperm(numel(sir_ind)));
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
        
        % random vaccination
        if rand_vac == 1 && vacc_all == 1
            % vaccinate whole population above 19 years old
            vac_ind = find(vac == 0 & (e == 0 | e == 1 | e == 2 | e == 3) & age > age_groups(2) & age < age_groups(8));
            vac_ind = vac_ind(randperm(numel(vac_ind)));
            if length(vac_ind) > vac_per_iter
                vac_ind = vac_ind(1:vac_per_iter);
            end
            % update the vaccination state
            vac(vac_ind) = ind * delta_t;
            
            % calculate time passed since
            % the first vaccination
            t_vac = ind * delta_t - vac;
            
            ind_end_imm1 = find(t_vac > t_im1 - delta_t & t_vac < t_im1 + delta_t & vac > 0 & e == 0);
            temp = rand(length(ind_end_imm1), 1);
            %ind_end_imm1 = (t_vac > t_im1 - delta_t & t_vac < t_im1 + delta_t & vac > 0 & (e == 0  | e == 3) & (temp < 0.52));
            e(ind_end_imm1(temp < gamma_imm1)) = 10;
            
            ind_end_imm2 = find(t_vac > t_im2 - delta_t & t_vac < t_im2 + delta_t & vac > 0 & e == 0);
            temp = rand(length(ind_end_imm2), 1);
            %ind_end_imm2 = (t_vac > t_im2 - delta_t & t_vac < t_im2 + delta_t & (e == 0  | e == 3) & vac > 0 & (temp < 0.95));
            e(ind_end_imm2(temp < gamma_imm2)) = 10;
                        
        elseif rand_vac == 1 && vacc_all == 0
            not_vac_ind = (vac == 0 & (e == 0 | e == 1 | e == 2 | e == 3));
%             if sum(not_vac_ind & age == age_groups(9)) > 0
%                 vac_ind = find(not_vac_ind & age == age_groups(9));
%                 vac_ind = vac_ind(randperm(numel(vac_ind)));
%                 if length(vac_ind) > vac_per_iter
%                     vac_ind = vac_ind(1:vac_per_iter);
%                 end
%                 vac_groups(9) = vac_groups(9) + length(vac_ind)
%             elseif sum(not_vac_ind & age == age_groups(8)) > 0
%                 vac_ind = find(not_vac_ind & age == age_groups(8));
%                 vac_ind = vac_ind(randperm(numel(vac_ind)));
%                 if length(vac_ind) > vac_per_iter
%                     vac_ind = vac_ind(1:vac_per_iter);
%                 end
%                 vac_groups(8) = vac_groups(8) + length(vac_ind)
            if sum(not_vac_ind & age == age_groups(7)) > 0
                vac_ind = find(not_vac_ind & age == age_groups(7));
                vac_ind = vac_ind(randperm(numel(vac_ind)));
                if length(vac_ind) > vac_per_iter
                    vac_ind = vac_ind(1:vac_per_iter);
                end
                vac_groups(7) = vac_groups(7) + length(vac_ind);
            elseif sum(not_vac_ind & age == age_groups(6)) > 0
                vac_ind = find(not_vac_ind & age == age_groups(6));
                vac_ind = vac_ind(randperm(numel(vac_ind)));
                if length(vac_ind) > vac_per_iter
                    vac_ind = vac_ind(1:vac_per_iter);
                end
                vac_groups(6) = vac_groups(6) + length(vac_ind);
            elseif sum(not_vac_ind & age == age_groups(5)) > 0
                vac_ind = find(not_vac_ind & age == age_groups(5));
                vac_ind = vac_ind(randperm(numel(vac_ind)));
                if length(vac_ind) > vac_per_iter
                    vac_ind = vac_ind(1:vac_per_iter);
                end
                vac_groups(5) = vac_groups(5) + length(vac_ind);
            elseif sum(not_vac_ind & age == age_groups(4)) > 0
                vac_ind = find(not_vac_ind & age == age_groups(4));
                vac_ind = vac_ind(randperm(numel(vac_ind)));
                if length(vac_ind) > vac_per_iter
                    vac_ind = vac_ind(1:vac_per_iter);
                end
                vac_groups(4) = vac_groups(4) + length(vac_ind);
            elseif sum(not_vac_ind & age == age_groups(3)) > 0
                vac_ind = find(not_vac_ind & age == age_groups(3));
                vac_ind = vac_ind(randperm(numel(vac_ind)));
                if length(vac_ind) > vac_per_iter
                    vac_ind = vac_ind(1:vac_per_iter);
                end
                vac_groups(3) = vac_groups(3) + length(vac_ind);
%             elseif sum(not_vac_ind & age == age_groups(2)) > 0
%                 vac_ind = find(not_vac_ind & age == age_groups(2));
%                 vac_ind = vac_ind(randperm(numel(vac_ind)));
%                 if length(vac_ind) > vac_per_iter
%                     vac_ind = vac_ind(1:vac_per_iter);
%                 end
%                 vac_groups(2) = vac_groups(2) + length(vac_ind)
%             elseif sum(not_vac_ind & age == age_groups(1)) > 0
%                 vac_ind = find(not_vac_ind & age == age_groups(1));
%                 vac_ind = vac_ind(randperm(numel(vac_ind)));
%                 if length(vac_ind) > vac_per_iter
%                     vac_ind = vac_ind(1:vac_per_iter);
%                 end
%                 vac_groups(1) = vac_groups(1) + length(vac_ind)
            end
            
            % update the vaccination state
            vac(vac_ind) = ind * delta_t;
            
            % calculate time passed since
            % the vaccination
            t_vac = ind * delta_t - vac;
            
            ind_end_imm1 = find(t_vac > t_im1 - delta_t & t_vac < t_im1 + delta_t & vac > 0 & e == 0);
            temp = rand(length(ind_end_imm1), 1);
            e(ind_end_imm1(temp < gamma_imm1)) = 10; 
                
            ind_end_imm2 = find(t_vac > t_im2 - delta_t & t_vac < t_im2 + delta_t & vac > 0 & e == 0);
            temp = rand(length(ind_end_imm2), 1);
            e(ind_end_imm2(temp < gamma_imm2)) = 10;
            
        end

                
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
    tot_rec_imm_n(:, i_sim) = tot_rec_imm;
    tot_vac_imm_n(:, i_sim) = tot_vac_imm;
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
    
    % save data
end
save 'output/lecco_serilizing_vacc_69_8.mat'

