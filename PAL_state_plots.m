clearvars
stateFile = "Data Files/pal_test/pal_fsl_test_fsl.csv";
gpsFile = "Data Files/pal_test/pal_fsl_test_gps.csv";
tmFile = "2024-02-26-serial-8183-flight-0004";
rawFile = "Data Files/pal_test/pal_fsl_test_dat.csv";
flight = readtable(stateFile);
gps = readtable(gpsFile);
tm = readtable(tmFile);
raw = readtable(rawFile);

flight.Properties.VariableNames;
gps.Properties.VariableNames;
tm.Properties.VariableNames;

g = 9.81;

iMin = 1;
iMax = length(flight.timestamp);

tMin = 3125; % s
tMax = 3225; % s

% tMin = 3136;
% tMax = 3152;

%% analysis
transitions = zeros(1, 7);
for phase = 2:7
    t = find(flight.flight_phase == phase, 1,'first');
    if (~isempty(t))
        transitions(phase) = flight.timestamp(find(flight.flight_phase == phase, 1,'first'));
    end
end

%accuracy
h0 = 210; % m
adjusted_gps = zeros(length(gps.timestamp), 6);
adjusted_gps(:,1) = gps.vel_down .* gps.fix_valid; % vel
adjusted_gps(:,2) = (gps.height_msl - h0) .* gps.fix_valid; % height
adjusted_gps(:,3) = (adjusted_gps(:,1) - gps.accuracy_speed) .* gps.fix_valid; % vel min
adjusted_gps(:,4) = (adjusted_gps(:,1) + gps.accuracy_speed) .* gps.fix_valid; % vel max
adjusted_gps(:,5) = (adjusted_gps(:,2) - gps.accuracy_vertical) .* gps.fix_valid; % vel min
adjusted_gps(:,6) = (adjusted_gps(:,2) + gps.accuracy_vertical) .* gps.fix_valid; % vel max

adjusted_gps = changem(adjusted_gps, NaN, 0);

%% PLOT
figure(2)
clf;
tmOffset = 3136.42;

subplot(3, 1, 1); hold on;
plot(flight.timestamp/1e6, -1*flight.acc_d, DisplayName="PAL-state", LineWidth=1)
plot(raw.timestamp/1e6, raw.acc_i_y*g, "c", DisplayName="PAL-imu-y")
plot(raw.timestamp/1e6, raw.acc_h_y*g, "g", DisplayName="PAL-hg-y")
plot(tm.time + tmOffset, tm.acceleration, "r", DisplayName="telemega")
% plot(flight.timestamp/1e6, tm.height, DisplayName="tm-state")
phaseLines(transitions);
hold off; grid("on"), legend; xlabel("time (s)"); ylabel("acceleration (m/s^2)"); xlim([tMin, tMax]);

subplot(3, 1, 2); hold on;
plot(flight.timestamp/1e6, -1*flight.vel_d, DisplayName="PAL-state")
plot(gps.timestamp/1e6, -1*adjusted_gps(:,1), DisplayName="PAL-gps")
plot(gps.timestamp/1e6, -1*adjusted_gps(:,3), "--", DisplayName="PAL-gps-min", Color=	"#EDB120")
plot(gps.timestamp/1e6, -1*adjusted_gps(:,4), "--", DisplayName="PAL-gps-max", Color=	"#EDB120")
plot(tm.time + tmOffset, tm.speed, "r", DisplayName="telemega")
plot(tm.time + tmOffset, tm., "r", DisplayName="tm gps")
phaseLines(transitions);
hold off; grid("on"), legend; xlabel("time (s)"); ylabel("velocity (m/s)"); xlim([tMin, tMax]);

subplot(3, 1, 3); hold on;
plot(flight.timestamp/1e6, -1*flight.pos_d, DisplayName="PAL-state")
plot(gps.timestamp/1e6, adjusted_gps(:,2), DisplayName="PAL-gps")
plot(gps.timestamp/1e6, adjusted_gps(:,5), "--", DisplayName="PAL-gps-min", Color=	"#EDB120")
plot(gps.timestamp/1e6, adjusted_gps(:,6), "--", DisplayName="PAL-gps-max", Color=	"#EDB120")
plot(tm.time + tmOffset, tm.height, "r", DisplayName="telemega")
phaseLines(transitions);
hold off; grid("on"), legend; xlabel("time (s)"); ylabel("position (m AGL)"); xlim([tMin, tMax]);

%% GPS plot
figure(4)
clf;

subplot(3, 1, 1); hold on;
plot(flight.timestamp/1e6, -1*flight.pos_d, DisplayName="PAL-state")
plot(gps.timestamp/1e6, adjusted_gps(:,2), DisplayName="PAL-gps")
plot(gps.timestamp/1e6, adjusted_gps(:,5), "--", DisplayName="PAL-gps-min", Color=	"#EDB120")
plot(gps.timestamp/1e6, adjusted_gps(:,6), "--", DisplayName="PAL-gps-max", Color=	"#EDB120")
phaseLines(transitions);
hold off; grid("on"), legend; xlabel("time (s)"); ylabel("position (m AGL)"); xlim([tMin, tMax]);

subplot(3, 1, 2); hold on;
plot(flight.timestamp/1e6, -1*flight.vel_d, DisplayName="PAL-state")
plot(gps.timestamp/1e6, -1*adjusted_gps(:,1), DisplayName="PAL-gps")
plot(gps.timestamp/1e6, -1*adjusted_gps(:,3), "--", DisplayName="PAL-gps-min", Color=	"#EDB120")
plot(gps.timestamp/1e6, -1*adjusted_gps(:,4), "--", DisplayName="PAL-gps-max", Color=	"#EDB120")
% plot(tm.time, tm.height)
phaseLines(transitions);
hold off; grid("on"), legend; xlabel("time (s)"); ylabel("velocity (m/s)"); xlim([tMin, tMax]);

subplot(3, 1, 3);
plot(gps.timestamp/1e6, gps.accuracy_vertical, gps.timestamp/1e6, gps.accuracy_horiz, gps.timestamp/1e6, gps.accuracy_speed)
grid("on"), legend(["vertical", "horizontal", "speed"]); xlabel("time (s)"); ylabel("accuracy"); xlim([tMin, tMax]);

% figure(4)
% % plot(raw.timestamp/1e6, acc)
%  hold on;
% plot(flight.timestamp/1e6, -1*flight.acc_d, DisplayName="PAL-state", LineWidth=1)
% plot(raw.timestamp/1e6, raw.acc_i_y*g, "c", DisplayName="PAL-imu-y")
% plot(raw.timestamp/1e6, raw.acc_h_y*g, "g", DisplayName="PAL-hg-y")

figure(5)
clf
subplot(2,1,1)
plot(tm.time, tm.height);
xlim([0, 15])
hold on
plot([13.21, 13.21], ylim)
hold off; grid("on"), legend; xlabel("time (s)"); ylabel("height (barometric) (m)");
subplot(2,1,2)
plot(tm.time, tm.speed);
xlim([0, 15])
hold on
plot([13.21, 13.21], ylim)
hold off; grid("on"), legend; xlabel("time (s)"); ylabel("velocity (m/s)"); title("telemega");



%% functions

function phaseLines(transitions)
    for phase = 1:length(transitions)
        plot([transitions(phase), transitions(phase)]/1e6, ylim, "--k", HandleVisibility="off")
    end
end
