function plot_average(delta_t, cur_iter, tot_exposed, tot_infected, tot_recovered, tot_dead, tot_quarantined, ... 
    tot_isolated, tot_severe_inf, tot_cases, std_dev_dead, std_dev_tot)

% close all plots
close all;

% estimate low and high std devs for total cases
tot_cases_low = tot_cases - std_dev_tot;
tot_cases_high = tot_cases + std_dev_tot;

% estimate low and high std devs for death cases
tot_dead_low = tot_dead - std_dev_dead;
tot_dead_high = tot_dead + std_dev_dead;

% construc the time vector
time_vec = (0:cur_iter - 1) * delta_t;

f1 = figure(1);
set(f1,'Position',[60 60 1200 700]);
subplot(3,1,1:2)
hold on;

legend_list = {};
p2 = stairs(time_vec, tot_exposed(1:cur_iter), 'm-', 'LineWidth', 1);
legend_list = [legend_list, 'Exposed'];

p3 = stairs(time_vec, tot_quarantined(1:cur_iter), 'm--', 'LineWidth', 1);
legend_list = [legend_list, 'Quarantined'];

p4 = stairs(time_vec, tot_infected(1:cur_iter), 'r-', 'LineWidth', 1);
legend_list = [legend_list, 'Infected'];

p5 = stairs(time_vec, tot_severe_inf(1:cur_iter), 'r--','LineWidth', 1);
legend_list = [legend_list, 'Severe Infected'];

p6 = stairs(time_vec, tot_recovered(1:cur_iter), 'g-', 'LineWidth', 1);
legend_list = [legend_list, 'Recovered'];

p7 = stairs(time_vec, tot_isolated(1:cur_iter), 'c-','LineWidth', 1);
legend_list = [legend_list, 'Isolated'];

p8 = stairs(time_vec, tot_dead(1:cur_iter), 'k-', 'LineWidth', 1);
legend_list = [legend_list, 'Dead'];
%p8_ = stairs(actual_date, actual_death, 'k-o', 'LineWidth', 1);
%legend_list = [legend_list, 'Dead (Actual)'];

p9 = plot(time_vec, tot_cases(1:cur_iter), 'b-', 'LineWidth', 1);
legend_list = [legend_list, 'Total cases'];
%p9_ = plot(actual_date, actual_cases, 'b-o', 'LineWidth', 1);
%legend_list = [legend_list, 'Total cases (Actual)'];

filled = [tot_cases_low; flipud(tot_cases_high)];
xpoints = [time_vec, fliplr(time_vec)];
color = 'b';
edge = 'b';
transparency = 0.1;
fillhandle = fill(xpoints, filled, color);
set(fillhandle, 'EdgeColor',edge,'FaceAlpha',transparency,'EdgeAlpha',transparency);
hold on;

legend( legend_list, 'FontName','Arial', 'FontSize', 12','FontWeight','Demi','Location','northwest','Orientation','Vertical');

ylabel('Number of Particles','FontName','Arial', 'FontSize', 14, 'FontWeight', 'Demi');
xlabel('', 'FontName','Arial', 'FontSize', 14, 'FontWeight', 'Demi');
xlim([0 100]);
%ylim([0 18000]);
set(gca,'YTickLabel',num2str(get(gca,'YTick').'))
grid on;  box on;

subplot 313
filled = [tot_dead_low; flipud(tot_dead_high)];
xpoints = [time_vec, fliplr(time_vec)];
color = 'k';
edge = 'k';
transparency = 0.1;
fillhandle = fill(xpoints, filled, color);
set(fillhandle, 'EdgeColor',edge,'FaceAlpha',transparency,'EdgeAlpha',transparency);
hold on;

%ha = plot(actual_date, actual_death, 'k-o', 'LineWidth', 0.5);
ax = gca;
ax.YAxis.Exponent = 0;
ylabel('Num. of Particles', 'FontName', 'Arial', 'FontSize', 14, 'FontWeight', 'Demi');
xlabel('Days', 'FontName', 'Arial', 'FontSize', 14, 'FontWeight', 'Demi');
grid on; box on;
hold on
hb = plot(time_vec, tot_dead(1:cur_iter), 'k-', 'LineWidth', 1);
hc = plot(time_vec, tot_severe_inf(1:cur_iter), 'r--', 'LineWidth', 1);

xlim([0 100]);
%ylim([0 1500]);
legend([hb hc], 'Dead', 'Severe Infected', 'FontSize', 12', 'Location','northwest','Orientation','Vertical');
hold off;

saveas(f1, 'milan_std_dev.png')
end