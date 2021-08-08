import numpy as np
import math
import particles
import pickle


class Simulator(): 
    def __init__(self):
        '''
        The Simulator object contains model parameters for the epidemic 
        
        simulation of the population of interest. Particles move in a 2D
        
        map represented by a square with x limits (-1, 1) and y limits (-1, 1).
        '''
        self.NUMBER_OF_PARTICLES = 5000 
        self.INITIAL_EXPOSED = 50
        self.AGE_GROUPS = np.array([1, 2, 3, 4, 5, 6, 7, 8, 9])
        self.AGE_DISTRS = [500, 500, 500, 500, 500, 500, 500, 500, 1000]
        
        self.SIMULATION_LENGTH = 10
        self.INIT_V_MAX = 1
        self.KT = 20
        self.KA = 10
        self.KDT_FREQ = 10
        self.MORTALITY_RATE = 0.15
        self.MOR_IMM1 = 0.52
        self.MOR_IMM2 = 0.95
        
        self.TESTING_RATE = 0.5
        self.TRACING = 0
        self.NTEST = 0
        self.TEST_SN = 0.95
        self.TEST_SP = 0.99
        
        self.TRANSMISSION_RATE_EXPOSED = 0.7
        self.TRANSMISSION_RATE_SEVERE_INFECT = 0.3
        self.TRANSMISSION_RATE_QUA = 0.3
        self.SIR = [0, 0.1, 0.3, 0.8, 0.15, 0.6, 0.22, 0.51, 0.93]
        self.SER = 0.093
        self.SIR_VAC = [i*0.05 for i in self.SIR]
    
        self.mean_dst = 1/math.sqrt(self.NUMBER_OF_PARTICLES)
        self.init_cont_threshold = self.mean_dst/self.KT
        self.speed_gain = self.INIT_V_MAX/self.KA
        self.delta_t = self.init_cont_threshold/self.INIT_V_MAX
        self.number_of_iter = math.ceil(self.SIMULATION_LENGTH/self.delta_t)    
        
        self.DAILY_VAC = 2
        self.VAC_FLOAT = self.DAILY_VAC*self.NUMBER_OF_PARTICLES/(1000*self.delta_t)
        self.VAC_FLOOR = math.floor(self.VAC_FLOAT)
        self.VAC_CEIL = math.ceil(self.VAC_FLOAT)
        self.RAND_VAC = 1 # 1 for vaccination; 0 for no vaccination
        self.VAC_AGE = 0 # 1 for random all, 0 for age-based vaccination
        
        self.T_IMM1 = math.ceil(12/self.delta_t)*self.delta_t
        self.T_IMM2 = math.ceil(28/self.delta_t)*self.delta_t
        self.T_INF = 4
        self.T_EXP = 2
         
        
    def susceptible_to_exposed(self, model, susceptible_contacted): 
        '''
        Class method to transition epidemic status of the particles from 
        susceptible to exposed.
        '''
        
        model.epidemic_state[susceptible_contacted]=1
        model.time_cur_state[susceptible_contacted]=0
      
        
    def pos_to_trace(self, model, i, contact):
        '''
        Class method to transition epidemic status of the particles from 
        susceptible to exposed.
        '''
  
        ind_recent_inf = np.where(model.test_res>=(i-1))
        filtered_by_app = np.where(model.app[ind_recent_inf]==1)
        to_iter = np.intersect1d(contact, filtered_by_app)
                
        for k in range(len(to_iter)):
            if type(model.contact_cell[k, 0])!=list:
                continue
            else:
                m = len(model.contact_cell[k, 0])
            for j in range(m):
                if (model.contact_cell[k, 1][j]>=(self.i*self.delta_t-self.T_INF)):
                    if model.epidemic_state[model.contact_cell[[k, 0], j]]==0:
                        model.epidemic_state[model.contact_cell[[k, 0], j]] = 9
                        model.time_cur_state[model.contact_cell[[k, 1], j]] = 0
                    elif model.epidemic_state[model.contact_cell[[k, 0], j]]==1:
                        model.epidemic_state[model.contact_cell[[k, 0], j]] = 5
                        
                    elif model.epidemic_state[model.contact_cell[[k, 0], j]]==2:
                        model.epidemic_state[model.contact_cell[[k, 0], j]] = 6
    
    
    def exposed_to_infected(self, model): 
        '''
        Class method to transition epidemic status of the particles from 
        Exposed to Infected state. 
        '''
        
        to_inf = np.where((model.epidemic_state==1) & (model.time_cur_state >= self.T_EXP))  
        model.epidemic_state[to_inf] = 2
        model.time_cur_state[to_inf] = 0
        
        
    def infected_to_recovered(self, model):
        '''
        Class method to transition epidemic status of the particles from 
        Infected to Recovered state. 
        '''
        
        infected_passed_t_inf = np.where((model.epidemic_state==2) & (model.time_cur_state >= self.T_INF))
        
        model.epidemic_state[infected_passed_t_inf] = 3

    
    def infected_to_severe_infected(self, model, i): 
        '''
        Class method to transition epidemic status of the particles from 
        Infected to Severe Infected. 
        '''
        
        for i in self.AGE_GROUPS:
            ind_sevinf = np.where((model.epidemic_state==2)&(model.ages==i)&(model.vac_imm==0))
            sir = self.SIR[i-1]
            if (len(ind_sevinf[0])>0):
                  temp_ar = np.random.random((len(ind_sevinf[0]), 1))
                  fil = np.where(temp_ar<(self.SIR[i-1]*self.delta_t))
                  to_sev_inf = ind_sevinf[0][fil[0]]
                  model.epidemic_state[to_sev_inf] = 7

            ind_sevinfvac = np.where((model.epidemic_state==2)&(model.ages==i)&(model.vac_imm==1), 1, 0)
            if (len(ind_sevinfvac)>0):
                  temp_ar = np.random.random((len(ind_sevinfvac), 1)) 
                  model.epidemic_state[ind_sevinfvac[temp_ar<(self.SIR_VAC[i-1]*self.delta_t)]] = 7


    def severe_infected_to_dead_recovered(self, model, i):
        '''
        Class method to transition epidemic status of the particles from 
        Severe Infected to Dead/Recovered state. 
        '''
        
        temp = np.random.rand(self.NUMBER_OF_PARTICLES, 1)
        ind_end_severe_inf = np.where((model.time_cur_state >= self.T_INF) & (model.epidemic_state == 7) & (temp>self.MORTALITY_RATE))
        model.epidemic_state[ind_end_severe_inf] = 3 
        ind_severe_inf = np.where((model.time_cur_state >= self.T_INF) & (model.epidemic_state == 7) & (temp<self.MORTALITY_RATE))
        model.epidemic_state[ind_severe_inf] = 4
        
    
    def random_vac(self, model, i, vac_iter):
        '''
        Class method for random all and age-based vaccination. 
        '''
        
        if (self.RAND_VAC==1&(self.VAC_AGE==1)):
            
            vac_ind = np.where(((model.vac==0)&((model.epidemic_state==0)|(model.epidemic_state==1)|
                                                  (model.epidemic_state==2)|(model.epidemic_state==3))&(model.ages>self.AGE_GROUPS[1])), 1, 0)
            vac_ind = np.random.permutation(len(vac_ind))
            if len(vac_ind) > vac_iter:
                vac_ind = vac_ind[:vac_iter]
            
            model.vac[vac_ind] = i*self.delta_t
            t_vac = i*self.delta_t - model.vac
            ind_end_imm1 = np.where(((t_vac > self.T_IMM1-self.delta_t)&(t_vac<self.T_IMM1+self.delta_t)&(model.vac>0))&((model.epidemic_state==0)|(model.epidemic_state==3)), 1, 0)
            temp_vac = np.random.random((len(ind_end_imm1), 1))
            model.vac_imm[ind_end_imm1[temp_vac<self.MOR_IMM1]] = 1
            
            ind_end_imm2 = np.where(((t_vac > self.T_IMM2-self.delta_t)&(t_vac<self.T_IMM2+self.delta_t)&(model.vac>0))&((model.epidemic_state==0)|(model.epidemic_state==3)), 1, 0)
            temp_vac_imm2 = np.random.random((len(ind_end_imm2), 1))
            model.vac_imm[ind_end_imm2[temp_vac_imm2<self.MOR_IMM2]] = 1
            
        elif (self.RAND_VAC==1&(self.VAC_AGE==0)):

            not_vac_ind = np.where((model.vac==0)&(model.epidemic_state==0)|(model.epidemic_state==1)|
                                                 (model.epidemic_state==2)|(model.epidemic_state==3), 1, 0)
            
            if sum(not_vac_ind &(model.ages==self.AGE_GROUPS[8]))>0:
                vac_ind = np.where((not_vac_ind==1)&(model.ages==self.AGE_GROUPS[8]))  
                order = np.random.permutation(len(vac_ind[0]))
                vac_ind = vac_ind[0][order]
                if len(vac_ind) > vac_iter:
                    vac_ind = vac_ind[:vac_iter]
                model.vac_groups[8] += len(vac_ind)
                
            elif sum(not_vac_ind &( model.ages == self.AGE_GROUPS[7]))>0:
                vac_ind = np.where((not_vac_ind==1)&( model.ages == self.AGE_GROUPS[7]))  
                order = np.random.permutation(len(vac_ind[0]))
                vac_ind = vac_ind[0][order]
                if len(vac_ind) > vac_iter:
                    vac_ind = vac_ind[:vac_iter]
                model.vac_groups[7] += len(vac_ind)
                
            elif sum(not_vac_ind &( model.ages == self.AGE_GROUPS[6]))>0:
                vac_ind = np.where((not_vac_ind==1)&( model.ages == self.AGE_GROUPS[6]))  
                order = np.random.permutation(len(vac_ind[0]))
                vac_ind = vac_ind[0][order]
                if len(vac_ind) > vac_iter:
                    vac_ind = vac_ind[:vac_iter]
                model.vac_groups[6] += len(vac_ind)
                
            elif sum(not_vac_ind &( model.ages == self.AGE_GROUPS[5]))>0:
                vac_ind = np.where((not_vac_ind==1)&( model.ages == self.AGE_GROUPS[5]))  
                order = np.random.permutation(len(vac_ind[0]))
                vac_ind = vac_ind[0][order]
                if len(vac_ind) > vac_iter:
                    vac_ind = vac_ind[:vac_iter]
                model.vac_groups[5] += len(vac_ind)
            elif sum(not_vac_ind &( model.ages == self.AGE_GROUPS[4]))>0:
                vac_ind = np.where((not_vac_ind==1)&( model.ages == self.AGE_GROUPS[4]))  
                order = np.random.permutation(len(vac_ind[0]))
                vac_ind = vac_ind[0][order]
                if len(vac_ind) > vac_iter:
                    vac_ind = vac_ind[:vac_iter]
                model.vac_groups[4] += len(vac_ind)
            
            elif sum(not_vac_ind &( model.ages == self.AGE_GROUPS[3]))>0:
                vac_ind = np.where((not_vac_ind==1)&( model.ages == self.AGE_GROUPS[3]))  
                order = np.random.permutation(len(vac_ind[0]))
                vac_ind = vac_ind[0][order]
                if len(vac_ind) > vac_iter:
                    vac_ind = vac_ind[:vac_iter]
                model.vac_groups[3] += len(vac_ind)
                
                
            #vac_ind[vac_ind] = i*self.delta_t
            model.vac[vac_ind] = i*self.delta_t
            t_vac = i*self.delta_t - model.vac
        
            ind_end_imm1 = np.argwhere(((t_vac > self.T_IMM1-self.delta_t)&(t_vac<self.T_IMM1+self.delta_t)&(model.vac>0))&((model.epidemic_state==0)|(model.epidemic_state==3)))
            temp_vac = np.random.random((len(ind_end_imm1), 1))
            model.vac_imm[ind_end_imm1[temp_vac<self.MOR_IMM1]] = 1
            
            ind_end_imm2 = np.argwhere(((t_vac > self.T_IMM2-self.delta_t)&(t_vac<self.T_IMM2+self.delta_t)&(model.vac>0))&((model.epidemic_state==0)|(model.epidemic_state==3)))
            temp_vac_imm2 = np.random.random((len(ind_end_imm2), 1))
            model.vac_imm[ind_end_imm2[temp_vac_imm2<self.MOR_IMM2]] = 1
         
            
    def tp_to_tqiso(self, model, i):
        '''
        Class method to transition True Positive tested particles to 
        True Quarantined or True Isolated states. 
        '''
        
        sir_ind = np.where(((model.epidemic_state==1)|(model.epidemic_state==2)))
        temp_ar = np.random.rand(self.NUMBER_OF_PARTICLES, 1)
        temp_test = np.zeros((self.NUMBER_OF_PARTICLES, 1))
        temp_test[sir_ind] = 1
        sir_ind_ts_tp = np.where((temp_test==1) & (temp_ar<(self.delta_t*self.TESTING_RATE*self.TEST_SN)))
        model.test_res[sir_ind_ts_tp] = 1
        int_qua = np.where((model.test_res!=0)&(model.epidemic_state==1))
        model.epidemic_state[int_qua] = 5
        int_iso = np.where((model.test_res==1)&(model.epidemic_state==2))
        model.epidemic_state[int_iso] = 6
        
        
    def fp_to_fiso(self, model, i):
        '''
        Class method to transition False Positive tested particles to
        False Isolated state.
        '''  
        
        sir_ind = np.where(model.epidemic_state==0)
        temp_ar = np.random.rand(self.NUMBER_OF_PARTICLES, 1)
        tempp_test = np.zeros([self.NUMBER_OF_PARTICLES, 1])
        tempp_test[sir_ind] = 1
        sir_ind_ts_fp = np.where((tempp_test==1) & (temp_ar<self.TESTING_RATE*(1-self.TEST_SP)*self.delta_t))
        model.test_res[sir_ind_ts_fp] = 2
        int_iso = np.where((model.test_res!=0)&(model.epidemic_state==0))
        model.epidemic_state[int_iso] = 8
        model.time_cur_state[int_iso] = 0
        
    def isof_to_sus(self, model):
        '''
        Class method to transition epidemic status of the particles from 
        False Isolated to Susceptible super-state. 
        '''
        
        to_sus =np.where((model.epidemic_state==8) & (model.time_cur_state >= self.T_INF))
        model.epidemic_state[to_sus] = 0
        
        
    def quat_to_isot(self, model):
        '''
        Class method to transition epidemic status of the particles from 
        True Quarantined to True Isolated 
        '''
        
        to_isot =np.where((model.epidemic_state==5) & (model.time_cur_state >= self.T_EXP))
        model.epidemic_state[to_isot] = 6
        model.time_cur_state[to_isot] = 0 
        
    def quaf_to_sus(self, model):
        '''
        Class method to transition epidemic status of the particles from 
        False Quarantined. 
        '''
        
        to_sus = np.where(((model.epidemic_state==9) & (model.time_cur_state >= self.T_EXP)))
        
        model.epidemic_state[to_sus] = 0
        model.time_cur_state[to_sus] = 0 
        
        
    def isot_to_rec(self, model):
        '''
        Class method to transition epidemic status of the particles from 
        True Isolated to Recovered state. 
        '''
        
        to_rec = np.where((model.epidemic_state==6) & (model.time_cur_state >= self.T_INF))
        
        model.epidemic_state[to_rec] = 3
        
        
    def isot_to_sevinf(self, model, i):
        '''
        Class method to transition epidemic status of the particles from 
        True Isolated to Severe Infected sub-state.
        '''

        for i in self.AGE_GROUPS:
            ind_sevinf = np.where((model.epidemic_state==6)&(model.ages==i)&(model.vac_imm==0), 1, 0)

            if (len(ind_sevinf)>0):
                  temp_ar = np.random.random((len(ind_sevinf), 1)) 
                  temp_diff = temp_ar< self.SIR[i-1]*self.delta_t
                  model.epidemic_state[ind_sevinf[temp_diff]] = 7
            
            ind_sevinfvac = np.where((model.epidemic_state==6)&(model.ages==i)&(model.vac_imm==1), 1, 0)
            if (len(ind_sevinfvac)>0):
                  temp_ar = np.random.random((len(ind_sevinfvac), 1)) 
                  model.epidemic_state[ind_sevinfvac[temp_ar<(self.SIR_VAC[i-1]*self.delta_t)]] = 7
  
        



