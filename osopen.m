function [fids,fmts,fmti]=osopen(np)
% [fids,fmts,fmti]=OSOPEN(np,npp)
%
% Opens ALL FOUR diagnostic files for writing by the suite of
% programs following Simons & Olhede (2013). Data files are, like,
% 'mleosl_thzro_16-Jun-2015-64-2', 'mleosl_thini_16-Jun-2015-64-2',
% 'mleosl_thhat_16-Jun-2015-64-2', 'mleosl_diagn_16-Jun-2015-64-2', etc, 
%  and returns identifiers and format strings. 
%
% INPUT:
%
% np     The number of parameters to solve for (e.g. 3, 5 or 6)
%
% OUTPUT:
%
% fids   A vector of file identifiers
% fmts   A cell of formatting strings
% fmti   A cell of formatting strings, reverse order of fmts{3}
%
% SEE ALSO:
%
% OSLOAD, OSRDIAG (with which it needs to match!)
%
% Last modified by fjsimons-at-alum.mit.edu, 08/18/2017

% Who called? Work this into the filenames
[~,n]=star69;

% The number of unique entries in an np*np symmetric matrix
npp=np*(np+1)/2;

% Ouput files, in parallel might be a jumble
% The thruth and the theoretical covariances
fids(1)=fopen(sprintf('%s_thzro_%s',n,date),'w');
% The estimates
fids(2)=fopen(sprintf('%s_thhat_%s',n,date),'a+');
% The initial guesses
fids(3)=fopen(sprintf('%s_thini_%s',n,date),'a+');
% The collected optimization diagnostics, replicated some above
fids(4)=fopen(sprintf('%s_diagn_%s',n,date),'a+');

% Output formatting for the estimation parameters
if np==3
  %                           s2    nu    rho
  fmts{1}=[                   '%9.3e %6.3f %6.0f\n'];
elseif np==5
  %                D    f2    s2    nu    rho
  fmts{1}=[      '%12.6e %6.3f %9.3e %6.3f %6.0f\n'];
elseif np==6
  %         D    f2      r    s2    nu    rho
  fmts{1}=['%12.6e %6.3f %6.3f %9.3e %6.3f %6.0f\n'];
end

% Output formatting for the simulation parameters
if np>=5
  %     DEL     g  z2  dydx  NyNx  blurs kiso quart
  fmts{2}='%i %i %5.2f %i %i %i %i %i %i %f %i\n';
else
  %     dydx  NyNx  blurs kiso quart
  fmts{2}='%i %i %i %i %i %f %i\n';
end

% For the time, exit flag, iterations 
fmti{6}='%3i %3i %3i\n';
% For the likelihood, first-order optimality, and moments
fmti{5}='%15.8e %15.8e %15.8e %15.8e %15.8e\n';
% For the scale
fmti{4}=[repmat('%15.0e ',1,np) '\n'];
% For the score, the gradient of the misfit function
fmti{3}=[repmat('%15.8e ',1,np) '\n']; 
% For the Hessian of the misfit function, with npp unique elements 
fmti{2}=repmat([repmat('%15.12f ',1,npp/3) '\n'],1,3);
% For the unscaled Hessian-derived covariance matrix, or 
% for the unscaled theoretical covariance matrix
fmti{1}=repmat([repmat('%19.12e ',1,npp/3) '\n'],1,3);

% Lumps some of the formats together
fmts{3}=[fmti{6} fmti{5} fmti{4} fmti{3} fmti{2} fmti{1}];
