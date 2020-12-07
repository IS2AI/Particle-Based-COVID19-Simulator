function plot_vis(delta_t, num_iter, cur_iter, tot_exposed, tot_infected, tot_recovered, tot_dead, ...
    tot_quarantined, tot_isolated, tot_severe_inf, tot_susceptible)

% close all plots
close all;

% construct the time vector
time_vec = (0:cur_iter - 1) * delta_t;

f1 = figure(1);
%set(f1,'Position',[60 60 800 500]);
set(f1, 'PaperUnits', 'centimeters');
set(f1, 'PaperPosition', [0 0 18 13]);
%set(f1,'defaultFigurePaperPositionMode','manual')
subplot(3,1,1:2)
hold on;

legend_list = {};

%p9 = plot(time_vec, tot_susceptible(1:cur_iter), 'b-', 'LineWidth', 1);
%legend_list = [legend_list, 'Susceptible'];

p2 = stairs(time_vec, tot_exposed(1:cur_iter), 'm-', 'LineWidth', 1);
legend_list = [legend_list, 'Exposed'];

%p3 = stairs(time_vec, tot_quarantined(1:cur_iter), 'm--', 'LineWidth', 1);
%legend_list = [legend_list, 'Quarantined'];

p4 = stairs(time_vec, tot_infected(1:cur_iter), 'r-', 'LineWidth', 1);
legend_list = [legend_list, 'Infected'];

%p5 = stairs(time_vec, tot_severe_inf(1:cur_iter), 'r--','LineWidth', 1);
%legend_list = [legend_list, 'Severe Infected'];

p6 = stairs(time_vec, tot_recovered(1:cur_iter), 'g-', 'LineWidth', 1);
legend_list = [legend_list, 'Recovered'];

%p7 = stairs(time_vec, tot_isolated(1:cur_iter), 'c-','LineWidth', 1);
%legend_list = [legend_list, 'Isolated'];

%p8 = stairs(time_vec, tot_dead(1:cur_iter), 'k-', 'LineWidth', 1);
%legend_list = [legend_list, 'Dead'];

legend( legend_list, 'FontName','Arial', 'FontSize', 10', 'FontWeight','Demi','Location','northwest','Orientation','Vertical');

ylabel('Number of individuals','FontName','Arial', 'FontSize', 12, 'FontWeight', 'Demi');
xlabel('', 'FontName','Arial', 'FontSize', 12, 'FontWeight', 'Demi');
xlim([0 num_iter * delta_t]);
xticks([0 20 40 60 80 100 120 140 160 180 200])
ylim([0 20000]);
set(gca,'YTickLabel',num2str(get(gca,'YTick').'))
grid on;  box on;

subplot 313
ax = gca;
ax.YAxis.Exponent = 0;
xlabel('Time (days)', 'FontName', 'Arial', 'FontSize', 12, 'FontWeight', 'Demi');
ylabel('Num. of Individuals', 'FontName', 'Arial', 'FontSize', 12, 'FontWeight', 'Demi');
xlim([0 num_iter * delta_t]);
xticks([0 20 40 60 80 100 120 140 160 180 200])
ylim([0 1000])
grid on; box on;
hold on
hd = plot(time_vec, tot_isolated(1:cur_iter), 'c-','LineWidth', 1);
ha = plot(time_vec, tot_quarantined(1:cur_iter), 'm-', 'LineWidth', 1);
hb = plot(time_vec, tot_dead(1:cur_iter), 'k-', 'LineWidth', 1);
hc = plot(time_vec, tot_severe_inf(1:cur_iter), 'r-', 'LineWidth', 1);
legend([ha hd hc hb], 'Quarantined', 'Isolated', 'Severe Infected', 'Dead', 'FontSize', 10', 'Location','northwest','Orientation','Vertical');
hold off;

filename = sprintf('plot/ind_%d.png', cur_iter);
saveas(f1, filename);

end
