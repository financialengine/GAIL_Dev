function [tmu,out_param]=meanMC_g(varargin)
% MEANMC_G Monte Carlo method to estimate the mean of a random variable
% to within a specified generalized error tolerance 
% tolfun = max(abstol,reltol|mu|) with guaranteed confidence level 1-alpha.
%
%   tmu = MEANMC_G(Yrand) estimates the mean of a random variable Y to
%   within a specified generalized error tolerance tolfun =
%   max(abstol,reltol|mu|) with guaranteed confidence level 99%. Input
%   Yrand is a function handle that accepts a positive integer input n and
%   returns an n x 1 vector of IID instances of the random variable Y.
%
%   tmu = MEANMC_G(Yrand,abstol,reltol,alpha,fudge,nSig,n1,tbudget,nbudget)
%    estimates the mean of a random variable Y to within a specified
%    generalized error tolerance tolfun with guaranteed confidence
%   level 1-alpha using all ordered parsing inputs abstol, reltol, alpha,
%   fudge, nSig, n1, tbudget, nbudget.
%
%   tmu = MEANMC_G(Yrand,'abstol',abstol,'reltol',reltol,'alpha',alpha,
%   'fudge',fudge,'nSig',nSig,'n1',n1,'tbudget',tbudget,'nbudget', nbudget)
%   estimates the mean of a random variable Y to within a specified
%   generalized error tolerance tolfun with guaranteed confidence level
%   1-alpha. All the field-value pairs are optional and can be supplied in
%   different order, if a field is not supplied, the default value is used.
%
%   [tmu, out_param] = MEANMC_G(Yrand,in_param) estimates the mean of a
%   random variable Y to within a specified generalized error tolerance
%   tolfun with the given parameters in_param and produce the estimated
%   mean tmu and output parameters out_param. If a field is not specified,
%   the default value is used.
%
%   Input Arguments
%
%    Yrand --- the function for generating n IID instances of a random
%    variable Y whose mean we want to estimate. Y is often defined as a
%    function of some random variable X with a simple distribution. The
%    input of Yrand should be the number of random variables n, the output
%    of Yrand should be n function values. For example, if Y = X.^2 where X
%    is a standard uniform random variable, then one may define Yrand =
%    @(n) rand(n,1).^2.
%
%    in_param.abstol --- the absolute error tolerance, default value is 1e-2.
%
%    in_param.reltol --- the relative error tolerance, default value is 1e-1.
%
%    in_param.alpha --- the uncertainty, default value is 1%.
%
%    in_param.fudge --- standard deviation inflation factor, default value is
%    1.2.
%
%    in_param.nSig --- initial sample size for estimating the sample
%    variance, the default value is 1e3.
%
%    in_param.n1 --- initial sample size for estimating the sample
%    mean, the default value is 1e4.
%
%    in_param.tbudget --- the time budget to do the two-stage estimation,
%    the default value is 100 seconds.
%
%    in_param.nbudget --- the sample budget to do the two-stage estimation,
%    the default value is 1e9.
%
%   Output Arguments
%
%    tmu--- the estimated mean of Y.
%
%    out_param.tau --- the iteration step.
%
%    out_param.n --- sample used in each iteration.
%
%    out_param.nmax --- the maximum sample budget to estimate mu, it comes
%    from both the sample budget and the time budget and sample has been
%    used.
%
%    out_param.ntot --- total sample used.
%
%    out_param.hmu --- estimated mean in each iteration
%
%    out_param.tol --- the tolerance for each iteration
%
%    out_param.var --- the sample variance.
%
%    out_param.exit --- the state of program when exiting.
%                     0   Success.
%                     1   Not enough samples to estimate the mean.
%                     2   Initial try out time costs more than 10% of time budget.
%                     3   The estimated time for estimating variance is bigger
%                         than half of the time budget.
%
%    out_param.kurtmax --- the upper bound on modified kurtosis.
%
%    out_param.time --- the time elapsed
%
%    out_param.checked --- parameter checking status
%                        1  checked by meanMC_g
%
% Guarantee
% This algorithm attempts to calculate the mean of a random variable to a
% prescribed error tolerance with guaranteed confidence level 1-alpha. If
% the algorithm terminated without showing any warning messages and provide
% an answer tmu, then the follow inequality would be satisfied:
% 
% Pr(|mu-tmu| <= max(abstol,reltol|mu|)) >= 1-alpha
%
% where abstol is the absolute error tolerance and reltol is the relative
% error tolerance, if the true mean mu is rather small as well as the
% reltol, then the abstol would be satisfied, and vice versa. 
%
% The cost of the algorithm is also bounded above by N_up, which is defined
% in terms of abstol, reltol, nSig, n1, fudge, kmax, beta. And the
% following inequality holds:
% 
% Pr (N_tot <= N_up) >= 1-beta
%
% Please refer to our paper for detailed arguments and proofs.
%
% Examples
%
% Example 1:
% If no parameters are parsed, help text will show up as follows:
% >> meanMC_g
% ***Monte Carlo method to estimate***
%
%
% Example 2:
% Calculate the mean of x^2 when x is uniformly distributed in
% [0 1], with the relative error tolerance = 1e-3 and uncertainty 5%.
%
% >> in_param.reltol=0; in_param.abstol = 1e-3;
% >> in_param.alpha = 0.05; Yrand=@(n) rand(n,1).^2;
% >> tmu=meanMC_g(Yrand,in_param)
% tmu = 0.33***
%
%
% Example 3:
% Calculate the mean of exp(x) when x is uniformly distributed in
% [0 1], with the absolute error tolerance 1e-3.
%
% >> tmu=meanMC_g(@(n)exp(rand(n,1)),1e-3,0)
% tmu = 1.71***
%
%
% Example 4:
% Calculate the mean of sin(x) when x is uniformly distributed in
% [0 1], with the relative error tolerance 1e-2 and uncertainty 0.05.
%
% >> tmu=meanMC_g(@(n)cos(rand(n,1)),'reltol',1e-2,'abstol',0,'alpha',0.05)
% tmu = 0.84***
%
%
%   See also FUNAPPX_G, INTEGRAL_G, CUBMC_G
%
%  References
%
%   [1]  F. J. Hickernell, L. Jiang, Y. Liu, and A. B. Owen, Guaranteed
%   conservative fixed width confidence intervals via Monte Carlo sampling,
%   Monte Carlo and Quasi-Monte Carlo Methods 2012 (J. Dick, F. Y. Kuo, G. W.
%   Peters, and I. H. Sloan, eds.), Springer-Verlag, Berlin, 2014, to appear,
%   arXiv:1208.4318 [math.ST]
%
%   [2] Sou-Cheng T. Choi, Yuhan Ding, Fred J. Hickernell, Lan Jiang, and
%   Yizhi Zhang, "GAIL: Guaranteed Automatic Integration Library (Version
%   1.3.0)" [MATLAB Software], 2014. Available from
%   http://code.google.com/p/gail/
%
%   If you find GAIL helpful in your work, please support us by citing the
%   above paper and software.

