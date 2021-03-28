function plot_sev_inf_age(delta_t, cur_iter, tot_sev_inf, sum_sev_inf)

time_vec = (0:cur_iter - 1) * delta_t;

f3 = figure(3);
set(f3,'Position',[60 60 1200 800]);
subplot 211

plot(time_vec, tot_sev_inf(1:cur_iter, 1), 'g-', 'LineWidth', 1);
hold on 
plot(time_vec, tot_sev_inf(1:cur_iter, 2), 'g--', 'LineWidth', 1);
hold on 
plot(time_vec, tot_sev_inf(1:cur_iter, 3), 'b-', 'LineWidth', 1);
hold on 
plot(time_vec, tot_sev_inf(1:cur_iter, 4), 'b--', 'LineWidth', 1);
hold on 
plot(time_vec, tot_sev_inf(1:cur_iter, 5), 'm-', 'LineWidth', 1);
hold on 
plot(time_vec, tot_sev_inf(1:cur_iter, 6), 'm--', 'LineWidth', 1);
hold on 
plot(time_vec, tot_sev_inf(1:cur_iter, 7), 'r-', 'LineWidth', 1);
hold on 
plot(time_vec, tot_sev_inf(1:cur_iter, 8), 'r--', 'LineWidth', 1);
hold on 
plot(time_vec, tot_sev_inf(1:cur_iter, 9), 'k-', 'LineWidth', 1);
hold off 


legend( '0-9', '10-19', '20-29', '30:39', '40-49', '50-59', '60-69', '70-79', '80+', ...
    'FontName','Arial', 'FontSize', 12,'FontWeight','Demi','Location','northwest','Orientation','Vertical');

ylabel('Num. of particles','FontName','Arial', 'FontSize', 16, 'FontWeight', 'Demi');
%xlabel('Day', 'FontName','Arial', 'FontSize', 12, 'FontWeight', 'Demi');
title('Severely Infected', 'FontName', 'Arial', 'FontSize', 16, 'FontWeight', 'Demi');
xlim([0 cur_iter * delta_t]);
%ylim([0 110000]);
set(gca,'YTickLabel',num2str(get(gca,'YTick').'))
grid on;  box on;

subplot 212
plot(time_vec, sum_sev_inf(1:cur_iter, 1), 'k-', 'LineWidth', 1);
legend( 'Total', 'FontName','Arial', 'FontSize', 14,'FontWeight','Demi','Location','northwest','Orientation','Vertical');

ylabel('Num. of particles','FontName','Arial', 'FontSize', 16, 'FontWeight', 'Demi');
xlabel('Days', 'FontName','Arial', 'FontSize', 16, 'FontWeight', 'Demi');
%title('Total Dead', 'FontName','Arial', 'FontSize', 12, 'FontWeight', 'Demi');
xlim([0 cur_iter * delta_t]);
set(gca,'YTickLabel',num2str(get(gca,'YTick').'))
grid on;  box on;