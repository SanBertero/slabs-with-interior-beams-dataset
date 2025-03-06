%% Preliminaries
clear
close all
clc

%% Load Dataset
load RunDataInteriorBeams_15ft.mat

%% Parse Data
% Dimension 2: Aspect ratio (Beta)
% Dimension 3: Stiffness ratio (Alpha)

for i=1:size(Losas,1)
    for j=1:size(Losas,2)       

        % True Distortion
        DistReal(:,i,j) = max(Losas{i,j}.LoadSus{:,2:9}');

        % Approximate Distortion
        DistProp(:,i,j) = Losas{i,j}.LoadSus{:,10};

        % Alternative Approximate Distortion
        DistRel(:,i,j) = Losas{i,j}.LoadSus{:,14};

        % Distortion using long span
        DistLong(:,i,j) = Losas{i,j}.LoadSus{:,12};

        % Distortion using short span
        DistShort(:,i,j) = Losas{i,j}.LoadSus{:,13};

        % Distortion using diagonal
        DistDiag(:,i,j) = Losas{i,j}.LoadSus{:,11};

        % Distortion lines

        % long span between columns
        Dist1(:,i,j) = max(Losas{i,j}.LoadSus{:,[2 4]}');

        % short span between columns
        Dist2(:,i,j) = max(Losas{i,j}.LoadSus{:,[3 5]}');

        % long mid-span
        Dist3(:,i,j) = Losas{i,j}.LoadSus{:,[6]}';

        % short mid-span
        Dist4(:,i,j) = Losas{i,j}.LoadSus{:,[7]}';

        % diagonal
        Dist5(:,i,j) = max(Losas{i,j}.LoadSus{:,[8 9]}');

        % Beta
        beta(i) = Losas{i,j}.Beta;
        % Alpha
        alpha(j) = Losas{i,j}.Alpha;

    end
end

disp(DistReal)
disp(DistProp)
disp(DistProp./DistReal)

%% Load "Typical Design" Dataset

load RunDataTypicalBeams.mat

%% Parse Data

for i=1:size(Losas,1)
    for j=1:1

        % True Distortion
        DistReal2(:,i) = max(Losas{i,j}.LoadSus{:,2:9}');

        % Approximate Distortion
        DistProp2(:,i) = Losas{i,j}.LoadSus{:,10};

        % Alternative Approximate Distortion
        DistRel2(:,i) = Losas{i,j}.LoadSus{:,14};

        % Distortion using long span
        DistLong2(:,i) = Losas{i,j}.LoadSus{:,12};

        % Distortion using short span
        DistShort2(:,i) = Losas{i,j}.LoadSus{:,13};

        % Distortion using diagonal
        DistDiag2(:,i) = Losas{i,j}.LoadSus{:,11};

        % Distortion lines

        % long span between columns
        Dist12(:,i) = max(Losas{i,j}.LoadSus{:,[2 4]}');

        % short span between columns
        Dist22(:,i) = max(Losas{i,j}.LoadSus{:,[3 5]}');

        % long mid-span
        Dist32(:,i) = Losas{i,j}.LoadSus{:,[6]}';

        % short mid-span
        Dist42(:,i) = Losas{i,j}.LoadSus{:,[7]}';

        % diagonal
        Dist52(:,i) = max(Losas{i,j}.LoadSus{:,[8 9]}');

        % Beta
        beta2(i) = Losas{i,j}.Beta;

        % Alpha
        alpha2(i,:) = Losas{i,j}.Alpha;

    end
end

disp(DistReal)
disp(DistProp)
disp(DistProp./DistReal)

%% Plots
% Preliminaries

% plot limits
lims = [0.5 2];
% number of rows
nr = 3;
% number of columns
nc = 2;

% Panel ID
Corner = 1;
Long = 2;
Short = 4;
Center = 5;

% Alpha ID
Alpha_ind = [1 4 5 6 7 8];

%% Plots A: "winning distortion"

% Corner Panels
figure('units','inch','position',[1,1,6,8])
tiledlayout(3,2, 'TileSpacing', 'compact'); 
ax = gobjects(0);

for j=1:numel(beta)
    ax(j) = nexttile;
    fill(alpha2(j,1)*[0.9 1.1 1.1 0.9],[0 0 2 2],[0.5 0.5 0.5],'facealpha',0.2,'EdgeColor','none')
    hold on
    plot(alpha,squeeze(Dist1(Corner,j,:))./squeeze(DistReal(Corner,j,:)),'LineStyle','-','Marker','^','MarkerFaceColor','r','color','r')
    plot(alpha,squeeze(Dist2(Corner,j,:))./squeeze(DistReal(Corner,j,:)),'LineStyle','-','Marker','v','MarkerFaceColor','[1, 0.647, 0]','color','[1, 0.647, 0]')
    plot(alpha,squeeze(Dist3(Corner,j,:))./squeeze(DistReal(Corner,j,:)),'LineStyle','-.','Marker','diamond','MarkerFaceColor','[0.4, 0.4, 0.4]','color','[0.4, 0.4, 0.4]')
    plot(alpha,squeeze(Dist4(Corner,j,:))./squeeze(DistReal(Corner,j,:)),'LineStyle','-.','Marker','square','MarkerFaceColor','m','color','m')
    plot(alpha,squeeze(Dist5(Corner,j,:))./squeeze(DistReal(Corner,j,:)),'LineStyle','--','Marker','o','MarkerFaceColor','b','color','b')

    if j==numel(beta)
        legend('','\theta_{cl}','\theta_{cs}','\theta_{ml}','\theta_{ms}','\theta_{d}','Location','southwest')
    end

    ylim([0.6 1.1])
    set(gca,'YTick',0.6:0.1:1.1)

    if j==1||j==3||j==5
        ylabel('$\theta_{i}/\theta_{max}$','Interpreter','latex','FontSize',6)
    else
        set(gca,'YTickLabels','')
    end

    set(gca,'XTick',[0 1 2 4 8 16])
    xlim([0 16])

    if j>4
        xlabel('$\alpha_{m}$','Interpreter','latex','FontSize',6)
    else
        set(gca,'XTickLabels','')
    end

    title(['Corner Panel $\beta=$' num2str(round(beta(j),1))],'Interpreter','latex','FontSize',6)
    grid on
    fontsize(gcf, 12, 'points')
    set(gca,"XScale","log")
end

linkaxes(ax,'xy')
annotation('textbox', [0.08, 0.03, 0.10, 0.04],'LineStyle',"none" ,'String', 'without beams')
annotation('textbox', [0.42, 0.03, 0.44, 0.04],'LineStyle',"none" ,'String', {'rigid','beams'})
annotation('textbox', [0.53, 0.03, 0.55, 0.04],'LineStyle',"none" ,'String', {'without', 'beams'})
annotation('textbox', [0.86, 0.03, 0.88, 0.04],'LineStyle',"none" ,'String', {'rigid','beams'})

saveas(gcf,'Fig8_L15_CornerPanels.png')

% Central Panels
figure('units','inch','position',[2,1,6,8])
tiledlayout(3,2, 'TileSpacing', 'compact'); 
ax = gobjects(0);

for j=1:numel(beta)
    ax(j) = nexttile;
    fill(alpha2(j,4)*[0.9 1.1 1.1 0.9],[0 0 2 2],[0.5 0.5 0.5],'facealpha',0.2,'EdgeColor','none')
    hold on
    plot(alpha,squeeze(Dist1(Center,j,:))./squeeze(DistReal(Center,j,:)),'LineStyle','-','Marker','^','MarkerFaceColor','r','color','r')
    plot(alpha,squeeze(Dist2(Center,j,:))./squeeze(DistReal(Center,j,:)),'LineStyle','-','Marker','v','MarkerFaceColor','[1, 0.647, 0]','color','[1, 0.647, 0]')
    plot(alpha,squeeze(Dist3(Center,j,:))./squeeze(DistReal(Center,j,:)),'LineStyle','-.','Marker','diamond','MarkerFaceColor','[0.4, 0.4, 0.4]','color','[0.4, 0.4, 0.4]')
    plot(alpha,squeeze(Dist4(Center,j,:))./squeeze(DistReal(Center,j,:)),'LineStyle','-.','Marker','square','MarkerFaceColor','m','color','m')
    plot(alpha,squeeze(Dist5(Center,j,:))./squeeze(DistReal(Center,j,:)),'LineStyle','--','Marker','o','MarkerFaceColor','b','color','b')

    if j==numel(beta)
        legend('','\theta_{cl}','\theta_{cs}','\theta_{ml}','\theta_{ms}','\theta_{d}','Location','southwest')
    end

    ylim([0.6 1.1])
    set(gca,'YTick',0.6:0.1:1.1)

    if j==1||j==3||j==5
        ylabel('$\theta_{i}/\theta_{max}$','Interpreter','latex','FontSize',6)
    else
        set(gca,'YTickLabels','')
    end

    set(gca,'XTick',[0 1 2 4 8 16])
    xlim([0 16])

    if j>4
        xlabel('$\alpha_{m}$','Interpreter','latex','FontSize',6)
    else
        set(gca,'XTickLabels','')
    end

    title(['Central Panel $\beta=$' num2str(round(beta(j),1))],'Interpreter','latex','FontSize',6)
    grid on
    fontsize(gcf, 12, 'points')
    set(gca,"XScale","log")
end

linkaxes(ax,'xy')
annotation('textbox', [0.08, 0.03, 0.10, 0.04],'LineStyle',"none" ,'String', 'without beams')
annotation('textbox', [0.42, 0.03, 0.44, 0.04],'LineStyle',"none" ,'String', {'rigid','beams'})
annotation('textbox', [0.53, 0.03, 0.55, 0.04],'LineStyle',"none" ,'String', {'without', 'beams'})
annotation('textbox', [0.86, 0.03, 0.88, 0.04],'LineStyle',"none" ,'String', {'rigid','beams'})

saveas(gcf,'Fig9_L15_CentralPanels.png')


% Short Edge Panel
figure('units','inch','position',[3,1,6,8])
tiledlayout(3,2, 'TileSpacing', 'compact'); 
ax = gobjects(0);

for j=1:numel(beta)
    ax(j) = nexttile;
    fill(alpha2(j,1)*[0.9 1.1 1.1 0.9],[0 0 2 2],[0.5 0.5 0.5],'facealpha',0.2,'EdgeColor','none')
    hold on
    plot(alpha,squeeze(Dist1(Short,j,:))./squeeze(DistReal(Short,j,:)),'LineStyle','-','Marker','^','MarkerFaceColor','r','color','r')
    plot(alpha,squeeze(Dist2(Short,j,:))./squeeze(DistReal(Short,j,:)),'LineStyle','-','Marker','v','MarkerFaceColor','[1, 0.647, 0]','color','[1, 0.647, 0]')
    plot(alpha,squeeze(Dist3(Short,j,:))./squeeze(DistReal(Short,j,:)),'LineStyle','-.','Marker','diamond','MarkerFaceColor','[0.4, 0.4, 0.4]','color','[0.4, 0.4, 0.4]')
    plot(alpha,squeeze(Dist4(Short,j,:))./squeeze(DistReal(Short,j,:)),'LineStyle','-.','Marker','square','MarkerFaceColor','m','color','m')
    plot(alpha,squeeze(Dist5(Short,j,:))./squeeze(DistReal(Short,j,:)),'LineStyle','--','Marker','o','MarkerFaceColor','b','color','b')

    if j==numel(beta)
        legend('','\theta_{cl}','\theta_{cs}','\theta_{ml}','\theta_{ms}','\theta_{d}','Location','southwest')
    end

    ylim([0.6 1.1])
    set(gca,'YTick',0.6:0.1:1.1)

    if j==1||j==3||j==5
        ylabel('$\theta_{i}/\theta_{max}$','Interpreter','latex','FontSize',6)
    else
        set(gca,'YTickLabels','')
    end

    set(gca,'XTick',[0 1 2 4 8 16])
    xlim([0 16])

    if j>4
        xlabel('$\alpha_{m}$','Interpreter','latex','FontSize',6)
    else
        set(gca,'XTickLabels','')
    end

    title(['Short Edge Panel $\beta=$' num2str(round(beta(j),1))],'Interpreter','latex','FontSize',6)
    grid on
    fontsize(gcf, 12, 'points')
    set(gca,"XScale","log")
end

linkaxes(ax,'xy')
annotation('textbox', [0.08, 0.03, 0.10, 0.04],'LineStyle',"none" ,'String', 'without beams')
annotation('textbox', [0.42, 0.03, 0.44, 0.04],'LineStyle',"none" ,'String', {'rigid','beams'})
annotation('textbox', [0.53, 0.03, 0.55, 0.04],'LineStyle',"none" ,'String', {'without', 'beams'})
annotation('textbox', [0.86, 0.03, 0.88, 0.04],'LineStyle',"none" ,'String', {'rigid','beams'})

% saveas(gcf,'L15_SedgePanels.png')

% Long Edge Panels
figure('units','inch','position',[4,1,6,8])
tiledlayout(3,2, 'TileSpacing', 'compact'); 
ax = gobjects(0);

for j=1:numel(beta)
    ax(j) = nexttile;
    fill(alpha2(j,1)*[0.9 1.1 1.1 0.9],[0 0 2 2],[0.5 0.5 0.5],'facealpha',0.2,'EdgeColor','none')
    hold on
    plot(alpha,squeeze(Dist1(Long,j,:))./squeeze(DistReal(Long,j,:)),'LineStyle','-','Marker','^','MarkerFaceColor','r','color','r')
    plot(alpha,squeeze(Dist2(Long,j,:))./squeeze(DistReal(Long,j,:)),'LineStyle','-','Marker','v','MarkerFaceColor','[1, 0.647, 0]','color','[1, 0.647, 0]')
    plot(alpha,squeeze(Dist3(Long,j,:))./squeeze(DistReal(Long,j,:)),'LineStyle','-.','Marker','diamond','MarkerFaceColor','[0.4, 0.4, 0.4]','color','[0.4, 0.4, 0.4]')
    plot(alpha,squeeze(Dist4(Long,j,:))./squeeze(DistReal(Long,j,:)),'LineStyle','-.','Marker','square','MarkerFaceColor','m','color','m')
    plot(alpha,squeeze(Dist5(Long,j,:))./squeeze(DistReal(Long,j,:)),'LineStyle','--','Marker','o','MarkerFaceColor','b','color','b')

    if j==numel(beta)
        legend('','\theta_{cl}','\theta_{cs}','\theta_{ml}','\theta_{ms}','\theta_{d}','Location','southwest')
    end

    ylim([0.6 1.1])
    set(gca,'YTick',0.6:0.1:1.1)

    if j==1||j==3||j==5
        ylabel('$\theta_{i}/\theta_{max}$','Interpreter','latex','FontSize',6)
    else
        set(gca,'YTickLabels','')
    end

    set(gca,'XTick',[0 1 2 4 8 16])
    xlim([0 16])

    if j>4
        xlabel('$\alpha_{m}$','Interpreter','latex','FontSize',6)
    else
        set(gca,'XTickLabels','')
    end

    title(['Long Edge Panel $\beta=$' num2str(round(beta(j),1))],'Interpreter','latex','FontSize',6)
    grid on
    fontsize(gcf, 12, 'points')
    set(gca,"XScale","log")
end

linkaxes(ax,'xy')
annotation('textbox', [0.08, 0.03, 0.10, 0.04],'LineStyle',"none" ,'String', 'without beams')
annotation('textbox', [0.42, 0.03, 0.44, 0.04],'LineStyle',"none" ,'String', {'rigid','beams'})
annotation('textbox', [0.53, 0.03, 0.55, 0.04],'LineStyle',"none" ,'String', {'without', 'beams'})
annotation('textbox', [0.86, 0.03, 0.88, 0.04],'LineStyle',"none" ,'String', {'rigid','beams'})

% saveas(gcf,'L15_LedgePanels.png')

%% Plots B: "simple formulas"


aind = 1;
figure('units','inch','position',[5,1,6,11])
tiledlayout(4,2, 'TileSpacing', 'compact');
ax = gobjects(0);

ax(1) = nexttile;
plot(beta,squeeze(DistLong(Center,:,aind))./squeeze(DistReal(Center,:,aind)),'LineStyle','-','Marker','^','MarkerFaceColor','r','color','r')
hold on
plot(beta,squeeze(DistShort(Center,:,aind))./squeeze(DistReal(Center,:,aind)),'LineStyle','-.','Marker','square','MarkerFaceColor','b','color','b')
plot(beta,squeeze(DistDiag(Center,:,aind))./squeeze(DistReal(Center,:,aind)),'LineStyle','--','Marker','o','MarkerFaceColor','[0.4 0.4 0.4]','color','[0.4 0.4 0.4]')
yline(1,'k-','LineWidth',1)
ylabel('$\theta_{i}/\theta_{max}$','Interpreter','latex')
ylim([0.5 2])
set(gca,'XTick',1:0.25:2)
set(gca,'YTick',0.5:0.25:2)
set(gca,'XTickLabels','')
title(['Central Panel $\alpha_{m}=$' num2str(alpha(aind))],'Interpreter','latex')
grid on
fontsize(gcf, 12, 'points')

ax(2) = nexttile;
plot(beta,squeeze(DistLong(Corner,:,aind))./squeeze(DistReal(Corner,:,aind)),'LineStyle','-','Marker','^','MarkerFaceColor','r','color','r')
hold on
plot(beta,squeeze(DistShort(Corner,:,aind))./squeeze(DistReal(Corner,:,aind)),'LineStyle','-.','Marker','square','MarkerFaceColor','b','color','b')
plot(beta,squeeze(DistDiag(Corner,:,aind))./squeeze(DistReal(Corner,:,aind)),'LineStyle','--','Marker','o','MarkerFaceColor','[0.4 0.4 0.4]','color','[0.4 0.4 0.4]')
yline(1,'k-','LineWidth',1)
ylim([0.5 2])
set(gca,'XTick',1:0.25:2)
set(gca,'YTick',0.5:0.25:2)
set(gca,'XTickLabels','')
set(gca,'YTickLabels','')
title(['Corner Panel $\alpha_{m}=$' num2str(alpha(aind))],'Interpreter','latex')
grid on
fontsize(gcf, 12, 'points')

aind = 4;
ax(3) = nexttile;
plot(beta,squeeze(DistLong(Center,:,aind))./squeeze(DistReal(Center,:,aind)),'LineStyle','-','Marker','^','MarkerFaceColor','r','color','r')
hold on
plot(beta,squeeze(DistShort(Center,:,aind))./squeeze(DistReal(Center,:,aind)),'LineStyle','-.','Marker','square','MarkerFaceColor','b','color','b')
plot(beta,squeeze(DistDiag(Center,:,aind))./squeeze(DistReal(Center,:,aind)),'LineStyle','--','Marker','o','MarkerFaceColor','[0.4 0.4 0.4]','color','[0.4 0.4 0.4]')
yline(1,'k-','LineWidth',1)
ylabel('$\theta_{i}/\theta_{max}$','Interpreter','latex')
ylim([0.5 2])
set(gca,'XTick',1:0.25:2)
set(gca,'YTick',0.5:0.25:2)
set(gca,'XTickLabels','')
title(['Central Panel $\alpha_{m}=$' num2str(alpha(aind))],'Interpreter','latex')
grid on
fontsize(gcf, 12, 'points')

ax(4) = nexttile;
plot(beta,squeeze(DistLong(Corner,:,aind))./squeeze(DistReal(Corner,:,aind)),'LineStyle','-','Marker','^','MarkerFaceColor','r','color','r')
hold on
plot(beta,squeeze(DistShort(Corner,:,aind))./squeeze(DistReal(Corner,:,aind)),'LineStyle','-.','Marker','square','MarkerFaceColor','b','color','b')
plot(beta,squeeze(DistDiag(Corner,:,aind))./squeeze(DistReal(Corner,:,aind)),'LineStyle','--','Marker','o','MarkerFaceColor','[0.4 0.4 0.4]','color','[0.4 0.4 0.4]')
yline(1,'k-','LineWidth',1)
ylim([0.5 2])
set(gca,'XTick',1:0.25:2)
set(gca,'YTick',0.5:0.25:2)
set(gca,'XTickLabels','')
set(gca,'YTickLabels','')
title(['Corner Panel $\alpha_{m}=$' num2str(alpha(aind))],'Interpreter','latex')
grid on
fontsize(gcf, 12, 'points')

aind = 5;
ax(5) = nexttile;
plot(beta,squeeze(DistLong(Center,:,aind))./squeeze(DistReal(Center,:,aind)),'LineStyle','-','Marker','^','MarkerFaceColor','r','color','r')
hold on
plot(beta,squeeze(DistShort(Center,:,aind))./squeeze(DistReal(Center,:,aind)),'LineStyle','-.','Marker','square','MarkerFaceColor','b','color','b')
plot(beta,squeeze(DistDiag(Center,:,aind))./squeeze(DistReal(Center,:,aind)),'LineStyle','--','Marker','o','MarkerFaceColor','[0.4 0.4 0.4]','color','[0.4 0.4 0.4]')
yline(1,'k-','LineWidth',1)
ylabel('$\theta_{i}/\theta_{max}$','Interpreter','latex')
ylim([0.5 2])
set(gca,'XTick',1:0.25:2)
set(gca,'YTick',0.5:0.25:2)
set(gca,'XTickLabels','')
title(['Central Panel $\alpha_{m}=$' num2str(alpha(aind))],'Interpreter','latex')
grid on
fontsize(gcf, 12, 'points')

ax(6) = nexttile;
plot(beta,squeeze(DistLong(Corner,:,aind))./squeeze(DistReal(Corner,:,aind)),'LineStyle','-','Marker','^','MarkerFaceColor','r','color','r')
hold on
plot(beta,squeeze(DistShort(Corner,:,aind))./squeeze(DistReal(Corner,:,aind)),'LineStyle','-.','Marker','square','MarkerFaceColor','b','color','b')
plot(beta,squeeze(DistDiag(Corner,:,aind))./squeeze(DistReal(Corner,:,aind)),'LineStyle','--','Marker','o','MarkerFaceColor','[0.4 0.4 0.4]','color','[0.4 0.4 0.4]')
yline(1,'k-','LineWidth',1)
ylim([0.5 2])
set(gca,'XTick',1:0.25:2)
set(gca,'YTick',0.5:0.25:2)
set(gca,'XTickLabels','')
set(gca,'YTickLabels','')
title(['Corner Panel $\alpha_{m}=$' num2str(alpha(aind))],'Interpreter','latex')
grid on
fontsize(gcf, 12, 'points')

aind = 7;
ax(7) = nexttile;
plot(beta,squeeze(DistLong(Center,:,aind))./squeeze(DistReal(Center,:,aind)),'LineStyle','-','Marker','^','MarkerFaceColor','r','color','r')
hold on
plot(beta,squeeze(DistShort(Center,:,aind))./squeeze(DistReal(Center,:,aind)),'LineStyle','-.','Marker','square','MarkerFaceColor','b','color','b')
plot(beta,squeeze(DistDiag(Center,:,aind))./squeeze(DistReal(Center,:,aind)),'LineStyle','--','Marker','o','MarkerFaceColor','[0.4 0.4 0.4]','color','[0.4 0.4 0.4]')
yline(1,'k-','LineWidth',1)
xlabel('$\beta$','Interpreter','latex')
ylabel('$\theta_{i}/\theta_{max}$','Interpreter','latex')
ylim([0.5 2])
set(gca,'XTick',1:0.25:2)
set(gca,'YTick',0.5:0.25:2)
title(['Central Panel $\alpha_{m}=$' num2str(alpha(aind))],'Interpreter','latex')
grid on
fontsize(gcf, 12, 'points')

ax(8) = nexttile;
plot(beta,squeeze(DistLong(Corner,:,aind))./squeeze(DistReal(Corner,:,aind)),'LineStyle','-','Marker','^','MarkerFaceColor','r','color','r')
hold on
plot(beta,squeeze(DistShort(Corner,:,aind))./squeeze(DistReal(Corner,:,aind)),'LineStyle','-.','Marker','square','MarkerFaceColor','b','color','b')
plot(beta,squeeze(DistDiag(Corner,:,aind))./squeeze(DistReal(Corner,:,aind)),'LineStyle','--','Marker','o','MarkerFaceColor','[0.4 0.4 0.4]','color','[0.4 0.4 0.4]')
yline(1,'k-','LineWidth',1)
xlabel('$\beta$','Interpreter','latex')
ylim([0.5 2])
set(gca,'XTick',1:0.25:2)
set(gca,'YTick',0.5:0.25:2)
set(gca,'YTickLabels','')
legend('$\psi_{l}$','$\psi_{s}$','$\psi_{d}$','','Location','northwest','interpreter','latex','fontsize',12)
title(['Corner Panel $\alpha_{m}=$' num2str(alpha(aind))],'Interpreter','latex')
grid on
fontsize(gcf, 12, 'points')

annotation('textbox', [0.08, 0.03, 0.10, 0.04],'LineStyle',"none" ,'String', {'square',' slab'})
annotation('textbox', [0.42, 0.03, 0.44, 0.04],'LineStyle',"none" ,'String', {'rectang.','slab'})
annotation('textbox', [0.53, 0.03, 0.55, 0.04],'LineStyle',"none" ,'String', {'square', 'slab'})
annotation('textbox', [0.86, 0.03, 0.88, 0.04],'LineStyle',"none" ,'String', {'rectang.','slab'})

% saveas(gcf,'L15_AllApprox.png')