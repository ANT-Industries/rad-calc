# Half-Life Calculation

The **Half-Life** calculator is a multi-purpose tool solving the standard exponential radioactive decay formula. Since radioactive particles decay continuously over time at a consistent rate depending on their specific isotope, you can isolate and find any missing variable.

## Formula
```math
A = A_0 \times e^{(-\lambda \cdot t)} \implies \lambda = \frac{\ln(2)}{T_{1/2}}
```

### Variables
- **Initial Activity ($A_0$):** The starting activity rate before decay begins.
- **Final Activity ($A$):** The remaining activity after a specific span of time has elapsed.
- **Time ($t$):** The total elapsed time between measuring $A_0$ and $A$.
- **Half-Life ($T_{1/2}$):** The constant physical property representing the span of time required for the activity to reduce by exactly half.

## Features
Depending on known values, the calculator solves for the missing variable:
1. **Final Activity:** Computes the remaining activity given an initial amount, a time span, and the specific isotope's half-life.
2. **Initial Activity:** Computes the original activity using decay tracing backwards over known time.
3. **Time:** Extracts the elapsed time between two known activities.
4. **Half-Life:** Determines the specific half-life of an unknown isotope if the initial and final activity drop over a measurable time is recorded.

## Graphical Overviews
The tool continuously updates an `Activity Over Time` chart. The slope visually maps the steady $e^{(-x)}$ decay exponential over the exact duration requested.
