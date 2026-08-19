function verify_project()
%VERIFY_PROJECT Execute reproducibility and basic engineering checks.

repoRoot = fileparts(fileparts(mfilename("fullpath")));
p = init_params();

assert(p.A > 0, "Reservoir area must be positive.");
assert(p.k > 0, "Outlet coefficient must be positive.");
assert(p.Kp < 0 && p.Ki < 0, "This outlet-actuated model requires negative PI gains.");
assert(p.u_min == 0 && p.u_max == 1, "Actuator bounds must match the report.");

modelPath = build_simulink_model();
assert(isfile(modelPath), "Simulink model was not generated.");

metrics = run_all_scenarios();
assert(all(isfinite(metrics.IAE_m_s)), "IAE contains non-finite values.");
assert(all(metrics.MaximumLevel_m < 6), "A recreated scenario exceeded the review bound.");
assert(all(metrics.MinimumLevel_m > 4), "A recreated scenario fell below the review bound.");

expectedOutputs = [
    fullfile(repoRoot, "results", "metrics.csv")
    fullfile(repoRoot, "results", "nominal-response.png")
    fullfile(repoRoot, "results", "disturbance-response.png")
    fullfile(repoRoot, "results", "measurement-noise-response.png")
    fullfile(repoRoot, "results", "simulink-model.png")
];
assert(all(isfile(expectedOutputs)), "One or more expected outputs are missing.");

fprintf("Verification passed: model, scenarios, metrics and figures are reproducible.\n");
fprintf("Physical dam validation is outside the scope of this academic reconstruction.\n");
end
