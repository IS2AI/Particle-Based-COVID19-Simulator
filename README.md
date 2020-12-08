# Particle-Based-COVID19-Simulator
Particle-based COVID-19 simulator with contact tracing and testing modules. 

Link to the paper: https://www.medrxiv.org/content/10.1101/2020.12.07.20245043v1

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
If you use this code in research, please cite the following paper:
```
@article {Kuzdeuov2020.12.07.20245043,
	author = {Kuzdeuov, Askat and Karabay, Aknur and Baimukashev, Daulet and Ibragimov, Bauyrzhan and Varol, Huseyin Atakan},
	title = {Particle-Based COVID-19 Simulator with Contact Tracing and Testing},
	elocation-id = {2020.12.07.20245043},
	year = {2020},
	doi = {10.1101/2020.12.07.20245043},
	URL = {https://www.medrxiv.org/content/early/2020/12/08/2020.12.07.20245043},
	eprint = {https://www.medrxiv.org/content/early/2020/12/08/2020.12.07.20245043.full.pdf},
	journal = {medRxiv}
}
```


