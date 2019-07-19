%**************************************************************************
% Plot the graph of IBIs from iPPG and cPPG.
%**************************************************************************
function IBIplot(IBI,IBIPPG,TitleName,fntSize,lineWidth)

MarkerSize = 8;
% interpolation with PCHIP
IBI_interp = interp1(IBI(1,:),IBI(2,:),IBI(1,1):0.01:IBI(1,end),'PCHIP');
IBIPPG_interp = interp1(IBIPPG(1,:),IBIPPG(2,:),IBIPPG(1,1):0.01:IBIPPG(1,end),'PCHIP');

figure
p1 = plot(IBI(1,1):0.01:IBI(1,end),IBI_interp,'LineWidth',lineWidth);
hold on
p2 = plot(IBIPPG(1,1):0.01:IBIPPG(1,end),IBIPPG_interp,'LineWidth',lineWidth);
p3 = plot(IBI(1,:),IBI(2,:),'ok','MarkerSize',MarkerSize);
plot(IBIPPG(1,:),IBIPPG(2,:),'ok','MarkerSize',MarkerSize);
legend([p1, p2, p3],{['IBI of iPPG with',TitleName],'IBI of cPPG','Detected peaks'},'Location','southeast')
title(['Comparison of IBI between iPPG with ',TitleName, ' metric and cPPG'])
xlabel('time[s]');ylabel('IBI[s]')
set(gca,'Fontsize',fntSize)

end