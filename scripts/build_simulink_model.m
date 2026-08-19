function modelPath = build_simulink_model()
%BUILD_SIMULINK_MODEL Recreate the report-level Simulink architecture.
% The top level intentionally mirrors the submitted report. The PI equation
% is expanded inside the PI Controller subsystem for traceability.

repoRoot = fileparts(fileparts(mfilename("fullpath")));
modelDir = fullfile(repoRoot, "models");
resultDir = fullfile(repoRoot, "results");
if ~isfolder(modelDir)
    mkdir(modelDir);
end
if ~isfolder(resultDir)
    mkdir(resultDir);
end

p = init_params();
modelName = "pi_dam_water_level";
modelPath = fullfile(modelDir, modelName + ".slx");

if bdIsLoaded(modelName)
    close_system(modelName, 0);
end
if isfile(modelPath)
    delete(modelPath);
end

new_system(modelName);
open_system(modelName);
set_param(modelName, "StopTime", num2str(p.stop_time), "Solver", "ode45");

add_block("simulink/Sources/Constant", modelName + "/Level reference", ...
    "Value", "p.h_ref", "Position", [40 105 90 135]);
add_block("simulink/Math Operations/Sum", modelName + "/Control error", ...
    "Inputs", "+-", "Position", [130 100 155 140]);
add_block("simulink/Ports & Subsystems/Subsystem", modelName + "/PI Controller", ...
    "Position", [210 92 320 148]);
buildPiSubsystem(modelName + "/PI Controller");
piMask = Simulink.Mask.create(modelName + "/PI Controller");
piMask.Display = "disp('PI(s)')";
piMask.IconOpaque = "opaque";
add_block("simulink/Discontinuities/Saturation", modelName + "/Actuator limits", ...
    "UpperLimit", "p.u_max", "LowerLimit", "p.u_min", "Position", [370 100 440 140]);
add_block("simulink/Math Operations/Gain", modelName + "/Outlet coefficient", ...
    "Gain", "p.k", "Position", [490 100 570 140]);
add_block("simulink/Sources/Constant", modelName + "/Nominal inflow", ...
    "Value", "p.Q_in_nominal", "Position", [485 30 555 60]);
add_block("simulink/Math Operations/Sum", modelName + "/Net flow", ...
    "Inputs", "+-", "Position", [620 75 645 125]);
add_block("simulink/Math Operations/Gain", modelName + "/Inverse area", ...
    "Gain", "1/p.A", "Position", [690 85 755 120]);
add_block("simulink/Continuous/Integrator", modelName + "/Water level", ...
    "InitialCondition", "p.h_initial", "Position", [805 80 835 125]);
add_block("simulink/Sinks/Scope", modelName + "/Level scope", ...
    "Position", [900 80 935 120]);
add_block("simulink/Sinks/To Workspace", modelName + "/Level output", ...
    "VariableName", "level_output", "SaveFormat", "Structure With Time", ...
    "Position", [885 150 970 180]);

add_line(modelName, "Level reference/1", "Control error/1", "autorouting", "on");
add_line(modelName, "Control error/1", "PI Controller/1", "autorouting", "on");
add_line(modelName, "PI Controller/1", "Actuator limits/1", "autorouting", "on");
add_line(modelName, "Actuator limits/1", "Outlet coefficient/1", "autorouting", "on");
add_line(modelName, "Nominal inflow/1", "Net flow/1", "autorouting", "on");
add_line(modelName, "Outlet coefficient/1", "Net flow/2", "autorouting", "on");
add_line(modelName, "Net flow/1", "Inverse area/1", "autorouting", "on");
add_line(modelName, "Inverse area/1", "Water level/1", "autorouting", "on");
add_line(modelName, "Water level/1", "Level scope/1", "autorouting", "on");
add_line(modelName, "Water level/1", "Level output/1", "autorouting", "on");
add_line(modelName, "Water level/1", "Control error/2", "autorouting", "on");

save_system(modelName, modelPath);
print(['-s' char(modelName)], '-dpng', '-r180', char(fullfile(resultDir, "simulink-model.png")));
close_system(modelName, 0);

fprintf("Created %s\n", modelPath);
end

function buildPiSubsystem(subsystemPath)
%BUILDPI SUBSYSTEM Show the equation u = Kp*e + Ki*integral(e dt).

Simulink.SubSystem.deleteContents(subsystemPath);
add_block("simulink/Ports & Subsystems/In1", subsystemPath + "/Error", ...
    "Position", [35 83 65 97]);
add_block("simulink/Math Operations/Gain", subsystemPath + "/Kp", ...
    "Gain", "p.Kp", "Position", [115 35 180 70]);
add_block("simulink/Continuous/Integrator", subsystemPath + "/Integral", ...
    "InitialCondition", "0", "Position", [105 125 135 155]);
add_block("simulink/Math Operations/Gain", subsystemPath + "/Ki", ...
    "Gain", "p.Ki", "Position", [175 120 240 160]);
add_block("simulink/Math Operations/Sum", subsystemPath + "/P plus I", ...
    "Inputs", "++", "Position", [290 75 315 125]);
add_block("simulink/Ports & Subsystems/Out1", subsystemPath + "/Control", ...
    "Position", [365 93 395 107]);

add_line(subsystemPath, "Error/1", "Kp/1", "autorouting", "on");
add_line(subsystemPath, "Error/1", "Integral/1", "autorouting", "on");
add_line(subsystemPath, "Kp/1", "P plus I/1", "autorouting", "on");
add_line(subsystemPath, "Integral/1", "Ki/1", "autorouting", "on");
add_line(subsystemPath, "Ki/1", "P plus I/2", "autorouting", "on");
add_line(subsystemPath, "P plus I/1", "Control/1", "autorouting", "on");
end
