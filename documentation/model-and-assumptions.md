# Model and assumptions

## Governing equation

The reconstruction follows the mass balance documented in the course report:

```text
A dh/dt = Qin - Qout
Qout = k u
```

This gives:

```text
dh/dt = Qin/A - (k/A)u
```

The controlled variable is reservoir level `h`, while the manipulated variable `u` controls outlet flow. Because a larger command lowers the level, the plant gain from `u` to `h` is negative. With the report's error definition `e = href - h`, both PI gains are therefore negative.

## Assumptions inherited from the report

- Constant horizontal reservoir area.
- Linear relation between actuator command and outlet flow.
- Negligible viscosity, turbulence, leakage and other hydraulic losses.
- No significant sensor, valve or transport delay.
- Normalised actuator command limited to the interval `[0, 1]`.

## Reconstruction assumptions

The report defines band-limited white measurement noise but does not preserve its numerical block parameters. The recreated noise case therefore uses a seeded zero-order-held Gaussian signal with standard deviation `0.02 m` and a one-second update interval. These values are explicitly reconstruction choices and must not be represented as original submission parameters.

The disturbance case follows the report more closely: inflow is a seeded random value between `0` and `1 m^3/s`, updated every 120 seconds.

## Scope limitation

The model is useful for demonstrating feedback-control concepts. It is not suitable for hydraulic design, flood-risk analysis or deployment on critical infrastructure without a nonlinear hydraulic model, actuator dynamics, validated sensing, safety constraints and domain review.

