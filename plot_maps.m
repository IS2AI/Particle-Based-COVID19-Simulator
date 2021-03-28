function plot_maps(ind, ind_exp, ind_inf, ind_imm, ind_dead, ind_qua_t, ind_iso_t, ind_sev_inf, ...
    ind_sus, age, age_groups, vac, x, save_plt, path, ind_exp_i, ind_inf_i, ind_dead_i, ...
                ind_sev_inf_i, x_i)

% ind_sus1 = (age == age_groups(1) & ind_sus);
% ind_sus2 = (age == age_groups(2) & ind_sus);
% ind_sus3 = (age == age_groups(3) & ind_sus);
% ind_sus4 = (age == age_groups(4) & ind_sus);
% ind_sus5 = (age == age_groups(5) & ind_sus);
% ind_sus6 = (age == age_groups(6) & ind_sus);
% ind_sus7 = (age == age_groups(7) & ind_sus);
% ind_sus8 = (age == age_groups(8) & ind_sus);
% ind_sus9 = (age == age_groups(9) & ind_sus);

ind_exp1 = (age == age_groups(1) & ind_exp & ~ind_exp_i);
ind_exp2 = (age == age_groups(2) & ind_exp & ~ind_exp_i);
ind_exp3 = (age == age_groups(3) & ind_exp & ~ind_exp_i);
ind_exp4 = (age == age_groups(4) & ind_exp & ~ind_exp_i);
ind_exp5 = (age == age_groups(5) & ind_exp & ~ind_exp_i);
ind_exp6 = (age == age_groups(6) & ind_exp & ~ind_exp_i);
ind_exp7 = (age == age_groups(7) & ind_exp & ~ind_exp_i);
ind_exp8 = (age == age_groups(8) & ind_exp & ~ind_exp_i);
ind_exp9 = (age == age_groups(9) & ind_exp & ~ind_exp_i);

ind_exp1_i = (age == age_groups(1) & ind_exp_i);
ind_exp2_i = (age == age_groups(2) & ind_exp_i);
ind_exp3_i = (age == age_groups(3) & ind_exp_i);
ind_exp4_i = (age == age_groups(4) & ind_exp_i);
ind_exp5_i = (age == age_groups(5) & ind_exp_i);
ind_exp6_i = (age == age_groups(6) & ind_exp_i);
ind_exp7_i = (age == age_groups(7) & ind_exp_i);
ind_exp8_i = (age == age_groups(8) & ind_exp_i);
ind_exp9_i = (age == age_groups(9) & ind_exp_i);

ind_inf1 = (age == age_groups(1) & ind_inf & ~ind_inf_i);
ind_inf2 = (age == age_groups(2) & ind_inf & ~ind_inf_i);
ind_inf3 = (age == age_groups(3) & ind_inf & ~ind_inf_i);
ind_inf4 = (age == age_groups(4) & ind_inf & ~ind_inf_i);
ind_inf5 = (age == age_groups(5) & ind_inf & ~ind_inf_i);
ind_inf6 = (age == age_groups(6) & ind_inf & ~ind_inf_i);
ind_inf7 = (age == age_groups(7) & ind_inf & ~ind_inf_i);
ind_inf8 = (age == age_groups(8) & ind_inf & ~ind_inf_i);
ind_inf9 = (age == age_groups(9) & ind_inf & ~ind_inf_i);

ind_inf1_i = (age == age_groups(1) & ind_inf_i);
ind_inf2_i = (age == age_groups(2) & ind_inf_i);
ind_inf3_i = (age == age_groups(3) & ind_inf_i);
ind_inf4_i = (age == age_groups(4) & ind_inf_i);
ind_inf5_i = (age == age_groups(5) & ind_inf_i);
ind_inf6_i = (age == age_groups(6) & ind_inf_i);
ind_inf7_i = (age == age_groups(7) & ind_inf_i);
ind_inf8_i = (age == age_groups(8) & ind_inf_i);
ind_inf9_i = (age == age_groups(9) & ind_inf_i);

