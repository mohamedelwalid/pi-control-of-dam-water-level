function metrics = run_all_scenarios()
%RUN_ALL_SCENARIOS Recreate the report's nominal, disturbance and noise cases.

repoRoot = fileparts(fileparts(mfilename("fullpath")));
resultDir = fullfile(repoRoot, "results");
if ~isfolder(resultDir)
    mkdir(resultDir);
end

p = init_params();
t = (0:p.dt:p.stop_time)';

nominalInflow = p.Q_in_nominal * ones(size(t));
zeroNoise = zeros(size(t));

rng(4105, "twister");
disturbanceValues = rand(ceil(p.stop_time / p.disturbance_period) + 1, 1);
disturbanceIndex = floor(t / p.disturbance_period) + 1;
disturbedInflow = disturbanceValues(disturbanceIndex);

rng(4125, "twister");
noiseValues = p.noise_std * randn(ceil(p.stop_time / p.noise_hold) + 1, 1);
noiseIndex = floor(t / p.noise_hold) + 1;
measurementNoise = noiseValues(noiseIndex);

nominal = simulateCase(t, nominalInflow, zeroNoise, p);
disturbance = simulateCase(t, disturbedInflow, zeroNoise, p);
noise = simulateCase(t, nominalInflow, measurementNoise, p);

metrics = table( ...
    ["Nominal"; "Inflow disturbance"; "Measurement noise"], ...
    [nominal.IAE(end); disturbance.IAE(end); noise.IAE(end)], ...
    [max(abs(nominal.error)); max(abs(disturbance.error)); max(abs(noise.error))], ...
    [max(nominal.level); max(disturbance.level); max(noise.level)], ...
    [min(nominal.level); min(disturbance.level); min(noise.level)], ...
    VariableNames=["Scenario", "IAE_m_s", "PeakAbsoluteError_m", "MaximumLevel_m", "MinimumLevel_m"]);

writetable(metrics, fullfile(resultDir, "metrics.csv"));
save(fullfile(resultDir, "simulation_results.mat"), "p", "nominal", "disturbance", "noise", "metrics");

plotScenario(nominal, p, "Nominal regulation", fullfile(resultDir, "nominal-response.png"));
plotScenario(disturbance, p, "Piecewise-constant inflow disturbance", fullfile(resultDir, "disturbance-response.png"));
plotScenario(noise, p, "Measurement-noise response", fullfile(resultDir, "measurement-noise-response.png"));

disp(metrics);
end

function result = simulateCase(t, inflow, measurementNoise, p)
n = numel(t);
level = zeros(n, 1);
measuredLevel = zeros(n, 1);
error = zeros(n, 1);
control = zeros(n, 1);
integralError = zeros(n, 1);
IAE = zeros(n, 1);

level(1) = p.h_initial;
measuredLevel(1) = level(1) + measurementNoise(1);
error(1) = p.h_ref - measuredLevel(1);

for i = 2:n
    integralError(i) = integralError(i - 1) + error(i - 1) * p.dt;
    rawControl = p.Kp * error(i - 1) + p.Ki * integralError(i);
    control(i) = min(max(rawControl, p.u_min), p.u_max);

    levelRate = (inflow(i - 1) - p.k * control(i)) / p.A;
    level(i) = level(i - 1) + levelRate * p.dt;
    measuredLevel(i) = level(i) + measurementNoise(i);
    error(i) = p.h_ref - measuredLevel(i);
    IAE(i) = IAE(i - 1) + abs(error(i - 1)) * p.dt;
end

result = struct("time", t, "level", level, "measuredLevel", measuredLevel, ...
    "error", error, "control", control, "inflow", inflow, "IAE", IAE);
end

function plotScenario(result, p, plotTitle, outputPath)
fig = figure("Visible", "off", "Color", "white", "Position", [100 100 1100 720]);
tiledlayout(3, 1, "TileSpacing", "compact", "Padding", "compact");

nexttile;
plot(result.time, result.level, "LineWidth", 1.5, "Color", [0.04 0.45 0.74]);
hold on;
yline(p.h_ref, "--", "Reference", "LineWidth", 1.1, "Color", [0.2 0.2 0.2]);
ylabel("Level (m)");
title(plotTitle);
grid on;

nexttile;
plot(result.time, result.control, "LineWidth", 1.3, "Color", [0.85 0.33 0.10]);
ylabel("Control u");
ylim([-0.05 1.05]);
grid on;

nexttile;
yyaxis left;
plot(result.time, result.inflow, "LineWidth", 1.1);
ylabel("Inflow (m^3/s)");
yyaxis right;
plot(result.time, result.IAE, "LineWidth", 1.3);
ylabel("IAE (m s)");
xlabel("Time (s)");
grid on;

set(findall(fig, "Type", "axes"), ...
    "Color", "white", "XColor", [0.15 0.15 0.15], "YColor", [0.15 0.15 0.15], ...
    "GridColor", [0.72 0.72 0.72], "MinorGridColor", [0.85 0.85 0.85]);
set(findall(fig, "Type", "text"), "Color", [0.12 0.12 0.12]);

exportgraphics(fig, outputPath, "Resolution", 180);
close(fig);
end
