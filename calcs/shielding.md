# Shielding Calculation

The **Shielding (Half Value Layer)** calculator estimates the reduction of radiation exposure when passing through physical barriers. It utilizes the Half-Value Layer (HVL) principle, which measures how many layers of thickness are required to attenuate the radiation rate by half.

## Formula
```math
Final Exposure = Initial Exposure \times 0.5^{(\text{Number of HVL})}
```

### Variables
- **Initial Exposure:** The raw radiation exposure rate entering the shielding structure.
- **Final Exposure:** The transmitted radiation rate exiting the far side of the shielding.
- **Number of HVL ($N_{HVL}$):** The total thickness of the shielding, expressed as multiples of the element's specific Half-Value Layer length. 

## Features
1. **Final Exposure:** Evaluates the resulting exposure passed through a specific thickness. 
2. **Initial Exposure:** Reverse calculation estimating what raw exposure hitting the shield must have been, given the transmitted exposure.
3. **Number of HVL (In Progress):** Evaluating necessary layer thickness between boundaries (supported dynamically in application scaling).

## Graphical Overviews
An exponential attenuation dropoff curve titled `Dropoff Over HVL` maps how radiation diminishes logarithmically as the physical number of generic HVLs increase within a wall or barrier.