ind_sev_inf1 = (age == age_groups(1) & ind_sev_inf & ~ind_sev_inf_i);
ind_sev_inf2 = (age == age_groups(2) & ind_sev_inf & ~ind_sev_inf_i);
ind_sev_inf3 = (age == age_groups(3) & ind_sev_inf & ~ind_sev_inf_i);
ind_sev_inf4 = (age == age_groups(4) & ind_sev_inf & ~ind_sev_inf_i);
ind_sev_inf5 = (age == age_groups(5) & ind_sev_inf & ~ind_sev_inf_i);
ind_sev_inf6 = (age == age_groups(6) & ind_sev_inf & ~ind_sev_inf_i);
ind_sev_inf7 = (age == age_groups(7) & ind_sev_inf & ~ind_sev_inf_i);
ind_sev_inf8 = (age == age_groups(8) & ind_sev_inf & ~ind_sev_inf_i);
ind_sev_inf9 = (age == age_groups(9) & ind_sev_inf & ~ind_sev_inf_i);

ind_sev_inf1_i = (age == age_groups(1) & ind_sev_inf_i);
ind_sev_inf2_i = (age == age_groups(2) & ind_sev_inf_i);
ind_sev_inf3_i = (age == age_groups(3) & ind_sev_inf_i);
ind_sev_inf4_i = (age == age_groups(4) & ind_sev_inf_i);
ind_sev_inf5_i = (age == age_groups(5) & ind_sev_inf_i);
ind_sev_inf6_i = (age == age_groups(6) & ind_sev_inf_i);
ind_sev_inf7_i = (age == age_groups(7) & ind_sev_inf_i);
ind_sev_inf8_i = (age == age_groups(8) & ind_sev_inf_i);
ind_sev_inf9_i = (age == age_groups(9) & ind_sev_inf_i);

% ind_qua1 = (age == age_groups(1) & ind_qua_t);
% ind_qua2 = (age == age_groups(2) & ind_qua_t);
% ind_qua3 = (age == age_groups(3) & ind_qua_t);
% ind_qua4 = (age == age_groups(4) & ind_qua_t);
% ind_qua5 = (age == age_groups(5) & ind_qua_t);
% ind_qua6 = (age == age_groups(6) & ind_qua_t);
% ind_qua7 = (age == age_groups(7) & ind_qua_t);
% ind_qua8 = (age == age_groups(8) & ind_qua_t);
% ind_qua9 = (age == age_groups(9) & ind_qua_t);
% 
% ind_iso1 = (age == age_groups(1) & ind_iso_t);
% ind_iso2 = (age == age_groups(2) & ind_iso_t);
% ind_iso3 = (age == age_groups(3) & ind_iso_t);
% ind_iso4 = (age == age_groups(4) & ind_iso_t);
% ind_iso5 = (age == age_groups(5) & ind_iso_t);
% ind_iso6 = (age == age_groups(6) & ind_iso_t);
% ind_iso7 = (age == age_groups(7) & ind_iso_t);
% ind_iso8 = (age == age_groups(8) & ind_iso_t);
% ind_iso9 = (age == age_groups(9) & ind_iso_t);

ind_imm1 = (age == age_groups(1) & ind_imm);
ind_imm2 = (age == age_groups(2) & ind_imm);
ind_imm3 = (age == age_groups(3) & ind_imm);
ind_imm4 = (age == age_groups(4) & ind_imm);
ind_imm5 = (age == age_groups(5) & ind_imm);
ind_imm6 = (age == age_groups(6) & ind_imm);
ind_imm7 = (age == age_groups(7) & ind_imm);
ind_imm8 = (age == age_groups(8) & ind_imm);
ind_imm9 = (age == age_groups(9) & ind_imm);

ind_dead1 = (age == age_groups(1) & ind_dead & ~ind_dead_i);
ind_dead2 = (age == age_groups(2) & ind_dead & ~ind_dead_i);
ind_dead3 = (age == age_groups(3) & ind_dead & ~ind_dead_i);
ind_dead4 = (age == age_groups(4) & ind_dead & ~ind_dead_i);
ind_dead5 = (age == age_groups(5) & ind_dead & ~ind_dead_i);
ind_dead6 = (age == age_groups(6) & ind_dead & ~ind_dead_i);
ind_dead7 = (age == age_groups(7) & ind_dead & ~ind_dead_i);
ind_dead8 = (age == age_groups(8) & ind_dead & ~ind_dead_i);
ind_dead9 = (age == age_groups(9) & ind_dead & ~ind_dead_i);

