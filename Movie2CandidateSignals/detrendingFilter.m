%From: M.P. Tarvainan, P.O. Ranta-aho, and P.A. Karjalainen "An advanced
%detrending method with application to HRV analysis", IEEE Trans Biomed
%Eng, 2002.
function z_stat=detrendingFilter(z,lambda)
if nargin<2
    lambda = 10;
end
T = length(z);
I = speye(T);
D2 = spdiags(ones(T-2,1)*[1 -2 1],[0:2],T-2,T);
z_stat = (I-inv(I+lambda^2*D2'*D2))*z;