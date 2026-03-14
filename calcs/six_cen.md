# 6CEN Rule of Thumb Calculation

This calculator implements the **6CEN** rule of thumb, a commonly used approximation in Health Physics for estimating the exposure rate from a gamma-emitting point source.

## Formula
```math
Exposure Rate (R/hr @ 1 ft) ≈ 6 \times C \times E \times N
```

### Variables
- **C (Activity):** The activity of the source, typically in Curies (Ci).
- **E (Photon Energy):** The energy of the emitted gamma photon in MeV.
- **N (Photon Abundance):** The fractional yield or abundance of the photon per disintegration (often 1.0 for a 100% yield).
- **Exposure:** The resulting estimated exposure rate at 1 foot distance, generally given in Roentgens per hour (R/hr).

## Features
The application supports isolating and solving for *any* of the four variables:
1. **Activity (C):** `C = Exposure / (6 * E * N)`
2. **Photon Energy (E):** `E = Exposure / (6 * C * N)`
3. **Photon Abundance (N):** `N = Exposure / (6 * C * E)`
4. **Exposure Rate:** Default calculation solving for the rate.

*Note: This rule of thumb generally applies to distances of 1 foot and is a rough approximation intended for quick field estimates involving gamma and X-ray emission.*