ind_dead1_i = (age == age_groups(1) & ind_dead_i);
ind_dead2_i = (age == age_groups(2) & ind_dead_i);
ind_dead3_i = (age == age_groups(3) & ind_dead_i);
ind_dead4_i = (age == age_groups(4) & ind_dead_i);
ind_dead5_i = (age == age_groups(5) & ind_dead_i);
ind_dead6_i = (age == age_groups(6) & ind_dead_i);
ind_dead7_i = (age == age_groups(7) & ind_dead_i);
ind_dead8_i = (age == age_groups(8) & ind_dead_i);
ind_dead9_i = (age == age_groups(9) & ind_dead_i);

% ind_vac1 = (age == age_groups(1) & vac > 0);
% ind_vac2 = (age == age_groups(2) & vac > 0);
% ind_vac3 = (age == age_groups(3) & vac > 0);
% ind_vac4 = (age == age_groups(4) & vac > 0);
% ind_vac5 = (age == age_groups(5) & vac > 0);
% ind_vac6 = (age == age_groups(6) & vac > 0);
% ind_vac7 = (age == age_groups(7) & vac > 0);
% ind_vac8 = (age == age_groups(8) & vac > 0);
% ind_vac9 = (age == age_groups(9) & vac > 0);

f7 = figure(7);
set(f7,'Position',[60 60 1800 1000]);
%set(f7, 'PaperUnits', 'centimeters');
%set(f7, 'PaperPosition', [0 0 100 100]);

%%%% SUSCEPTIBLE %%%%%%%
% subplot(7,9,1)
% plot(x(ind_sus1, 1),x(ind_sus1, 2), 'b o','MarkerSize', 2)
% ylabel('Susceptible')
% set(gca,'XTick', [], 'YTick', [])
% title('1')
% 
% subplot(7,9,2)
% plot(x(ind_sus2, 1),x(ind_sus2, 2), 'b o','MarkerSize', 2)
% set(gca,'XTick', [], 'YTick', [])
% title('2')
% 
% subplot(7,9,3)
% plot(x(ind_sus3, 1),x(ind_sus3, 2), 'b o','MarkerSize', 2)
% set(gca,'XTick', [], 'YTick', [])
% title('3')
% 
% subplot(7,9,4)
% plot(x(ind_sus4, 1),x(ind_sus4, 2), 'b o','MarkerSize', 2)
% set(gca,'XTick', [], 'YTick', [])
% title('4')
% 
% subplot(7,9,5)
% plot(x(ind_sus5, 1),x(ind_sus5, 2), 'b o','MarkerSize', 2)
% set(gca,'XTick', [], 'YTick', [])
% title('5')
% 
% subplot(7,9,6)
% plot(x(ind_sus6, 1),x(ind_sus6, 2), 'b o','MarkerSize', 2)
% set(gca,'XTick', [], 'YTick', [])
% title('6')
% 
% subplot(7,9,7)
% plot(x(ind_sus7, 1),x(ind_sus7, 2), 'b o','MarkerSize', 2)
% set(gca,'XTick', [], 'YTick', [])
% title('7')
% 
% subplot(7,9,8)
% plot(x(ind_sus8, 1),x(ind_sus8, 2), 'b o','MarkerSize', 2)
% set(gca,'XTick', [], 'YTick', [])
% title('8')
% 
% subplot(7,9,9)
% plot(x(ind_sus9, 1),x(ind_sus9, 2), 'b o','MarkerSize', 2)
% set(gca,'XTick', [], 'YTick', [])
% title('9')

%%% EXPOSED %%%%%%%
subplot(5,9,1)
plot(x(ind_exp1, 1),x(ind_exp1, 2), 'm o','MarkerSize', 3)
hold on 
plot(x_i(ind_exp1_i, 1),x(ind_exp1_i, 2), 'b .','MarkerSize', 1)
hold off
ylabel('Exposed','FontSize',12)
box on
set(gca,'XTick', [], 'YTick', [])
title('Age [0-10)','FontSize',11)

subplot(5,9,2)
plot(x(ind_exp2, 1),x(ind_exp2, 2), 'm o','MarkerSize', 3)
hold on 
plot(x_i(ind_exp2_i, 1),x(ind_exp2_i, 2), 'b .','MarkerSize', 1)
hold off
box on
set(gca,'XTick', [], 'YTick', [])
title('Age [10-20)','FontSize',11)

