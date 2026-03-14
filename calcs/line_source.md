# Line Source Calculation

The **Line Source** calculation models the exposure rate falloff from a uniform linear source of radiation, such as a contaminated pipe or a cylindrical tube.

## Behavior
Unlike a point source, which drops strictly by $1/r^2$ everywhere, a linear source exhibits complex geometry-dependent attenuation:

1. **Near Field (distance $\le L/2$):** 
   Close to the middle of the line source, it approximates an infinite cylinder, and exposure rate drops off inversely proportional to the **first power** of distance ($1/r$).
2. **Far Field (distance $> L/2$):** 
   At a distance far beyond half the length of the source, the line begins to appear like a singular point, and exposure transitions into following the **Inverse Square Law** ($1/r^2$).

### Variables
- **Length ($L$):** Physical length of the line source.
- **Exposure Rate 1 & 2:** Exposure measured at distance 1 and distance 2.
- **Distance 1 & 2:** Distance vectors orthogonal to the source.

## Calculation Logic
The app dynamically transitions the scaling exponent based on the user's relation to `L/2`:
- If both distances are in the **Near Field**, it strictly solves using `(D1 / D2)`.
- If both distances are in the **Far Field**, it strictly solves using `(D1 / D2)^2`.
- If one distance is near-field and the other is far-field, the app splits the calculation into two continuous stages, scaling by $1/r$ out to $L/2$, and then by $1/r^2$ for the remainder of the length. 

## Graphical Overviews
The included charting graph overlays exposure across varying distances to demonstrate how the curve slope breaks and steepens at the transitional $L/2$ boundary.
