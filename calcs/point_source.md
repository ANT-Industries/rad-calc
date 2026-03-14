# Point Source Calculation (Inverse Square Law)

This calculation utilizes the **Inverse Square Law**, mapping how the intensity of radiation from a concentrated point source decreases proportionally to the square of the distance from that source.

## Formula
```math
\frac{I_1}{I_2} = \frac{(D_2)^2}{(D_1)^2} \implies I_1 = I_2 \times \left(\frac{D_2}{D_1}\right)^2
```

### Variables
- **Exposure Rate 1 ($I_1$):** Exposure rate at distance 1.
- **Exposure Rate 2 ($I_2$):** Exposure rate at distance 2.
- **Distance 1 ($D_1$):** The first distance measurement point.
- **Distance 2 ($D_2$):** The second distance measurement point.

## Features
You can calculate any missing component when three variables are known:
1. **Exposure Rate 1:** `ER1 = ER2 * (D2 / D1)^2`
2. **Exposure Rate 2:** `ER2 = ER1 * (D1 / D2)^2`
3. **Distance 1:** `D1 = √((ER2 / ER1) * D2^2)`
4. **Distance 2:** `D2 = √((ER1 / ER2) * D1^2)`

## Graphical Overviews
The tool also plots the `Exposure Over Distance` on a dynamically generated chart. This visually reinforces the rapid non-linear falloff of radiation dose as distance increases from a point source.
