fig = figure;
hold on;
plot(T1.t/60, T1.T, 'LineWidth',2)
% plot(T2.t/60, T2.T)
% plot(T3.t/60, T3.T)
% plot(T4.t/60, T4.T)
% plot(T5.t/60, T5.T)
% plot(T6.t/60, T6.T)
% plot(T7.t/60, T7.T)
% plot(T8.t/60, T8.T)
plot(T9.t(T9.t>2900)/60-2900/60, T9.T(T9.t>2900), 'LineWidth',2)
xlim([0, 80]);
ylim([0, 28]);
standardizePlot(gcf,gca,'temperature_timeseries');
close(fig);
