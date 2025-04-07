# Optimization-Based Signal Generator

This project provides an optimization-based signal generator designed to create worst-case signals for closed-loop systems. The core of the system is a flexible signal generator with an objective function that can be adapted to various optimization methods.

[![DOI](https://zenodo.org/badge/961921832.svg)](https://doi.org/10.5281/zenodo.15167317)

## About  
This code was developed as part of the master's thesis  
*"Optimierungsbasierte Generierung von Testsignalen für die Analyse von Regelkreisen"*  
[Thesis Link](https://catalogplus.tuwien.at/permalink/f/8j3js/UTW_alma71156034990003336).  

The research was conducted at the **Austrian Institute of Technology (AIT)** within the  
**Vision, Automation & Control (VAC) Center**, specifically in the  
**Complex Dynamical Systems (CDS) Group**  
[CDS Group](https://www.ait.ac.at/themen/complex-dynamical-systems).  
This work was carried out in collaboration with the **Technische Universität Wien (TU Wien)**,  
particularly the **Institute of Analysis and Scientific Computing (ASC)**  
[ASC Institute](https://www.tuwien.at/mg/asc).  

This project extends the prior work conducted by 
**Cornelia Geischläger**  
[Previous Thesis](https://catalogplus.tuwien.at/permalink/f/8j3js/UTW_alma21139941830003336).  

## Project Structure
The project is organized into three main folders, each containing essential functions and files:

### 1. **SignalGenerator**
This folder contains the primary signal generation functions:
- **`signalGenerator.m`**
  - Validates input parameters and offers an option to plot the generated signal.
- **`coreGenerator.m`**
  - A C-compatible code that produces the signal using the segment function.
- **`segments.m`**
  - Contains the segment functions used to generate the signal. These can be customized or extended based on your requirements.

### 2. **optimization**
This folder contains functions and data related to optimization:
- **`objectGeneratorFnc.m`**
  - Defines the objective function for optimization.
- **`demoFncSurrogate.m`**
  - A MATLAB-based surrogate algorithm from the Global Optimization Toolbox designed to optimize the simulation of a nonlinear spring-mass system.
- **`demoFncMC.m`** 
  - A monte carlo simulation designed to simulate the nonlinear spring-mass system.
- **`MaxRateOfChangeDeterminationFnc.m`**
  - Determines the maximum rate of change the optimization/signal generator can handle.
- **`startingValuesAllData.mat`**
  - Contains all starting values, including those from the demo. Use this for a different closed-loop system by adding your own values. (e.g., entry 1 corresponds to three change points.)
- **`startingValuesForSpringMassSystem.mat`**
  - Contains starting values specific to the spring-mass system demo.
- **`costMae.m`**
  - A simple costfunction mean absolute error.
- **`costRmse.m`**
  - A simple costfunction root mean square error.

### 3. **models**
This folder includes the necessary Simulink and MATLAB files for running simulations:
- **`initMechSysWithFriction.m`**
  - Initializes the spring-mass system with friction.
- **`simSpringMassSystem.m`**
  - The primary simulation function used for optimization.
- **`systemMechanicalFriction.slx`**
  - The Simulink model of the spring-mass system demo.

## Additional Files
- **`demo.m`**
  - A demonstration script showcasing how to use the provided functions and structure.
- **`plotResults.m`**
  - A utility for visualizing the generated signals and simulation results.

## How to Use (For Non-Demo Applications)
To use the Optimization-Based Signal Generator for your closed-loop system, follow these steps:

1. **Create a Simulation Function**
   - Define a simulation function as a function handle `@(x)Fnc(x)` that takes the output of `signalGenerator.m` as input. 
   - This function should simulate the closed-loop system using the provided signal. 
   - The output must be atleast two equally sized vectors: `[y_in, y_out]`, where `y_in` is the input signal and `y_out` is the system's output. For reference, check the demo function `simSpringMassSystem.m`.

2. **Create a Cost Function**
   - Define a cost function as a function handle `@Fnc` that takes `y_in` and `y_out` as inputs. 
   - Example cost functions can be found as the demo functions `costMae.m` and `costRmse.m`.

3. **Define the Number of Change Points**
   - Choose the number of change points that best fits your simulation (default is 4).

4. **Set the Sampling Time (Ts)**
   - `Ts` represents the interpolation fineness, defining the smallest time step for the simulation (default is `1e-2`).

5. **Determine the Maximum Rate of Change**
   - Use `maxRateOfChanceDeterminationFnc.m` to calculate this value by providing the maximum rate of change your closed-loop system can handle. 
   - *Note:* This function assumes the total signal duration is 1 second.

6. **Choose an Optimization Algorithm**
   - If you have the Global Optimization Toolbox, you can use the surrogate algorithm as demonstrated in `DemoFncSurrogate.m`. 
   - Alternatively, any optimizer can be used with `objectGeneratorFnc.m`. 
   - To ensure proper function calls, use the following syntax:
     ```matlab
     @(x) objectGeneratorFnc(x, NT, CostFunction, Sim, Ts, maxRateOfChance);
     ```
     - `NT` = Number of change points
     - `costFunction` = Cost function handle (Step 2)
     - `sim` = Simulation function handle (Step 1)
     - `ts` = Set the Sampling Time (Step 4)
     - `maxRateOfChance` = Set the Maxium Rate of Chance (Step 5)

7. **Set Starting Values**
   - If using the surrogate algorithm (`demoFncSurrogate`) or the monte carlo simulation (`demoFncMC`), load `startingValuesAllData.mat` in the same way as `startingValuesForSpringMassSystem.mat` is used in the demo. 
   - If no starting values are needed, pass a scalar instead. These starting values can also be applied to the optimizer of your choice.

8. **Plot the Results**
   - Use `plotResults.m` with the following syntax to visualize the input and output signals:
     ```matlab
     plotResult(parameters, nChanceoverPoints, sim, costFunction, ts, opt);
     ```
     - `parameters` = Optimized signal parameters
     - `nChanceoverPoints` = Number of chanceover points
     - `costFunction` = Cost function handle
     - `sim` = Simulation function handle
     - `ts` = Sampling time
     - `opt` = optionstruct
        - opt.noSimTime     - turn off if your sim function has no extra outputs for the simtime
        - opt.noU           - turn off if your sim function has no extra outputs for the control variable

## Getting Started
1. Ensure all required dependencies (e.g., MATLAB Global Optimization Toolbox) are installed.
2. Run `demo.m` to see an example of the system in action.
3. Customize the segment functions in `segments.m` or adjust starting values in the provided `.mat` files for your specific application.

## Notes
- The project is modular, allowing you to extend or modify individual components with ease.
- For best results, carefully adjust the starting values and segment functions to suit your system's characteristics.

For any issues or questions, please refer to the comments within the code or contact the project maintainers.