tstart = tic; %start the clock
[Yrand, out_param] = meanMC_g_param(varargin{:});

n1 = 2;
Yrand(n1); %let it run once to load all the data. warm up the machine.
nsofar = n1;

ntry = 20;% try several samples to get the time
tic;
Yrand(ntry);
ttry=toc;
tpern = ttry/ntry; % calculate time per sample

nsofar = nsofar+ntry; % update n so far

if tpern<1e-6;%each sample use rather little time
    booster = 8;
    tic;Yrand(ntry*booster);ttry2 = toc;
    ntry = ntry*[1 booster];
    ttry = [ttry ttry2];% take eight times more samples to try
    [tmu,out_param] =  meanmctolfun(Yrand,out_param,ntry,ttry,nsofar,tstart);
elseif tpern>=1e-3 %each sample use a lot of time
    booster = 2;
    tic;Yrand(ntry*booster);ttry2 = toc;
    ntry = ntry*[1 booster];
    ttry = [ttry ttry2];% take two times more samples to try
    [tmu,out_param] =  meanmctolfun(Yrand,out_param,ntry,ttry,nsofar,tstart);
else %each sample uses moderate time
    booster = 5;
    tic;Yrand(ntry*booster);ttry2 = toc;
    ntry = ntry*[1 booster];
    ttry = [ttry ttry2];% take five times more samples to try
    [tmu,out_param] =  meanmctolfun(Yrand,out_param,ntry,ttry,nsofar,tstart);
end
end

function [tmu,out_param] =  meanmctolfun(Yrand,out_param,ntry,ttry,nsofar,tstart)
tic;
Yval = Yrand(out_param.nSig);% get samples to estimate variance 
t_sig = toc;%get the time for calculating nSig function values.
nsofar = nsofar+out_param.nSig;% update the samples that have been used
out_param.nmax = gail.estsamplebudget(out_param.tbudget,...
    out_param.nbudget,[ntry out_param.nSig 0],nsofar,tstart,[ttry t_sig 0]);
