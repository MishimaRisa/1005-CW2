% Name: Jiaheng Pan 
% Email: ssyjp5@nottingham.edu.cn

clear a
a = arduino('COM5', 'Uno');
temp_monitor(a);

function temp_monitor(a)

% Duration for data collection in seconds
duration = 600;
timeData = [];
tempData = [];
tStart = datetime('now');

% Open log file
logFile = fopen('cabin_temperature.txt', 'w');
fprintf(logFile, 'Time(s)\tTemperature(C)\n');

% Initialize plot
figure;
h = plot(NaN, NaN, '-o', 'LineWidth', 2);
xlabel('Time (s)');
ylabel('Temperature (°C)');
title('Cabin Temperature Monitoring');
ylim([10 35]);
xlim([0 60]);
grid on;
hold on;

while true
    % Current time
    tNow = datetime('now');
    t = seconds(tNow - tStart);

    % Read analog voltage and convert to temperature
    V = readVoltage(a, 'A0');
    T = (V - 0.5) * 100;

    % Store data
    timeData(end+1) = t;
    tempData(end+1) = T;

    % Write to log file
    fprintf(logFile, '%.2f\t%.2f\n', t, T);

    % Update plot
    set(h, 'XData', timeData, 'YData', tempData);
    xlim([max(0, t-60) t+5]);
    drawnow;

    % ===== Task 3: Temperature Prediction and Slope Calculation =====
    slope = 0;  % Default temperature rate
    predictedTemp = T;

    if length(timeData) >= 10
        % Use last 30 seconds of data to fit a linear model
        idx = timeData > (t - 30);
        recentT = timeData(idx);
        recentY = tempData(idx);
        if length(recentT) >= 2
            p = polyfit(recentT, recentY, 1);  % Linear fit
            slope = p(1) * 60;  % Convert to °C/min
            predictedTemp = T + slope * 5;
        end
    end

    % Display prediction info
    fprintf('Current temperature: %.2f°C | Predicted in 5 min: %.2f°C | Rate: %.2f°C/min\n', T, predictedTemp, slope);

    % ===== Task 3: LED Response Based on Temperature Rate =====
    if slope > 4
        writeDigitalPin(a, 'D7', 0);
        writeDigitalPin(a, 'D8', 0);
        writeDigitalPin(a, 'D9', 1);  % Red LED ON
        pause(1);
    elseif slope < -4
        writeDigitalPin(a, 'D7', 0);
        writeDigitalPin(a, 'D8', 1);  % Yellow LED ON
        writeDigitalPin(a, 'D9', 0);
        pause(1);
    else
        % Task 2: Standard LED logic
        if T >= 18 && T <= 24
            writeDigitalPin(a, 'D7', 1);  % Green LED ON
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

    % Stop condition
    if t >= duration
        break;
    end
end

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