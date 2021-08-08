import particles
import simulator
import csv
import matplotlib.pyplot as plt
import os


path = ("plot")
CHECK_FOLDER = os.path.isdir(path)

# If folder doesn't exist, then create it.
if not CHECK_FOLDER:
    os.makedirs(path)
    
# frequency of plotting the epidemic states and saving images
plot_freq = 1000

# the object of class simulator 
sim = simulator.Simulator()   

# the object of class Particles
particles = particles.Particles(sim) 


for i in range(sim.number_of_iter):
    if i%10==0:
        print("Completed {}/{} iterations".format(i, sim.number_of_iter))
    if i == 33408:
        print('done')
    
    # update the records on easch epidemic state 
    particles.update_states(i, sim)
    
    # update the velocities and coordinates of particles
    particles.update_velocities(i, sim)
    particles.update_coordinates(sim)
    
    # number of vaccines for current iteration
    vac_iter = particles.vac_per_iter(i, sim)
    
    # contacts of contagious particle
    contact_sub = particles.get_contact(i, sim)
    
    # increment the timer for each state
    particles.time_cur_state = particles.time_cur_state + sim.delta_t  
    
    # Add calibration time from the main folder
    calibration_time = 1
    days = i*sim.delta_t + calibration_time
    
    # Susceptible particles that got exposed to the infection
    new_cases = particles.get_new_cases_ids(i, sim)

    # Susceptible to Exposed transition
    sim.susceptible_to_exposed(particles, new_cases)
        
    # Trace contacts of the positive tested particles and send them to 
    # quarantined or isolated states
    sim.pos_to_trace(particles, i, contact_sub)

    # Exposed to Infected transition
    sim.exposed_to_infected(particles)
    
    # True Quarantined to True Isolated transition
    sim.quat_to_isot(particles)
    
    # False Quarantined to Susceptible transition
    sim.quaf_to_sus(particles)
    
    # Infected to Recovered transition
    sim.infected_to_recovered(particles)
    
    # Infected to Severe Infected transition
    sim.infected_to_severe_infected(particles, i)
    
    # Falrse Isolated to Susceptible transition
    sim.isof_to_sus(particles)
    
    # True Isolated to Recovered transition
    sim.isot_to_rec(particles)
    
    # True Isolated to Severe Infected transition
    sim.isot_to_sevinf(particles, i)
    
    # True Positive to True Quarantined/Isolated transition
    sim.tp_to_tqiso(particles, i)
    
    # False Positive to False Isolated transition
    sim.fp_to_fiso(particles, i)
    
    # Severe Infected to Dead/Recovered transition
    sim.severe_infected_to_dead_recovered(particles, i)
    
    # Random vaccination
    sim.random_vac(particles, i, vac_iter)
    
    #plot the epidemic states
    if i>=plot_freq and i%plot_freq==0:
        plot = particles.plot(sim, i)

