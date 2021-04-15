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

Link to the paper: https://www.medrxiv.org/content/10.1101/2021.03.28.21254468v1 

### How to use?
- To calibrate the model, use **main_v2.m** script. It is basically a modified version of the **main_lecco.m** script. 
We included an additional state, age, to make transitions from the Infected/Isolated state to the Severely Infected state based on the ages of particles. Then, you can use the calibrated model to simulate different vaccination strategies. You can also
download the calibrated model, used in the paper, for the province of Lecco from [here](https://drive.google.com/drive/folders/1JbNz1FaX1_lCMfWsKwQ-ZWPr47z7v6eA?usp=sharing). 
- To simulate effective immunization cases (random vaccination/age based vaccination) for particles above 19, use **effective_vaccination.m** script.
- To simulate effective immunization cases (random vaccination/age based vaccination) for particles between 19-69, use **effective_vaccination_v2.m** script.
- To simulate sterilizing immunization cases (random vaccination/age based vaccination) for particles above 19, use **sterilizing_vaccination.m** script.
- To simulate sterilizing immunization cases (random vaccination/age based vaccination) for particles between 19-69, use **sterilizing_vaccination_v2.m** script.

# Note:
If you use this code in your research, please cite the following papers:
```
@ARTICLE{9372866,
  author={A. {Kuzdeuov} and A. {Karabay} and D. {Baimukashev} and B. {Ibragimov} and H. A. {Varol}},
  journal={IEEE Open Journal of Engineering in Medicine and Biology}, 
  title={A Particle-Based COVID-19 Simulator With Contact Tracing and Testing}, 
  year={2021},
  volume={2},
  number={},
  pages={111-117},
  doi={10.1109/OJEMB.2021.3064506}}
```
```
@article {Karabay2021.03.28.21254468,
	author = {Karabay, Aknur and Kuzdeuov, Askat and Lewis, Michael and Varol, Atakan Huseyin},
	title = {A Vaccination Simulator for COVID-19: Effective and Sterilizing Immunization Cases.},
	elocation-id = {2021.03.28.21254468},
	year = {2021},
	doi = {10.1101/2021.03.28.21254468},
	publisher = {Cold Spring Harbor Laboratory Press},
	URL = {https://www.medrxiv.org/content/early/2021/04/04/2021.03.28.21254468},
	eprint = {https://www.medrxiv.org/content/early/2021/04/04/2021.03.28.21254468.full.pdf},
	journal = {medRxiv}}
```

