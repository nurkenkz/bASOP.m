This project is based on the following paper:
Lee, Donghwan ; Lee, Seungjae ; Karava, Panagiota ; Hu, Jianghai “Simulation-Based Policy Gradient and Its Building Control Application” 2018 Annual American Control Conference (ACC), June 2018, pp.5424-5429
It applies stochastic simulation-based policy gradient method for optimal office building HVAC control system:
- Approximates the gradient of the cost function using simulations
- Uses a gradient descent type algorithm to design a suboptimal control policy
- Assesses its performance through a simulation of building HVAC system
- Compares this method to the finite-horizon LQR state-feedback control policy

MATLAB Files:
1. inputData.m:
        Loads pdf for user actions from pdf_data.mat file
        Loads weather data for dayn from weather2018.mat file
        Initializes all parameters for dynamic state-space model
        Computes state-feedback for LQR
2. outputData.m - generates plots and histogram
3. simulation.m - 24 hour simulation for a given weights and day
4. bASOP.m - main script:
        Picks random day within [1 364] range as dayn
	Calls inputData.m for dayn
	Sets parameters for ß-ASOCP algorithm and runs it N_of_iteration times for initila theta=0
	Simulates (dayn+1) day using new control policy with computed theta and calculates cost
      	Simulates (dayn+1) day using state-feedback for LQR and calculates cost
	Compares both methods in histogram for 1000 samples
WARNING: number of iterations set to 10000, which takes ~15 min. Can be lowered for test purposes.

5. weather2018.mat - real weather data from UW weather station for 2018 with step=15 minutes
6. pdf_data.mat - probability density function of occupant actions based on indoor temperature

FOR MORE DETAIL SEE ECE686ProjNTuktibayev.pptx
