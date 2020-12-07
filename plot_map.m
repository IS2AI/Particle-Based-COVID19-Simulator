function plot_map(ind, tot_exposed, ind_exposed, tot_infected, ind_infected, tot_recovered, ind_recovered, tot_dead, ind_dead,...
    tot_true_quarantined, ind_true_quarantined, tot_true_isolated, ind_true_isolated, tot_severe_inf, ind_severe_inf, ...
    tot_susceptible, ind_susceptible, x, save_figures)

f2 = figure(2);
set(f2, 'PaperUnits', 'centimeters');
set(f2, 'PaperPosition', [0 0 13 13]);

legend_list = {};
if (tot_susceptible(ind) > 0)
    plot(x(ind_susceptible, 1), x(ind_susceptible, 2), 'b .','MarkerSize', 10)
    hold on
    legend_list = [legend_list, 'S'];
end
if (tot_exposed(ind) > 0)
    plot(x(ind_exposed, 1), x(ind_exposed, 2), 'm o','MarkerSize', 2)
    hold on
    legend_list = [legend_list, 'E'];
end
if (tot_infected(ind) > 0)
    plot(x(ind_infected, 1), x(ind_infected, 2), 'r o','MarkerSize', 2)
    hold on
    legend_list = [legend_list, 'I'];
end
if (tot_true_quarantined(ind) > 0)
    plot(x(ind_true_quarantined, 1), x(ind_true_quarantined, 2), 'm s','MarkerSize', 4, 'MarkerFaceColor', 'm')
    hold on
    legend_list = [legend_list, 'Q'];
end
if (tot_true_isolated(ind) > 0)
    plot(x(ind_true_isolated, 1), x(ind_true_isolated, 2), 'c s','MarkerSize', 4, 'MarkerFaceColor', 'c')
    hold on
    legend_list = [legend_list, 'Iso'];
end
if (tot_severe_inf(ind) > 0)
    plot(x(ind_severe_inf, 1), x(ind_severe_inf, 2), 'r *','MarkerSize', 4)
    hold on
    legend_list = [legend_list, 'SI'];
end
if (tot_recovered(ind) > 0)
    plot(x(ind_recovered, 1), x(ind_recovered, 2), 'g .','MarkerSize', 1)
    hold on
    legend_list = [legend_list, 'R'];
end
if (tot_dead(ind) > 0)
    plot(x(ind_dead, 1), x(ind_dead, 2), 'k x','MarkerSize', 4)
    hold on
    legend_list = [legend_list, 'D'];
end
hold off
yticks([-1 0 1])
xticks([-1 0 1])
xlim([-1 1]);
ylim([-1 1]);
%L = legend(legend_list, 'Fontsize', 10, 'Location','north','Orientation','Horizontal');
%L.ItemTokenSize(1) = 10;
% 0 -> Susceptible, 1 -> Exposed, 2 -> Infected, 3 -> Recovered,
% 4 -> Dead, 5 -> Quarantined, 6 -> Isolated, 7 -> Severe Infected

% create a new pair of axes inside current figure
axes('position',[.64 .12 .25 .25])
box on % put box around new pair of axes
indexOfInterest = (x(:, 1) >= -0.25 & x(:, 1) <= -0.2 & x(:, 2) >= -0.025 & x(:, 2) <= 0.025);
indexOfInterest_sus = (indexOfInterest & ind_susceptible);
indexOfInterest_inf = (indexOfInterest & ind_infected);
indexOfInterest_exp = (indexOfInterest & ind_exposed);
indexOfInterest_iso = (indexOfInterest & ind_true_isolated);
indexOfInterest_dead = (indexOfInterest & ind_dead);
indexOfInterest_qua = (indexOfInterest & ind_true_quarantined);
indexOfInterest_rec = (indexOfInterest & ind_recovered);
indexOfInterest_sev = (indexOfInterest & ind_severe_inf);
plot(x(indexOfInterest_sus, 1), x(indexOfInterest_sus, 2), 'b .','MarkerSize', 5)
hold on
plot(x(indexOfInterest_inf, 1), x(indexOfInterest_inf, 2), 'r o','MarkerSize', 5)
hold on
plot(x(indexOfInterest_exp, 1), x(indexOfInterest_exp, 2), 'm o','MarkerSize', 5)
hold on
plot(x(indexOfInterest_iso, 1), x(indexOfInterest_iso, 2), 'c s','MarkerSize', 5, 'MarkerFaceColor', 'c')
hold on
plot(x(indexOfInterest_dead, 1), x(indexOfInterest_dead, 2), 'k x','MarkerSize', 5)
hold on
plot(x(indexOfInterest_qua, 1), x(indexOfInterest_qua, 2), 'm s','MarkerSize', 5, 'MarkerFaceColor', 'm')
hold on
plot(x(indexOfInterest_rec, 1), x(indexOfInterest_rec, 2), 'g .','MarkerSize', 5)
hold on
plot(x(indexOfInterest_sev, 1), x(indexOfInterest_sev, 2), 'r *','MarkerSize', 5)
set(gca,'XTick', [], 'YTick', [])
hold off
axis tight

if save_figures
    filename2 = sprintf('map/ind_%d.png', ind);
    saveas(f2, filename2);
end