subplot(5,9,3)
plot(x(ind_exp3, 1),x(ind_exp3, 2), 'm o','MarkerSize', 3)
hold on 
plot(x_i(ind_exp3_i, 1),x(ind_exp3_i, 2), 'b .','MarkerSize', 1)
hold off
box on
set(gca,'XTick', [], 'YTick', [])
title('Age [20-30)','FontSize',11)

subplot(5,9,4)
plot(x(ind_exp4, 1),x(ind_exp4, 2), 'm o','MarkerSize', 3)
hold on 
plot(x_i(ind_exp4_i, 1),x(ind_exp4_i, 2), 'b .','MarkerSize', 1)
hold off
box on
set(gca,'XTick', [], 'YTick', [])
title('Age [30-40)','FontSize',11)

subplot(5,9,5)
plot(x(ind_exp5, 1),x(ind_exp5, 2), 'm o','MarkerSize', 3)
hold on 
plot(x_i(ind_exp5_i, 1),x(ind_exp5_i, 2), 'b .','MarkerSize', 1)
hold off
box on
set(gca,'XTick', [], 'YTick', [])
title('Age [40-50)','FontSize',11)

subplot(5,9,6)
plot(x(ind_exp6, 1),x(ind_exp6, 2), 'm o','MarkerSize', 3)
hold on 
plot(x_i(ind_exp6_i, 1),x(ind_exp6_i, 2), 'b .','MarkerSize', 1)
hold off
box on
set(gca,'XTick', [], 'YTick', [])
title('Age [50-60)','FontSize',11)

subplot(5,9,7)
plot(x(ind_exp7, 1),x(ind_exp7, 2), 'm o','MarkerSize', 3)
hold on 
plot(x_i(ind_exp7_i, 1),x(ind_exp7_i, 2), 'b .','MarkerSize', 1)
hold off
box on
set(gca,'XTick', [], 'YTick', [])
title('Age [60-70)','FontSize',11)

subplot(5,9,8)
plot(x(ind_exp8, 1),x(ind_exp8, 2), 'm o','MarkerSize', 3)
hold on 
plot(x_i(ind_exp8_i, 1),x(ind_exp8_i, 2), 'b .','MarkerSize', 1)
hold off
box on
set(gca,'XTick', [], 'YTick', [])
title('Age [70-80)','FontSize',11)

subplot(5,9,9)
plot(x(ind_exp9, 1),x(ind_exp9, 2), 'm o','MarkerSize', 3)
hold on 
plot(x_i(ind_exp9_i, 1),x(ind_exp9_i, 2), 'b .','MarkerSize', 1)
hold off
box on
set(gca,'XTick', [], 'YTick', [])
title('Age 80+','FontSize',11)

%%% INFECTED %%%%%%%
subplot(5,9,10)
plot(x(ind_inf1, 1),x(ind_inf1, 2), 'r o','MarkerSize', 3)
hold on 
plot(x_i(ind_inf1_i, 1),x(ind_inf1_i, 2), 'b .','MarkerSize', 1)
hold off
box on
ylabel('Infected','FontSize',12)
set(gca,'XTick', [], 'YTick', [])

subplot(5,9,11)
plot(x(ind_inf2, 1),x(ind_inf2, 2), 'r o','MarkerSize', 3)
hold on 
plot(x_i(ind_inf2_i, 1),x(ind_inf2_i, 2), 'b .','MarkerSize', 1)
hold off
box on
set(gca,'XTick', [], 'YTick', [])

subplot(5,9,12)
plot(x(ind_inf3, 1),x(ind_inf3, 2), 'r o','MarkerSize', 3)
hold on 
plot(x_i(ind_inf3_i, 1),x(ind_inf3_i, 2), 'b .','MarkerSize', 1)
hold off
box on
set(gca,'XTick', [], 'YTick', [])

subplot(5,9,13)
plot(x(ind_inf4, 1),x(ind_inf4, 2), 'r o','MarkerSize', 3)
hold on 
plot(x_i(ind_inf4_i, 1),x(ind_inf4_i, 2), 'b .','MarkerSize', 1)
hold off
box on
set(gca,'XTick', [], 'YTick', [])