%update the nmax could afford until now
out_param.var = var(Yval);% calculate the sample variance--stage 1
sig0 = sqrt(out_param.var);% standard deviation
sig0up = out_param.fudge.*sig0;% upper bound on the standard deviation
alpha_sig = out_param.alpha/2;% the uncertainty for variance estimation
alphai = (out_param.alpha-alpha_sig)/(2*(1-alpha_sig));%uncertainty to do iteration
out_param.kurtmax = (out_param.nSig-3)/(out_param.nSig-1) ...
    + ((alpha_sig*out_param.nSig)/(1-alpha_sig))...
    *(1-1/out_param.fudge^2)^2;%the upper bound on the modified kurtosis
eps1 = ncbinv(out_param.n1,alphai,out_param.kurtmax);%tolerance for initial estimation
out_param.tol(1) = sig0up*eps1;%the width of initial confidence interval for the mean
i=1;
npcmax = 1e6;%constant to do iteration and mean calculation
out_param.n(i) = out_param.n1;% initial sample size to do iteration
while true
    out_param.tau = i;%step of the iteration
    if out_param.n(i) > out_param.nmax;
        % if the sample size used for initial estimation is
        % larger than nmax, print warning message and use nmax
        out_param.exit=1; %pass a flag
        meanMC_g_err(out_param); % print warning message
        out_param.n(i) = out_param.nmax;% update n
        tmu = gail.evalmean(Yrand,out_param.n(i),npcmax);%evaluate the mean
        nsofar = nsofar+out_param.n(i);%total sample used
        break;
    end
    out_param.hmu(i) = gail.evalmean(Yrand,out_param.n(i),npcmax);%evaluate mean
    nsofar = nsofar+out_param.n(i);
    out_param.nmax = out_param.nmax-out_param.n(i);%update n so far and nmax
    errtype = 'max';
    % error type, see the function 'tolfun' at +gail directory for more info
    theta  = 0;% relative error case
    deltaplus = (gail.tolfun(out_param.abstol,out_param.reltol,...
        theta,out_param.hmu(i) - out_param.tol(i),errtype)...
        +gail.tolfun(out_param.abstol,out_param.reltol,...
        theta,out_param.hmu(i) + out_param.tol(i),errtype))/2;
    % a combination of tolfun, which used to decide stopping time
    if deltaplus >= out_param.tol(i) % stopping criterion
        deltaminus= (gail.tolfun(out_param.abstol,out_param.reltol,...
            theta,out_param.hmu(i) - out_param.tol(i),errtype)...
            -gail.tolfun(out_param.abstol,out_param.reltol,...
            theta,out_param.hmu(i) + out_param.tol(i),errtype))/2;
        % the other combination of tolfun, which adjust the hmu a bit
        tmu = out_param.hmu(i)+deltaminus;
        break;
    else
        i=i+1;
        deltat=0.7;
        deltah=0.5;
        delta=0.3;% constant to decide the next tolerance
        out_param.tol(i) = max(min(deltaplus*deltat, ...
            deltah*out_param.tol(i-1)),delta*out_param.tol(i-1));
        %update the next tolerance
        toloversig = out_param.tol(i)/sig0up;%next tolerance over sigma
        alphai = (out_param.alpha-alpha_sig)/(1-alpha_sig)*2.^(-i);
        %update the next uncertainty
        out_param.n(i) = nchebe(toloversig,alphai,out_param.kurtmax);
        %get the next sample size needed
    end
end
out_param.ntot = nsofar;%total sample size used
out_param.time=toc(tstart); %elapsed time
end

function ncb = nchebe(toloversig,alpha,kmax)
%this function uses Chebyshev and Berry-Eseen Inequality to calculate the
%sample size needed
ncheb = ceil(1/(toloversig^2*alpha));%sample size by Cheybshev's Inequality
A=18.1139;
A1=0.3328;
A2=0.429; % three constants in Berry-Esseen inequality
M3upper = kmax^(3/4);%the upper bound on the third moment by Jensen's inequality
BEfun2=@(logsqrtn)gail.stdnormcdf(-exp(logsqrtn).*toloversig)...
    +exp(-logsqrtn).*min(A1*(M3upper+A2), ...
    A*M3upper./(1+(exp(logsqrtn).*toloversig).^3))- ...
    alpha/2; % Berry-Eseen function, whose solution is the sample size needed
