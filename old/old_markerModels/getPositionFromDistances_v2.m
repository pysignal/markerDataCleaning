function [pos] = getPositionFromDistances_v2(knownPositions,knownDistances,weights,initGuess)
%v2 allos for many pos to be estimated simultaneously
%INPUT:
%knownPositions: N x D  matrix, D being dimension of space
%knownDistances: N x M matrix containing distances from unknown point to
%weights: N x M vector to weigh the distances in the regression (larger
%weights means the distance is better preserved)
%OUTPUT:
%pos: M x D matrix containing D-dimensional positions for M points

[N,dim]=size(knownPositions);
[N1,M]=size(knownDistances);
if nargin<3 || isempty(weights)
    weights=ones(size(knownDistances));
elseif size(weights,1)~=N
    error('Weight dimensions mismatch')
end
weights=weights/sum(weights); %Normalizing to 1    

if nargin<4 || isempty(initGuess)
    initGuess=mean(knownPositions);
end

if size(knownDistances,1)~=N
    error('Provided distances dimension mismatch. Check that the number of distances is the same as the numer of known positions')
end

%Option 1:
%Do a least-squares regression:
opts = optimoptions('fminunc','Algorithm','trust-region','SpecifyObjectiveGradient',true,'Display','off');
pos=fminunc(@(x) distanceDistanceAll(reshape(x,M,dim),knownPositions,knownDistances,weights),initGuess(:),opts);

end

function [f,g]=distanceDistance(x,kP,kD,w)
    xx=bsxfun(@minus,x,kP); %Relative positions
    normXX=sqrt(sum(xx.^2,2));
    f=norm(w.*(normXX-kD))^2;
    gg1=2*w.^2.*(normXX-kD);
    gg2=bsxfun(@rdivide,xx,normXX);
    gg=bsxfun(@times,gg1,gg2);
    g=sum(gg,1);
end

function [f,g]=distanceDistanceAll(x,kP,kD,w)
    [M,dim]=size(x);
    [N,dim]=size(kP);
    xx=bsxfun(@minus,x,reshape(kP',1,size(kP,2),size(kP,1))); %M x dim x N
    normXX=sqrt(sum(xx.^2,2)); %M x 1 x N
    f=sum(sum((w'.*(reshape(normXX,M,N)-kD')).^2)); %scalar
    gg1=2*w'.^2.*(reshape(normXX,M,N)-kD'); %M x N
    gg2=bsxfun(@rdivide,xx,normXX); %M x dim x N
    gg=bsxfun(@times,reshape(gg1,size(gg2,1),1,size(gg2,3)),gg2); %M x dim x N
    g=sum(gg,3); %M x dim
    g=g(:);
end

%% A little script to test distanceDistanceAll:
% X1=randn(10,3);
% D=computeDistanceMatrix(X1);
% kP=X1(1:7,:);
% kD=D(1:7,8:10);
% w=ones(size(kD));
% 
% %% Eval:
% xA=randn(3,3);
% [fA,gA]=distanceDistanceAll(xA,kP,kD,w);
% xB=bsxfun(@plus,xA,[0, 0, 1e-5]);
% [fB,gB]=distanceDistanceAll(xB,kP,kD,w);
% xC=bsxfun(@plus,xA,[0, 1e-5, 0]);
% [fC,gC]=distanceDistanceAll(xC,kP,kD,w);
% xD=bsxfun(@plus,xA,[1e-5, 0, 0]);
% [fD,gD]=distanceDistanceAll(xD,kP,kD,w);
% sum(reshape(gA,3,3),1)
% 
% [(fD-fA) (fC-fA) (fB-fA)]/1e-5
% 
% [fA,~]=distanceDistanceAll(X1(8:10,:),kP,kD,w)
