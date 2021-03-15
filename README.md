# Particle-Based-COVID19-Simulator
Particle-based COVID-19 simulator with contact tracing and testing modules. 

Link to the paper: https://ieeexplore.ieee.org/document/9372866

Link to the video: https://www.youtube.com/watch?v=BJfjmWfi6ac&feature=youtu.be 

<img src="https://raw.githubusercontent.com/IS2AI/Particle-Based-COVID19-Simulator/main/particles_based_epidemic_simulation.gif">

## Requirements:
1. OS Windows/Linux/Mac.
2. MATLAB R2019/R2020.

## How to use?
In order to replicate results in the paper for the Lecco province, run the **main_lecco.m** file
by setting the *tracking_rate* and *testing_rate* parameters as in the paper.
If you are interested in simulating for a new region then you need to open **main.m** file and calibrate the model by setting new parameters. 

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


