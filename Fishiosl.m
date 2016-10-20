function [F,cF]=Fishiosl(k,th,xver)
% [F,cF]=FISHIOSL(k,th,xver)
%
% Calculates the entries in the Fisher matrix of Olhede & Simons (2013) for
% the Whittle-likelihood estimate of the SINGLE-FIELD Matern model, after
% wavenumber averaging. No blurring is possible here, since no data are
% involved and we work with analytical expressions for the derivatives,
% see LOGLIOSK. Zero-wavenumber excluded. No scaling asked or applied. 
%
% INPUT:
%
% k        Wavenumber(s), e.g. from KNUM2 [rad/m]
% th       The three-parameter vector argument [not scaled]:
%          th(1)=s2   The first Matern parameter [variance]
%          th(2)=nu   The second Matern parameter [differentiability]
%          th(3)=rho  The third Matern parameter [range]
% xver     Excessive verification
%
% OUTPUT:
%
% F        The full-form Fisher matrix, a symmetric 3x3 matrix
% cF       The 6-column Fisher matrix, listed in this order:
%          [1] Fs2s2   [2] Fnunu  [3] Frhorho
%          [4] Fs2nu   [5] Fs2rho [6] Fnurho
%
% SEE ALSO: 
%
% COVTHOSL, HESSIOSL, TRILOS, TRILOSI
% 
% EXAMPLE:
% 
% [~,th0,p,k,Hk]=simulosl([],[],1);
% F=Fishiosl(k,th0); H=Hessiosl(k,th0,p,Hk);
% % On average, these two should be close!
%
% Last modified by fjsimons-at-alum.mit.edu, 10/20/2016

% Early setup exactly as in HESSIOSL
defval('xver',0)

% Exclude the zero wavenumbers
k=k(~~k);

% The number of parameters to solve for
np=length(th);
% The number of unique entries in an np*np symmetric matrix
npp=np*(np+1)/2;
% The number of wavenumbers
lk=length(k(:));

% First compute the "means" parameters, one per parameter
mth=mAosl(k,th,xver);

% Initialize
cF=nan(npp,1);

if xver==0
  % Creative indexing - compare NCHOOSEK below
  [i,j]=ind2sub([np np],trilos(reshape(1:np^2,np,np)));
  % Do it all at once, don't save the wavenumber-dependent entities
  for ind=1:npp
    cF(ind)=mean(mth{j(ind)}.*mth{i(ind)});
  end
elseif xver==1
  % Initialize; some of them depend on the wave vectors, some don't
  cFk=cellnan([npp 1],[1 repmat(lk,1,5)],repmat(1,1,6));
  
  % We're doing it in this way to be able to compare it to HESSIOSL
  % Fthth, eq. (A60) in doi: 10.1093/gji/ggt056
  for j=1:3
    cFk{j}=mth{j}.^2;
  end
  
  % All further combinations Fththp, eq. (A60) in doi: 10.1093/gji/ggt056
  jcombo=nchoosek(1:np,2);
  for j=1:length(jcombo)
    cFk{np+j}=mth{jcombo(j,1)}.*mth{jcombo(j,2)};
  end
  
  % Take the expectation and put the elements in the right place
  for ind=1:npp
    cF(ind)=mean(cFk{ind});
  end
end

% The full Fisher matrix
F=trilosi(cF);
    
