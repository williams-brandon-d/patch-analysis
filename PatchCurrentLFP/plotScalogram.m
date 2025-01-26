function fig = plotScalogram(x,y,z,plotTitle,maxValues,data_units,stimType)
    fontsize = loadFontSizes();

    fig = figure;
    surf(x,y,z)
    shading interp
    view(0,90)
    hcb = colorbar('Fontsize',fontsize.cbar,'Fontweight','bold');
%     title(hcb,sprintf('Power (%s^2)',data_units),'FontSize',fontsize.cbar,'FontWeight','bold') 
    ylim([-inf inf])
    clim([0 inf]);
%     clim([0 354.2338])
    colormap('hot')

    switch stimType
        case 'theta'
            xlim([-inf inf])
            xticks([-pi -pi/2 0 pi/2 pi]);
            xticklabels({'-\pi','-\pi/2','0','\pi/2','\pi'});
            xLabel = 'Stim Theta Phase (rad)';
        case 'pulse'
            xlim([0 500]); % ms
            xTicks = 0:100:500;
            xticks(xTicks);
            xticklabels(string(xTicks));
            xLabel = 'Time (ms)';
        case 'noise'   
            xLabel = 'Time (ms)';
    end

    ax = gca;
    ax.YAxis.FontSize = fontsize.tick;
    ax.XAxis.FontSize = fontsize.tick;
    xlabel(xLabel,'Fontsize',20)
    ylabel('Gamma Frequency (Hz)','Fontsize',20)
    ax.YAxis.FontWeight = 'bold';
    ax.XAxis.FontWeight = 'bold';

    if nargin > 3
%         title(plotTitle,'FontSize',fontsize.title,'Interpreter','none')
    end

    if nargin > 4
        hold on
%         plot3(maxValues(1),maxValues(2),maxValues(3),'xb')
        hold off
    end

end