subplot(5,9,14)
plot(x(ind_inf5, 1),x(ind_inf5, 2), 'r o','MarkerSize', 3)
hold on 
plot(x_i(ind_inf5_i, 1),x(ind_inf5_i, 2), 'b .','MarkerSize', 1)
hold off
box on
set(gca,'XTick', [], 'YTick', [])

subplot(5,9,15)
plot(x(ind_inf6, 1),x(ind_inf6, 2), 'r o','MarkerSize', 3)
hold on 
plot(x_i(ind_inf6_i, 1),x(ind_inf6_i, 2), 'b .','MarkerSize', 1)
hold off
box on
set(gca,'XTick', [], 'YTick', [])

subplot(5,9,16)
plot(x(ind_inf7, 1),x(ind_inf7, 2), 'r o','MarkerSize', 3)
hold on 
plot(x_i(ind_inf7_i, 1),x(ind_inf7_i, 2), 'b .','MarkerSize', 1)
hold off
box on
set(gca,'XTick', [], 'YTick', [])

subplot(5,9,17)
plot(x(ind_inf8, 1),x(ind_inf8, 2), 'r o','MarkerSize', 3)
hold on 
plot(x_i(ind_inf8_i, 1),x(ind_inf8_i, 2), 'b .','MarkerSize', 1)
hold off
box on
set(gca,'XTick', [], 'YTick', [])

subplot(5,9,18)
plot(x(ind_inf9, 1),x(ind_inf9, 2), 'r o','MarkerSize', 3)
hold on 
plot(x_i(ind_inf9_i, 1),x(ind_inf9_i, 2), 'b .','MarkerSize', 1)
hold off
box on
set(gca,'XTick', [], 'YTick', [])

%%% SEV INFECTED %%%%%%%
subplot(5,9,19)
plot(x(ind_sev_inf1, 1),x(ind_sev_inf1, 2), 'r *','MarkerSize', 3)
hold on 
plot(x_i(ind_sev_inf1_i, 1),x(ind_sev_inf1_i, 2), 'b .','MarkerSize', 1)
hold off
box on
ylabel({'Severely'; 'Infected'},'FontSize',12)
set(gca,'XTick', [], 'YTick', [])

subplot(5,9,20)
plot(x(ind_sev_inf2, 1),x(ind_sev_inf2, 2), 'r *','MarkerSize', 3)
hold on 
plot(x_i(ind_sev_inf2_i, 1),x(ind_sev_inf2_i, 2), 'b .','MarkerSize', 1)
hold off
box on
set(gca,'XTick', [], 'YTick', [])

subplot(5,9,21)
plot(x(ind_sev_inf3, 1),x(ind_sev_inf3, 2), 'r *','MarkerSize', 3)
hold on 
plot(x_i(ind_sev_inf3_i, 1),x(ind_sev_inf3_i, 2), 'b .','MarkerSize', 1)
hold off
box on
set(gca,'XTick', [], 'YTick', [])

subplot(5,9,22)
plot(x(ind_sev_inf4, 1),x(ind_sev_inf4, 2), 'r *','MarkerSize', 3)
hold on 
plot(x_i(ind_sev_inf4_i, 1),x(ind_sev_inf4_i, 2), 'b .','MarkerSize', 1)
hold off
box on
set(gca,'XTick', [], 'YTick', [])

subplot(5,9,23)
plot(x(ind_sev_inf5, 1),x(ind_sev_inf5, 2), 'r *','MarkerSize', 3)
hold on 
plot(x_i(ind_sev_inf5_i, 1),x(ind_sev_inf5_i, 2), 'b .','MarkerSize', 1)
hold off
box on
set(gca,'XTick', [], 'YTick', [])

subplot(5,9,24)
plot(x(ind_sev_inf6, 1),x(ind_sev_inf6, 2), 'r *','MarkerSize', 3)
hold on 
plot(x_i(ind_sev_inf6_i, 1),x(ind_sev_inf6_i, 2), 'b .','MarkerSize', 1)
hold off
box on
set(gca,'XTick', [], 'YTick', [])

subplot(5,9,25)
plot(x(ind_sev_inf7, 1),x(ind_sev_inf7, 2), 'r *','MarkerSize', 3)
hold on 
plot(x_i(ind_sev_inf7_i, 1),x(ind_sev_inf7_i, 2), 'b .','MarkerSize', 1)
hold off
box on
set(gca,'XTick', [], 'YTick', [])

