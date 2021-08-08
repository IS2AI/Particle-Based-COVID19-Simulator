import particles
import simulator
import csv
import pandas as pd
import matplotlib.pyplot as plt
import os
import numpy as np

path = ("plot")
CHECK_FOLDER = os.path.isdir(path)

# If folder doesn't exist, then create it.
if not CHECK_FOLDER:
    os.makedirs(path)
    
# frequency of plotting the epidemic states and saving images
plot_freq = 1000

# the object of class Simulator 
sim = simulator.Simulator()   

# the object of class Particles 
particles = particles.Particles(sim) 


for i in range(sim.number_of_iter):
    if i%10==0:
        print("Completed {}/{} iterations".format(i, sim.number_of_iter))
        
    # update the records on easch epidemic state 
    particles.update_states(i, sim)
    
    # update the velocities and coordinates of particles
    particles.update_velocities(i, sim)
    particles.update_coordinates(sim)
    
    # get contacts for tracing purposes
    contact_sub = particles.get_contact(i, sim)
    
    # increment the timer for each state
    particles.time_cur_state = particles.time_cur_state + sim.delta_t 
    
    # Susceptible particles that got exposed to the infection
    new_cases = particles.get_new_cases_ids(i, sim)

    # Susceptible to Exposed transition
    sim.susceptible_to_exposed(particles, new_cases)
        
    # Trace contacts of the positive tested particles and send them to 
    # quarantined or isolated states
    sim.pos_to_trace(particles, i, contact_sub)

    # Exposed to Infected transition
    sim.exposed_to_infected(particles)
    
    # True Qurantined to True Isolated transition
    sim.quat_to_isot(particles)
    
    # False Qurantined to Susceptible transition
    sim.quaf_to_sus(particles)
    
    # Infected to Recovered transition
    sim.infected_to_recovered(particles)
    
    # Infected to Severe Infected transition
    sim.infected_to_severe_infected(particles, i)
    
    # False Isolated to Severe Infected transition
    sim.isof_to_sus(particles)
    
    # True Isolated to Recovered transition
    sim.isot_to_rec(particles)
    
    # True Isolated to Severe Infected transition
    sim.isot_to_sevinf(particles, i)
    
    # True Positive to True Qurantined/Isolated transition
    sim.tp_to_tqiso(particles, i)
    
    # False Positive to False Isolated transition
    sim.fp_to_fiso(particles, i)
    
    # Severe Infected to Dead/Recovered transition
    sim.severe_infected_to_dead_recovered(particles, i)
    
    #plot the epidemic states
    if i>=plot_freq and i%plot_freq==0:
        plot = particles.plot(sim, i)

# Save the calibration model to the .csv file
model = pd.DataFrame(particles.epidemic_state, columns=['state'])

model['time'] = pd.DataFrame(particles.time_cur_state)
model['testing'] = pd.DataFrame(particles.test_res)
model['app'] = pd.DataFrame(particles.app)
model['ages'] = pd.DataFrame(particles.ages)
model.to_csv("model.csv")
np.savetxt("x.txt", particles.x)
np.savetxt("v.txt", particles.v)
with open('cell.npy', 'wb') as f:
    np.save(f, particles.contact_cell)
    
