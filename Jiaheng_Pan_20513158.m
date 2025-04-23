% Name: Jiaheng Pan 
% Email: ssyjp5@nottingham.edu.cn
%% PRELIMINARY TASK - ARDUINO AND GIT INSTALLATION [10 MARKS]
% Establish Arduino connection
clear a
a = arduino('COM5', 'Uno');

% Call main temperature monitoring and prediction function
temp_monitor(a);


%% TASK 1, 2, 3 - FUNCTION IMPLEMENTATION
function temp_monitor(a)
% Tasks Covered:
% - Task 1: Data acquisition, plotting, and logging
% - Task 2: LED display logic based on temperature
% - Task 3: Temperature trend prediction and alerting

%% Initialization (Task 1 setup)
duration = 600; % total acquisition time in seconds
timeData = [];
tempData = [];
tStart = datetime('now');
logFile = fopen('cabin_temperature.txt', 'w');
fprintf(logFile, 'Time(s)\tTemperature(C)\n');

figure;
h = plot(NaN, NaN, '-o', 'LineWidth', 2);
xlabel('Time (s)');
ylabel('Temperature (°C)');
title('Cabin Temperature Monitoring');
ylim([10 35]);
xlim([0 60]);
grid on; hold on;

%% Main loop
while true
    tNow = datetime('now');
    t = seconds(tNow - tStart);

    % Read temperature
    V = readVoltage(a, 'A0');
    T = (V - 0.5) * 100;

    % Store and log
    timeData(end+1) = t;
    tempData(end+1) = T;
    fprintf(logFile, '%.2f\t%.2f\n', t, T);

    % Update plot
    set(h, 'XData', timeData, 'YData', tempData);
    xlim([max(0, t-60) t+5]);
    drawnow;

    %% TASK 3 - TEMPERATURE PREDICTION
    slope = 0; 
    predictedTemp = T;
    if length(timeData) >= 10
        idx = timeData > (t - 30);
        recentT = timeData(idx);
        recentY = tempData(idx);
        if length(recentT) >= 2
            p = polyfit(recentT, recentY, 1); 
            slope = p(1) * 60; % °C/min
            predictedTemp = T + slope * 5;
        end
    end
    fprintf('Current temperature: %.2f°C | Predicted in 5 min: %.2f°C | Rate: %.2f°C/min\n', ...
        T, predictedTemp, slope);

    %% TASK 2 - LED TEMPERATURE MONITORING DEVICE IMPLEMENTATION
    if slope > 4
        writeDigitalPin(a, 'D7', 0);
        writeDigitalPin(a, 'D8', 0);
        writeDigitalPin(a, 'D9', 1); % Red
        pause(1);
    elseif slope < -4
        writeDigitalPin(a, 'D7', 0);
        writeDigitalPin(a, 'D8', 1); % Yellow
        writeDigitalPin(a, 'D9', 0);
        pause(1);
    else
        if T >= 18 && T <= 24
            writeDigitalPin(a, 'D7', 1); % Green
            writeDigitalPin(a, 'D8', 0);
            writeDigitalPin(a, 'D9', 0);
            pause(1);
        elseif T < 18
            writeDigitalPin(a, 'D7', 0);
            for i = 1:1
                writeDigitalPin(a, 'D8', 1); pause(0.25);
                writeDigitalPin(a, 'D8', 0); pause(0.25);
            end
            writeDigitalPin(a, 'D9', 0);
        else
            writeDigitalPin(a, 'D7', 0);
            writeDigitalPin(a, 'D8', 0);
            for i = 1:2
                writeDigitalPin(a, 'D9', 1); pause(0.125);
                writeDigitalPin(a, 'D9', 0); pause(0.125);
            end
        end
    end

    % Exit condition
    if t >= duration
        break;
    end
end

%% Summary and file closure
fclose(logFile);
fprintf('\n--- Cabin Temperature Summary ---\n');
fprintf('Max Temp: %.2f °C\n', max(tempData));
fprintf('Min Temp: %.2f °C\n', min(tempData));
fprintf('Avg Temp: %.2f °C\n', mean(tempData));
fprintf('Data logging completed. File saved as cabin_temperature.txt\n');

end

%  Task 4: Reflective Statement 
%
% This coursework provided a hands-on opportunity to integrate hardware control,
% environmental sensing, and data processing through the use of Arduino and MATLAB.
% The project deepened my understanding of real-time analog signal acquisition,
% logic-based feedback systems, and modular program design.
%
% A notable technical challenge occurred during initial circuit setup:
% a short-circuited resistor prevented expected LED behavior and required
% significant time to isolate. Additionally, testing temperatures below 18°C
% proved difficult due to room conditions. I eventually addressed this by
% applying an ice-dampened tissue to the sensor, which successfully triggered
% the low-temperature LED logic.
%
% The logic structure itself required careful segmentation between standard
% temperature threshold control (Task 2) and predictive slope-based behavior (Task 3).
% The latter involved implementing real-time linear regression over recent data
% to estimate the temperature trend and anticipate future changes. While
% conceptually straightforward, this required attention to sampling consistency
% and numerical stability during execution.
%
% The LED response mechanism based on predicted slope presented both a technical
% and conceptual bridge between real-world dynamics and programmatic control,
% reinforcing the connection between physical systems and code-driven response.
%
% Overall, the assignment effectively combined practical relevance and technical rigor.
% It was particularly engaging to see how a familiar concept like temperature could
% be translated into algorithmic conditions and hardware response. I appreciated the
% applied nature of the task and believe that incorporating similar project-based
% assignments in future modules would help reinforce engineering principles
% through direct implementation.