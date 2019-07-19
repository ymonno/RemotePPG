%**************************************************************************
% Plot a figure of BVPs. The figure includes BVP from iPPG and BVP from cPPG.
% xaxis: time, yaxis: amplitude of BVP
%**************************************************************************
function BVPsignalPlot(time,iPPGsignal,PPGsignal,timePPG,IBI,IBIPPG,TitleName,fntSize,lineWidth)

MarkerSize = 8;
figure
p1 = plot(time,iPPGsignal,'LineWidth',lineWidth);
hold on
p2 = plot(timePPG,PPGsignal,'LineWidth',lineWidth);

% plot used peaks
[idx] = FindPeaksUsedIBI(IBI(1,:),time);
[idxPPG] = FindPeaksUsedIBI(IBIPPG(1,:),timePPG);

p3 = plot(time(idx),iPPGsignal(idx),'ok','MarkerSize',MarkerSize);
p4 = plot(timePPG(idxPPG),PPGsignal(idxPPG),'.k','MarkerSize',MarkerSize);
legend([p1, p2, p3, p4],{['iPPG with ',TitleName, ' metric'],'cPPG','Used peaks for IBI estimation (iPPG)','Used peaks for IBI estimation (cPPG)'},'Location','southeast')
title(['Comparison of BVP between iPPG with ',TitleName, ' metric and cPPG'])
xlabel('time[s]');ylabel('amplitude')
set(gca,'Fontsize',fntSize)
xlim([time(1) time(end)])
ylim([-1 1])

end