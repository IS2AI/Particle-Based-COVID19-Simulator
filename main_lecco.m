% prepare the desktop
close all; clear; clc;

%% initialize parameters
num_simulations = 1;                          % Number of simulations
num_population = 337000;                      % Total number of particles
num_exposed = 10;                              % Initial number of exposed particles
sim_length = 200;                             % Length of the simulation in days

mean_dst = 1/sqrt(num_population);            % Mean distance between particles 
init_cont_thr = mean_dst/20;                  % Contact distance threshold
init_max_vel = 0.02;                          % Maximum velocity of particles 
init_alpha = init_max_vel/10;                 % Speed gain of particles
delta_t = init_cont_thr/init_max_vel;         % Sampling time in days
num_iter = ceil(sim_length/delta_t);          % Total number of iterations

save_figures = 0;          % 0: don't save, 1: save.
vis = 1000;                % plot results after each vis iterations
kdt = 10;                  % run KdtTree after each kdt iterations 
load_init_states = 1;      % 1: Load initial positions x, velocities v, and indicies of exposed particles ind_exposed
                           % 0: generate random initial positions x, velocities v, and indicies of exposed particles ind_exposed

t_inf = 14;                 % Infection time in days
t_exp = 5;                  % Exposure time in days

sir = 0.02;                 % Daily Infected to Severe Infected Transition
gamma_mor = 0.15;           % Ratio of Severe Infected who die. The rest go to Recovered state

tracking_rate = 0;          % Percentage of population using tracking app
testing_rate = 5e-4;        % Daily rate of random testing for COVID-19
test_sn = 0.95;             % Test sensitivity
test_sp = 0.99;              % Test specificity

eps_exp = 0.7;      % Disease transmission rate of exposed compared to the infected
eps_qua = 0.3;      % Disease transmission rate of quarantined compared to the infected
eps_sev = 0.3;      % Disease transmission rate of severe infected compared to the infected

% load actual data for Lecco
load('actual_data.mat');
lombardy_region_population = 10078012;
total_cases_actual = actual_data.total_cases;
actual_date = actual_data.date;
death_cases_actual = ceil(actual_data.lombardy_death * num_population/ lombardy_region_population);

% matrices to store states after each simulation
tot_susceptible_n = zeros(num_iter,num_simulations);
tot_exposed_n = zeros(num_iter, num_simulations);
tot_infected_n = zeros(num_iter, num_simulations);
tot_recovered_n = zeros(num_iter, num_simulations);
tot_dead_n = zeros(num_iter, num_simulations);
tot_quarantined_t_n = zeros(num_iter, num_simulations);
tot_quarantined_f_n = zeros(num_iter, num_simulations);
tot_quarantined_n = zeros(num_iter, num_simulations);
tot_isolated_t_n = zeros(num_iter, num_simulations);
tot_isolated_f_n = zeros(num_iter, num_simulations);
tot_isolated_n = zeros(num_iter, num_simulations);
tot_severe_inf_n = zeros(num_iter, num_simulations);
tot_cases_n = zeros(num_iter, num_simulations);

