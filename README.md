# Particle-Based-COVID-19-Simulator
## Requirements:
1. OS Windows/Linux/Mac.
2. MATLAB R2019/R2020. 

## Particle-Based COVID-19 Simulator with Contact Tracing and Testing. 

Link to the paper: https://ieeexplore.ieee.org/document/9372866

Link to the video: https://www.youtube.com/watch?v=BJfjmWfi6ac&feature=youtu.be 

<img src="https://raw.githubusercontent.com/IS2AI/Particle-Based-COVID19-Simulator/main/particles_based_epidemic_simulation.gif">

### How to use?
In order to replicate results in the paper for the Lecco province, run the **main_lecco.m** file
by setting the *tracing_ratio (beta)* and *testing_rate (theta)* parameters as in the paper.
If you are interested in simulating for a new region then you need to open **main.m** file and calibrate the model by setting new parameters. 

## Vaccination Strategies for COVID-19: Effective and Sterilizing Immunization Cases. 

Link to the video: https://www.youtube.com/watch?v=z2j4hcmmOwc

### How to use?
- To calibrate the model, use **main_v2.m** script. It is basically a modified version of the **main.m** script. 
We included an additional state, age, to make transitions from Infected/Isolated state to the Severely Infected state based on ages of particles. Then, you can use the calibrated model to simulate different vaccination strategies. You can also
download the calibrated model for the province of Lecco from [here](https://drive.google.com/drive/folders/1JbNz1FaX1_lCMfWsKwQ-ZWPr47z7v6eA?usp=sharing). 
- To simulate effective immunization cases for particles above 19, use **effective_vaccination.m** script.
- To simulate effective immunization cases for particles between 19-69, use **effective_vaccination_v2.m** script.
- To simulate sterilizing immunization cases for particles above 19, use **sterilizing_vaccination.m** script.
- To simulate sterilizing immunization cases for particles between 19-69, use **sterilizing_vaccination_v2.m** script.

# Note:
If you use this code in your research, please cite the following paper:
```
@ARTICLE{9372866,
  author={A. {Kuzdeuov} and A. {Karabay} and D. {Baimukashev} and B. {Ibragimov} and H. A. {Varol}},
  journal={IEEE Open Journal of Engineering in Medicine and Biology}, 
  title={Particle-Based COVID-19 Simulator with Contact Tracing and Testing}, 
  year={2021},
  volume={},
  number={},
  pages={1-1},
  doi={10.1109/OJEMB.2021.3064506}}
```


