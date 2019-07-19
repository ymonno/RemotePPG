function [f] = successRatioGraph(nameofMethod,ADofIBIMatrics,x_vectorIBI,ADofRMSSDmatrics,x_VectorRMSSD)

f1 = figure;
for i = 1: length(ADofIBIMatrics)
    [successRatioVector] = successRatio(x_vectorIBI,ADofIBIMatrics{1,i});
    plot(x_vectorIBI,successRatioVector,'DisplayName',nameofMethod{1,i},'LineWidth',3)
    hold on
end
title('Absolute Difference of IBI')
xlabel('Thresthold')
ylabel('Seccess ratio')
set(gca,'FontSize',15)
legend(nameofMethod{:})

if nargin ==5
    f2 = figure;

    for i = 1: length(ADofRMSSDmatrics)
        [successRatioVector] = successRatio(x_VectorRMSSD,ADofRMSSDmatrics{1,i});
        plot(x_vectorIBI,successRatioVector,'DisplayName',nameofMethod{1,i})
        hold on
    end
    title('Absolute Difference of RMSSD')
    xlabel('Thresthold')
    ylabel('Seccess ratio')
    set(gca,'FontSize',15)
    f = {f1,f2};
else
    f = f1;
end

end