%% loop over the number of simulations
for num_sim = 1:num_simulations
    contact_thres = init_cont_thr;                % Initial contact distance threshold
    max_speed = init_max_vel;                     % Initial maximum speed of particles
    alpha = init_alpha;                           % Initial speed gain
    
    % load initial x and v
    if load_init_states == 1
        load('initialization/x.mat')
        load('initialization/v.mat')
    % otherwise initialize randomly
    else
        x = 2 * (rand(num_population, 2) - 0.5);           % Random initial positions
        v = max_speed * (rand(num_population, 2) - 0.5);   % Random initial velocities
    end
    e = int8(zeros(num_population, 1));                % Epidemic status:
                                                       % 0 -> Susceptible, 1 -> Exposed, 2 -> Infected, 3 -> Recovered,
                                                       % 4 -> Dead, 5 -> Quarantined, 6 -> Isolated, 7 -> Severe Infected
    
    a = rand(num_population, 1) < tracking_rate;       % Randomly install tracking app to the population
    ts_t = zeros(num_population, 1);                   % COVID-19 positive Tested and Confirmed
    ts_f = zeros(num_population, 1);                   % COVID-19 false Tested and Confirmed
    contactCell = cell(num_population, 2);             % Cell array to store the contacts,
                                                       % 1st column for indexes of particles, 2nd column for dates
    % vectors to store states
    tot_susceptible = zeros(num_iter,1);
    tot_exposed = zeros(num_iter, 1);
    tot_infected = zeros(num_iter, 1);
    tot_recovered = zeros(num_iter, 1);
    tot_dead = zeros(num_iter, 1);
    tot_true_quarantined = zeros(num_iter, 1);
    tot_false_quarantined = zeros(num_iter, 1);
    tot_quarantined = zeros(num_iter, 1);
    tot_isolated = zeros(num_iter, 1);
    tot_true_isolated = zeros(num_iter, 1);
    tot_false_isolated = zeros(num_iter, 1);
    tot_severe_inf = zeros(num_iter, 1);
    tot_cases = zeros(num_iter, 1);
    
    % vectors to store indices
    ind_susceptible = zeros(num_population, 1);
    ind_infected = zeros(num_population, 1);
    ind_recovered = zeros(num_population, 1);
    ind_dead = zeros(num_population, 1);
    ind_true_quarantined = zeros(num_population, 1);
    ind_false_quarantined = zeros(num_population, 1);
    ind_true_isolated = zeros(num_population, 1);
    ind_false_isolated = zeros(num_population, 1);
    ind_severe_inf = zeros(num_population, 1);
    
    % load infected persons
    if load_init_states == 1
        load('initialization/ind_exposed.mat')
    % otherwise randomly choose infected persons
    else
        ind_exposed = randi([1 num_population], 1 , num_exposed);
    end
    e(ind_exposed) = 1;
    
    % vector to store a timestamp of each particle
    t = zeros(num_population,1);

    % start the simulation
    tic
    for ind = 1:num_iter
        % extract indices for each state
        ind_susceptible = (e == 0);
        ind_exposed = (e == 1);
        ind_infected = (e == 2);
        ind_recovered = (e == 3);
        ind_dead = (e == 4);
        ind_true_quarantined = (e == 5);
        ind_true_isolated = (e == 6);
        ind_severe_inf = (e == 7);
        ind_false_isolated = (e == 8);
        ind_false_quarantined = (e == 9);
        
        % extract a total number of particles in each state
        % for the current iteration
        tot_susceptible(ind) = sum(ind_susceptible);
        tot_exposed(ind) = sum(ind_exposed);
        tot_infected(ind) = sum(ind_infected);
        tot_recovered(ind) = sum(ind_recovered);
        tot_dead(ind) = sum(ind_dead);
        tot_true_quarantined(ind) = sum(ind_true_quarantined);
        tot_false_quarantined(ind) = sum(ind_false_quarantined);
        tot_quarantined(ind) = tot_true_quarantined(ind) + tot_false_quarantined(ind);
        tot_true_isolated(ind) = sum(ind_true_isolated);
        tot_false_isolated(ind) = sum(ind_false_isolated);
        tot_isolated(ind) = tot_true_isolated(ind) + tot_false_isolated(ind);
        tot_severe_inf(ind) = sum(ind_severe_inf);
        tot_cases(ind) = tot_infected(ind) + tot_recovered(ind) + tot_dead(ind) + tot_isolated(ind) + tot_severe_inf(ind);
        
        % calculate the current simulation time in days
        day = ind * delta_t;
        
        % change the max speed and alpha based on days
        if day >= 55 && day < 71
            max_speed = init_max_vel * 0.6;
            alpha = max_speed/10;
        elseif day >= 71 && day < 82
            max_speed = init_max_vel * 0.3;
            alpha = max_speed/10;
        elseif day >= 82 && day < 122
            max_speed = init_max_vel * 0.2;
            alpha = max_speed/10;
        elseif day >= 122 && day < 154
            max_speed = init_max_vel * 0.1;
            alpha = max_speed/10;
        elseif day >= 154
            max_speed = init_max_vel;
            alpha = init_alpha;
            contact_thres = init_cont_thr * 0.8;     % Contact distance threshold
        end
                
        % plot the current states
        if mod(ind, vis) == 0
            close all;
            plot_current_states_lecco(delta_t, ind, tot_exposed, tot_infected, tot_recovered, tot_dead, ...
                tot_true_quarantined, tot_true_isolated, tot_severe_inf, tot_cases, total_cases_actual, ...
                death_cases_actual, actual_date, save_figures)
            
            plot_map(ind, tot_exposed, ind_exposed, tot_infected, ind_infected, tot_recovered, ind_recovered, tot_dead, ind_dead,...
                tot_true_quarantined, ind_true_quarantined, tot_true_isolated, ind_true_isolated, tot_severe_inf, ind_severe_inf, ...
                tot_susceptible, ind_susceptible, x, save_figures)
            pause(0.01)
        end
        
        % change the velocities randomly
        if mod(ind, kdt * 2) == 0 || ind == 1
            v = v + alpha * (rand(num_population, 2) - 0.5);
        end
        % If max speed is reached, stop to allow direction change.
        v(v > max_speed) = 0;
        v(v < -max_speed) = 0;
        % Dead, quarantined, isolated, severe infected (in hospital) don't move
        v(ind_dead | ind_true_quarantined | ind_false_quarantined | ind_true_isolated | ind_false_isolated | ind_severe_inf, :) = 0;
        
        % update positions based on the new velocities
        x = x + v * delta_t;  % This is our differential equation
        
        % Teleportation to contain the particles within the boundaries
        % Alternatively bouncing can be implemented (harder)
        x(x > 1) = -1;
        x(x < -1) = 1;
        
        t = t + delta_t;  % Increase the state timer (Reset if state change occurs)
        
        % Computationally efficient distance computation
        temp = rand(num_population,1);
        temp_ind = (ind_infected | ind_exposed.*(temp < eps_exp) | ...
            ind_true_quarantined.*(temp < eps_qua) | ...
            ind_true_isolated.*(temp < eps_qua) | ...
            ind_severe_inf.*(temp < eps_sev));
        
        if mod(ind, kdt) == 0 || ind == 1
            ns = createns(x, 'nsmethod', 'kdtree', 'distance', 'cityblock');
        end
        [ind_contacts, dst] = rangesearch(ns, x(temp_ind,:), contact_thres);
        
        % Storing the contacts of susceptible, exposed, infected and severe infected
        % individuals (who also have app installed) in contactCell
        for i = 1:numel(ind_contacts)
            % index of the current contact
            if isempty(ind_contacts{i})
                continue
            end
            curr_ind = ind_contacts{i}(1);
            % Dead, quarantined, isolated and recovered don't contact
            if a(curr_ind) == 1 && (e(curr_ind) == 0 || e(curr_ind) == 1 || e(curr_ind) == 2 || e(curr_ind) == 7)
                % loop starting from the second element
                % because the first is curr_ind element
                for j = 2:numel(ind_contacts{i})
                    m = numel(contactCell{curr_ind});
                    cont_ind = ind_contacts{i}(j);
                    if a(cont_ind) == 1 && (e(cont_ind) == 0 || e(cont_ind) == 1 || e(cont_ind) == 2 || e(cont_ind) == 7)
                        contactCell{curr_ind, 1}(m + 1) = cont_ind;        % Particle ID
                        contactCell{curr_ind, 2}(m + 1) = ind * delta_t;   % Date
                    end
                end
            end
        end
        
        % Finding the contacted particles
        ind_contacts = [ind_contacts{:}];
        temp = zeros(num_population,1);
        temp(ind_contacts) = 1;
        ind_contacts = temp & not(ind_infected) & not(ind_severe_inf) ...
            & not(ind_true_quarantined) & not(ind_true_isolated) & ind_susceptible;
        
        % Susceptible to Exposed transition
        e(ind_contacts) = 1;    % Change their epidemic status to Exposed = 1
        t(ind_contacts) = 0;    % Reset state timer
                
        % Version 14 update - Contact tracing based quarantining
        % Quarantine the (infected) contact list of a positive tested individual
        ind_recent_inf = (ts_t >= (ind - 1) | ts_f >= (ind - 1));
        for i = 1:numel(ind_recent_inf)
            % if the recently infected particle has installed app
            if ind_recent_inf(i) == 1 && a(i) == 1
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
        e(ind_end_infection) = 3;  % Recovered
        
        % Infected to Severe Infected Transition
        temp = rand(num_population,1);
        ts_t(e == 2 & (temp < sir * delta_t)) = ind; % COVID-19 Positive Tested --> Store the positive test date
        e(e == 2 & (temp < sir * delta_t)) = 7;
        
        % False Isolated to Susceptible Transition
        ind_end_isolation = ((t >= t_inf) & (e == 8));
        e(ind_end_isolation) = 0;
        t(ind_end_isolation) = 0;
        
        % True Isolated to Recovered Transition
        ind_end_isolation = ((t >= t_inf) & (e == 6));
        e(ind_end_isolation) = 3;
        
        % True Isolated to Severe Infected Transition
        temp = rand(num_population, 1);
        e(e == 6 & (temp < sir * delta_t)) = 7;
                        
        % Random test for COVID-19 taking into account the
        % test sensitivity and specificity
        %if mod(ind, kdt) == 0 
        ts_t(ts_t == 0 & (e == 1 | e == 2) & (temp < testing_rate * test_sn * delta_t)) = ind;     % Correct positive tests
        ts_f(ts_f == 0 & e == 0 & (temp < testing_rate * (1-test_sp) * delta_t)) = ind; % False positive tests
        
        % True Positive tested to True Isolated Transition
        e(ts_t == ind & e==1 & (temp < testing_rate * test_sn * delta_t)) = 5;
        e(ts_t == ind & e==2 & (temp < testing_rate * test_sn * delta_t)) = 6;
        
        % False Positive tested to False Isolated Transition
        t(ts_f == ind & e == 0 & (temp < testing_rate * (1 - test_sp) * delta_t)) = 0;
        e(ts_f == ind & e == 0 & (temp < testing_rate * (1 - test_sp) * delta_t)) = 8;
                        
        % Severe Infected to Death/Recovered Transition
        temp = rand(num_population,1);
        ind_end_severe_inf = ((t >= t_inf) & (e == 7));
        e(ind_end_severe_inf & (temp > gamma_mor)) = 3;  % Recovered
        e(ind_end_severe_inf & (temp < gamma_mor)) = 4;  % Death
                
        % display the current simulation, iteration, day, and simulations
        % time
        disp(['simulation: ', num2str(num_sim), ', iteration: ', num2str(ind)  ...
            ', day: ', num2str(ind * delta_t), ', sim time (sec): ', num2str(toc)]);
    end
    % store states of this simulation
    tot_susceptible_n(:, num_sim) =  tot_susceptible;
    tot_exposed_n(:, num_sim) = tot_exposed;
    tot_infected_n(:, num_sim) = tot_infected;
    tot_recovered_n(:, num_sim) = tot_recovered;
    tot_dead_n(:, num_sim) = tot_dead;
    tot_quarantined_t_n(:, num_sim) = tot_true_quarantined;
    tot_quarantined_f_n(:, num_sim) = tot_false_quarantined;
    tot_quarantined_n(:, num_sim) = tot_quarantined;
    tot_isolated_t_n(:, num_sim) = tot_true_isolated;
    tot_isolated_f_n(:, num_sim) = tot_false_isolated;
    tot_isolated_n(:, num_sim) = tot_isolated;
    tot_severe_inf_n(:, num_sim) = tot_severe_inf;
    tot_cases_n(:, num_sim) = tot_cases;
