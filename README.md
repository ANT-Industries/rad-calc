# rad-calc

`rad-calc` is a comprehensive health physics and radiation calculation tool. It provides a suite of calculators to assist with common radiological physics problems, including exposure rate estimations, attenuation, decay, and stay-time calculations.

The project features:
- A cross-platform **Flutter Application** offering a mobile/desktop graphical user interface.
- A **Go MCP Server** (`/mcp`) that exposes these calculators as tools to AI assistants (via the Model Context Protocol) and provides a standalone web-based dashboard using HTTP/SSE.

---

## 🧮 Calculations (`/calcs`)

The core formulas and mathematical foundations for the calculators are documented in the `/calcs` directory:

1. **[6CEN Approximation](calcs/six_cen.md)**
   - Used for estimating the gamma exposure rate from a point source. Provides a quick "rule of thumb" relating activity, energy, and photon abundance to the exposure rate.
   
2. **[Point Source (Inverse Square Law)](calcs/point_source.md)**
   - Calculates exposure rates at different distances from a point source in a vacuum or air, assuming no significant attenuation or scattering.

3. **[Line Source Attenuation](calcs/line_source.md)**
   - Extends the point source concept to a line distribution of radioactivity (e.g., a pipe), calculating the varying exposure rates at perpendicular distances.

4. **[Plane Source Exposure](calcs/plane_source.md)**
   - Determines the exposure rate from a two-dimensional, uniformly contaminated flat surface or disc.

5. **[Radioactive decay (Half-Life)](calcs/half_life.md)**
   - Calculates the exponential decay of a radioactive isotope over time based on its unique half-life, determining initial or final activity.

6. **[Shielding (HVL/TVL)](calcs/shielding.md)**
   - Determines the attenuation of radiation through shielding materials using Half-Value Layers (HVL) and Tenth-Value Layers (TVL).

7. **[Stay Time](calcs/stay_time.md)**
   - Calculates the maximum allowable time a worker can remain in a radiation area based on the current dose rate and their administrative or regulatory dose limits.

---

## 🚀 Getting Started

### MCP Server & Web App
The Go server exposes the calculators as MCP Tools and an interactive standalone web UI.
Navigate to the `mcp` directory and use the built-in scripts:
```bash
cd mcp
./bin/rad-calc -http -port 8080
```

### Docker
You can run the server instantly using Docker from the root:
```bash
docker build -t rad-calc .
docker run -p 8080:8080 rad-calc
```

Or using **Docker Compose**:
```bash
docker compose up -d
```
Then visit `http://localhost:8080`.
