# Plane Source Calculation

The **Plane Source** calculation estimates exposure rate variations over distance from a 2-dimensional radioactive surface (like ground contamination or a flat disk of material).

## Behavior
Plane sources act more like an infinite uniform sheet close up, and slowly resemble a point source as distance radically increases. The calculation hinges on defining an effective plane boundary denoted by the surface's **radius**.

The exposure model is divided empirically into distinct radial boundaries relative to the source size:
- Inner core ($R_1$): `10% of radius` 
- Outer transition ($R_7$): `70% of radius`

### Variables
- **Radius ($r$):** The effective physical radius of the plane source.
- **Exposure Rate 1 & 2:** Exposure measured at distance 1 and distance 2.
- **Distance 1 & 2:** Distance orthogonal from the center of the plane layer.

## Calculation Logic
Depending on the user's distance in relation to the radial boundaries, scaling changes dramatically:
1. **At or inside $R_1$ ($d \le 0.1 \times \text{radius}$):** The source acts as an infinite plane. **Exposure rate stays relatively constant.**
2. **Intermediate Phase ($R_1 < d \le R_7$):** Exposure drops steeply (by a factor of ~3).
3. **Beyond Transition Phase ($d > R_7$):** The plane source transitions into a normal inverse square drop-off, acting identically to a generic point source at a distance.

## Graphical Overviews
The calculator plots the predicted `Exposure Over Distance` on a dynamically generated chart. The transitions from constant exposure, to steep drop, out to inverse-square behavior is clearly displayed.
