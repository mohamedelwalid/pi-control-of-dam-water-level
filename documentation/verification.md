# Verification and provenance

## Original evidence

The submitted group report documents:

- the reservoir mass-balance equation;
- `A = 10 m^2`, `k = 2.5`, `Kp = -2`, `Ki = -0.1`;
- `href = 5 m`, nominal `Qin = 0.5 m^3/s` and initial level `h(0) = 5 m`;
- a Simulink feedback model with actuator saturation;
- a 1000-second simulation;
- a random inflow disturbance updated every two minutes;
- band-limited white measurement noise;
- IAE as the reported performance measure.

## What was reconstructed

The original `.m` and `.slx` files were not preserved. All source files in this repository were created during the portfolio review from the equations, table values, diagram and scenario descriptions in the report.

## Reproducibility checks

`verify_project.m`:

1. validates parameter signs and actuator bounds;
2. rebuilds the Simulink model;
3. runs all three MATLAB scenarios;
4. verifies finite metrics and conservative level bounds;
5. checks that the expected figures and CSV file were generated.

## Claims intentionally not made

- No claim that the reconstructed numerical traces are identical to the lost original files.
- No claim of validation against a physical dam.
- No claim that the controller is safe for real infrastructure.
- No individual-authorship claim for the original four-person report.