subplot(5,9,26)
plot(x(ind_sev_inf8, 1),x(ind_sev_inf8, 2), 'r *','MarkerSize', 3)
hold on 
plot(x_i(ind_sev_inf8_i, 1),x(ind_sev_inf8_i, 2), 'b .','MarkerSize', 1)
hold off
box on
set(gca,'XTick', [], 'YTick', [])

subplot(5,9,27)
plot(x(ind_sev_inf9, 1),x(ind_sev_inf9, 2), 'r *','MarkerSize', 3)
hold on 
plot(x_i(ind_sev_inf9_i, 1),x(ind_sev_inf9_i, 2), 'b .','MarkerSize', 1)
hold off
box on
set(gca,'XTick', [], 'YTick', [])

%%% DEAD %%%%%%%
subplot(5,9,28)
plot(x(ind_dead1, 1),x(ind_dead1, 2), 'k o','MarkerSize', 3)
hold on 
plot(x_i(ind_dead1_i, 1),x(ind_dead1_i, 2), 'b .','MarkerSize', 1)
hold off
box on
ylabel('Dead','FontSize',12)
set(gca,'XTick', [], 'YTick', [])

subplot(5,9,29)
plot(x(ind_dead2, 1),x(ind_dead2, 2), 'k o','MarkerSize', 3)
hold on 
plot(x_i(ind_dead2_i, 1),x(ind_dead2_i, 2), 'b .','MarkerSize', 1)
hold off
box on
set(gca,'XTick', [], 'YTick', [])

subplot(5,9,30)
plot(x(ind_dead3, 1),x(ind_dead3, 2), 'k o','MarkerSize', 3)
hold on 
plot(x_i(ind_dead3_i, 1),x(ind_dead3_i, 2), 'b .','MarkerSize', 1)
hold off
box on
set(gca,'XTick', [], 'YTick', [])

subplot(5,9,31)
plot(x(ind_dead4, 1),x(ind_dead4, 2), 'k o','MarkerSize', 3)
hold on 
plot(x_i(ind_dead4_i, 1),x(ind_dead4_i, 2), 'b .','MarkerSize', 1)
hold off
box on
set(gca,'XTick', [], 'YTick', [])

subplot(5,9,32)
plot(x(ind_dead5, 1),x(ind_dead5, 2), 'k o','MarkerSize', 3)
hold on 
plot(x_i(ind_dead5_i, 1),x(ind_dead5_i, 2), 'b .','MarkerSize', 1)
hold off
box on
set(gca,'XTick', [], 'YTick', [])

subplot(5,9,33)
plot(x(ind_dead6, 1),x(ind_dead6, 2), 'k o','MarkerSize', 3)
hold on 
plot(x_i(ind_dead6_i, 1),x(ind_dead6_i, 2), 'b .','MarkerSize', 1)
hold off
box on
set(gca,'XTick', [], 'YTick', [])

subplot(5,9,34)
plot(x(ind_dead7, 1),x(ind_dead7, 2), 'k o','MarkerSize', 3)
hold on 
plot(x_i(ind_dead7_i, 1),x(ind_dead7_i, 2), 'b .','MarkerSize', 1)
hold off
box on
set(gca,'XTick', [], 'YTick', [])

subplot(5,9,35)
plot(x(ind_dead8, 1),x(ind_dead8, 2), 'k o','MarkerSize', 3)
hold on 
plot(x_i(ind_dead8_i, 1),x(ind_dead8_i, 2), 'b .','MarkerSize', 1)
hold off
box on
set(gca,'XTick', [], 'YTick', [])

subplot(5,9,36)
plot(x(ind_dead9, 1),x(ind_dead9, 2), 'k o','MarkerSize', 3)
hold on 
plot(x_i(ind_dead9_i, 1),x(ind_dead9_i, 2), 'b .','MarkerSize', 1)
hold off
box on
set(gca,'XTick', [], 'YTick', [])

%%% VACC. IMMUNIZED %%%%%%%
subplot(5,9,37)
plot(x(ind_imm1, 1),x(ind_imm1, 2), 'g .','MarkerSize', 2)
box on
ylabel({'Vaccinated'; 'Immunized'},'FontSize',12)
box on
set(gca,'XTick', [], 'YTick', [])