end

%% if number of simulations is more than one
if num_sim > 1
    % then average states
    tot_susceptible_avg =  mean(tot_susceptible_n, 2);
    tot_exposed_avg = mean(tot_exposed_n, 2);
    tot_infected_avg = mean(tot_infected_n, 2);
    tot_recovered_avg = mean(tot_recovered_n, 2);
    tot_dead_avg = mean(tot_dead_n, 2);
    tot_quarantined_avg = mean(tot_quarantined_n, 2);
    tot_isolated_avg = mean(tot_isolated_n, 2);
    tot_severe_inf_avg = mean(tot_severe_inf_n, 2);
    tot_cases_avg = mean(tot_cases_n, 2);
    
    % caclulate the std dev for total and dead cases
    std_dev_dead = std(tot_dead_n, 0, 2);
    std_dev_tot = std(tot_cases_n, 0, 2);
    
    % plot averaged values with std devs
    plot_average(delta_t, num_iter, tot_exposed_avg, tot_infected_avg, tot_recovered_avg, tot_dead_avg, tot_quarantined_avg, ...
        tot_isolated_avg, tot_severe_inf_avg, tot_cases_avg, total_cases_actual, death_cases_actual, actual_date, ...
        std_dev_dead, std_dev_tot)
    
    % save data
    save 'output/track_0_05.mat'
end