logsqrtnCLT=log(gail.stdnorminv(1-alpha/2)/toloversig);%sample size by CLT
nbe=ceil(exp(2*fzero(BEfun2,logsqrtnCLT)));%calculate Berry-Eseen n by fzero function
ncb = min(ncheb,nbe);%take the min of two sample sizes.
end

function eps = ncbinv(n1,alpha1,kmax)
%This function calculate error tolerance when given Chebyshev and
%Berry-Esseen inequality and sample size n.
NCheb_inv = 1/sqrt(n1*alpha1);
% use Chebyshev inequality
A=18.1139;
A1=0.3328;
A2=0.429; % three constants in Berry-Esseen inequality
M3upper=kmax^(3/4);%using Jensen's inequality to
% bound the third moment
BEfun=@(logsqrtb)gail.stdnormcdf(n1.*logsqrtb)...
    +min(A1*(M3upper+A2), ...
    A*M3upper./(1+(sqrt(n1).*logsqrtb).^3))/sqrt(n1)...
    - alpha1/2;
% Berry-Esseen inequality
logsqrtb_clt=log(sqrt(gail.stdnorminv(1-alpha1/2)/sqrt(n1)));%CLT to get tolerance
NBE_inv = exp(2*fzero(BEfun,logsqrtb_clt));%use fzero to get Berry-Eseen tolerance
eps = min(NCheb_inv,NBE_inv);%take the min of Chebyshev and Berry Eseen tolerance
end

function  [Yrand,out_param] = meanMC_g_param(varargin)

default.abstol  = 1e-2;% default absolute error tolerance
default.reltol = 1e-1;% default relative error tolerance
default.nSig = 1e4;% default initial sample size nSig for variance estimation
default.n1 = 1e4; % default initial sample size n1 for mean estimation
default.alpha = 0.01;% default uncertainty
default.fudge = 1.2;% default fudge factor
default.tbudget = 100;% default time budget
default.nbudget = 1e9; % default sample budget

if isempty(varargin)
    help meanMC_g
    warning('MATLAB:meanMC_g:yrandnotgiven',...
        'Yrand must be specified. Now GAIL is using Yrand = rand(n,1).^2.')
    Yrand = @(n) rand(n,1).^2;
    %give the error message
else
    Yrand = varargin{1};
    if max(size(Yrand(5)))~=5 || min(size(Yrand(5)))~=1
        % if the input is not a length n Vector, print warning message
        warning('MATLAB:meanMC_g:yrandnotlengthN',...
            ['Yrand should be a random variable vector of length n, '...
            'but not an integrand or a matrix'])
        Yrand = @(n) rand(n,1).^2;
    end
end

validvarargin=numel(varargin)>1;
if validvarargin
    in2=varargin{2};
    validvarargin=(isnumeric(in2) || isstruct(in2) ...
        || ischar(in2));
end

if ~validvarargin
    %if only have one input which is Yrand, use all the default parameters
    
    out_param.abstol = default.abstol;% default absolute error tolerance
    out_param.reltol = default.reltol; % default relative error tolerance
    out_param.alpha = default.alpha;
    out_param.fudge = default.fudge;
    out_param.nSig = default.nSig;
    out_param.n1 = default.n1;
    out_param.tbudget = default.tbudget;
    out_param.nbudget = default.nbudget;
else
    p = inputParser;
    addRequired(p,'Yrand',@gail.isfcn);
    if isnumeric(in2)%if there are multiple inputs with
        %only numeric, they should be put in order.        
        addOptional(p,'abstol',default.abstol,@isnumeric);
        addOptional(p,'reltol',default.reltol,@isnumeric);
        addOptional(p,'alpha',default.alpha,@isnumeric);
        addOptional(p,'fudge',default.fudge,@isnumeric);
        addOptional(p,'nSig',default.nSig,@isnumeric);
        addOptional(p,'n1',default.n1,@isnumeric);
        addOptional(p,'tbudget',default.tbudget,@isnumeric);
        addOptional(p,'nbudget',default.nbudget,@isnumeric);
    else
        if isstruct(in2) %parse input structure
            p.StructExpand = true;
            p.KeepUnmatched = true;
        end
        addParamValue(p,'abstol',default.abstol,@isnumeric);
        addParamValue(p,'reltol',default.reltol,@isnumeric);
        addParamValue(p,'alpha',default.alpha,@isnumeric);
        addParamValue(p,'fudge',default.fudge,@isnumeric);
        addParamValue(p,'nSig',default.nSig,@isnumeric);
        addParamValue(p,'n1',default.n1,@isnumeric);
        addParamValue(p,'tbudget',default.tbudget,@isnumeric);
        addParamValue(p,'nbudget',default.nbudget,@isnumeric);
    end
    parse(p,Yrand,varargin{2:end})
    out_param = p.Results;