subplot(5,9,38)
plot(x(ind_imm2, 1),x(ind_imm2, 2), 'g .','MarkerSize', 2)
box on
set(gca,'XTick', [], 'YTick', [])

subplot(5,9,39)
plot(x(ind_imm3, 1),x(ind_imm3, 2), 'g .','MarkerSize', 2)
box on
set(gca,'XTick', [], 'YTick', [])

subplot(5,9,40)
plot(x(ind_imm4, 1),x(ind_imm4, 2), 'g .','MarkerSize', 2)
box on
set(gca,'XTick', [], 'YTick', [])

subplot(5,9,41)
plot(x(ind_imm5, 1),x(ind_imm5, 2), 'g .','MarkerSize', 2)
box on
set(gca,'XTick', [], 'YTick', [])

subplot(5,9,42)
plot(x(ind_imm6, 1),x(ind_imm6, 2), 'g .','MarkerSize', 2)
box on
set(gca,'XTick', [], 'YTick', [])

subplot(5,9,43)
plot(x(ind_imm7, 1),x(ind_imm7, 2), 'g .','MarkerSize', 2)
box on
set(gca,'XTick', [], 'YTick', [])

subplot(5,9,44)
plot(x(ind_imm8, 1),x(ind_imm8, 2), 'g .','MarkerSize', 2)
box on
set(gca,'XTick', [], 'YTick', [])

subplot(5,9,45)
plot(x(ind_imm9, 1),x(ind_imm9, 2), 'g .','MarkerSize', 2)
box on
set(gca,'XTick', [], 'YTick', [])

%%% VACCINATED %%%%%%%
% subplot(6,9,46)
% plot(x(ind_vac1, 1),x(ind_vac1, 2), 'c ^','MarkerSize', 2, 'MarkerFaceColor', 'c')
% ylabel('Vaccinated','FontSize',11,'FontWeight','bold')
% box on
% set(gca,'XTick', [], 'YTick', [])
% 
% subplot(6,9,47)
% plot(x(ind_vac2, 1),x(ind_vac2, 2), 'c ^','MarkerSize', 2, 'MarkerFaceColor', 'c')
% box on
% set(gca,'XTick', [], 'YTick', [])
% 
% subplot(6,9,48)
% plot(x(ind_vac3, 1),x(ind_vac3, 2), 'c ^','MarkerSize', 2, 'MarkerFaceColor', 'c')
% box on
% set(gca,'XTick', [], 'YTick', [])
% 
% subplot(6,9,49)
% plot(x(ind_vac4, 1),x(ind_vac4, 2), 'c ^','MarkerSize', 2, 'MarkerFaceColor', 'c')
% box on
% set(gca,'XTick', [], 'YTick', [])
% 
% subplot(6,9,50)
% plot(x(ind_vac5, 1),x(ind_vac5, 2), 'c ^','MarkerSize', 2, 'MarkerFaceColor', 'c')
% box on
% set(gca,'XTick', [], 'YTick', [])
% 
% subplot(6,9,51)
% plot(x(ind_vac6, 1),x(ind_vac6, 2), 'c ^','MarkerSize', 2, 'MarkerFaceColor', 'c')
% box on
% set(gca,'XTick', [], 'YTick', [])
% 
% subplot(6,9,52)
% plot(x(ind_vac7, 1),x(ind_vac7, 2), 'c ^','MarkerSize', 2, 'MarkerFaceColor', 'c')
% box on
% set(gca,'XTick', [], 'YTick', [])
% 
% subplot(6,9,53)
% plot(x(ind_vac8, 1),x(ind_vac8, 2), 'c ^','MarkerSize', 2, 'MarkerFaceColor', 'c')
% box on
% set(gca,'XTick', [], 'YTick', [])
% 
% subplot(6,9,54)
% plot(x(ind_vac9, 1),x(ind_vac9, 2), 'c ^','MarkerSize', 2, 'MarkerFaceColor', 'c')
% box on
% set(gca,'XTick', [], 'YTick', [])

if save_plt
    filename7 = sprintf('%s/ind_%d.png', path, ind);
    saveas(f7, filename7);
    %hgexport(f2, filename, hgexport('factorystyle'), 'Format', 'png')
    %export_fig(filename2)
end
