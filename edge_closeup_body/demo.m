% script to demonstrate small-scale example from paper Rick Chartrand, 
% "Numerical differentiation of noisy, nonsmooth data," ISRN
% Applied Mathematics, Vol. 2011, Article ID 164564, 2011.


% noisyabsdata = absdata + 0.05 * randn( size( absdata ) ); results vary
% slightly with different random instances

load boundingBox

[u,s] = TVRegDiff( ColMu, 10, 1, [], 'small', 1e-6, 0.01, 0, 0 );
% u: scaled gradient 

A = cumsum(u)/100;
ColMu_fit = ColMu(1)+A(1:end-1);


[u,s] = TVRegDiff( ColSigma, 10, 1, [], 'small', 1e-6, 0.01, 0, 0 );
A = cumsum(u)/100;
ColSigma_fit = ColSigma(1)+A(1:end-1);

[u,s] = TVRegDiff( RowMu, 10, 1, [], 'small', 1e-6, 0.01, 0, 0 );
A = cumsum(u)/100;
RowMu_fit = RowMu(1)+A(1:end-1);

[u,s] = TVRegDiff( RowSigma, 10, 1, [], 'small', 1e-6, 0.01, 0, 0 );
A = cumsum(u)/100;
RowSigma_fit = RowSigma(1)+A(1:end-1);

%%
figure,

subplot(3,1,1)

plot(ColMu_fit,'r')
hold on 
plot(ColSigma_fit,'g')
plot(RowMu_fit,'b')

plot(RowSigma_fit,'k')

legend('colmu','colsigma','rowmu','rowsigma','Location','NorthEastOutside')
title('TV filtered')
subplot(3,1,2)
hold on 
plot(ColMu,'r')
plot(ColSigma,'g')
plot(RowMu,'b')
plot(RowSigma,'k')
legend('colmu','colsigma','rowmu','rowsigma','Location','NorthEastOutside')
title('original')


subplot(3,1,3)
hold on
plot(ColMu_fit - transpose(ColMu),'r')
plot(ColSigma_fit - transpose(ColSigma),'g')
plot(RowMu_fit - transpose(RowMu),'b')
plot(RowSigma_fit - transpose(RowSigma),'k')
legend('colmu','colsigma','rowmu','rowsigma','Location','NorthEastOutside')
title('difference')


save('boundingBox_fit','ColMu_fit','ColSigma_fit','RowMu_fit','RowSigma_fit')