end

if (out_param.abstol < 0)
    %absolute error tolerance should be positive
    warning('MATLAB:meanMC_g:abstolneg',...
        ['Absolute error tolerance should be greater than 0, ' ...
        'use the absolute value of the error tolerance'])
    out_param.abstol = abs(out_param.abstol);
end
if (out_param.reltol < 0 || out_param.reltol > 1)
    % relative error tolerance should be in (0,1)
    warning('MATLAB:meanMC_g:reltolneg',...
        ['Relative error tolerance should be between 0 and 1, ' ...
        'use the default value of the error tolerance'])
    out_param.abstol = abs(out_param.abstol);
end
if (out_param.alpha <= 0 ||out_param.alpha >= 1) 
    %uncertainty should be in (0,1)
    warning('MATLAB:meanMC_g:alphanotin01',...
        ['the uncertainty should be between 0 and 1, '...
        'use the default value.'])
    out_param.alpha = default.alpha;
end
if (out_param.fudge<= 1) 
    %standard deviation factor should be bigger than 1
    warning('MATLAB:meanMC_g:fudgelessthan1',...
        ['the fudge factor should be larger than 1, '...
        'use the default value.'])
    out_param.fudge = default.fudge;
end
if (~gail.isposint(out_param.nSig)) 
    %initial sample size should be a positive integer
    warning('MATLAB:meanMC_g:nsignotposint',...
        ['the number nSig should a positive integer, '...
        'take the absolute value and ceil.'])
    out_param.nSig = ceil(abs(out_param.nSig));
end
if (~gail.isposint(out_param.n1)) 
    %initial sample size should be a posotive integer
    warning('MATLAB:meanMC_g:n1notposint',...
        ['the number n1 should a positive integer, '...
        'take the absolute value and ceil.'])
    out_param.n1 = ceil(abs(out_param.n1));
end
if (out_param.tbudget <= 0) 
    %time budget should be positive
    warning('MATLAB:meanMC_g:timebudgetlneg',...
        ['Time budget should be bigger than 0, '...
        'use the absolute value of time budget'])
    out_param.tbudget = abs(out_param.tbudget);
end
if (~gail.isposint(out_param.nbudget)) % sample budget should be a positive integer
    warning('MATLAB:meanMC_g:nbudgetnotposint',...
        ['the number of sample budget should be a positive integer,'...
        'take the absolute value and ceil.'])
    out_param.nbudget = ceil(abs(out_param.nbudget));
end
out_param.checked = 1; % pass the signal indicate the parameters have been checked
end

function out_param = meanMC_g_err(out_param)
% Handles errors in meanMC_g and meanMC_g_param to give an exit with
%  information.
%            out_param.exit = 0   success
%                             1   too many samples required
%                             2   too much try out time
%                             3   too much time required to estimate
%                                 variance
if ~isfield(out_param,'exit'); return; end
if out_param.exit==0; return; end
switch out_param.exit
    case 1 % not enough samples to estimate the mean.
        nexceed = out_param.n(out_param.tau);
        warning('MATLAB:meanMC_g:maxreached',...
            ['tried to evaluate at ' int2str(nexceed) ...
            ' samples, which is more than the allowed maximum of '...
            num2str(out_param.nmax) ' samples. Just use the maximum sample budget.']);
        return
%     case 2 % initial try out time costs more than 10% of time budget.
%         warning('MATLAB:meanMC_g:initialtryoutbudgetreached',...
%             ['initial try costs more than 10 percent '...
%             'of time budget, stop try and return an answer '...
%             'without guarantee.']);
%         return
%     case 3
%         % the estimated time for estimating variance is bigger than half of
%         % time budget.
%         warning('MATLAB:meanMC_g:timebudgetreached',...
%             ['the estimated time using nSig samples '...
%             'is bigger than half of the time budget, '...
%             'could not afford estimating variance, '...
%             'use all the time left to estimate the mean.']);
%       return
end
end
