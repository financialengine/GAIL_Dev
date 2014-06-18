%% funappx_t
% |1-D guaranteed function recovery on closed interval [a,b].|
%% Syntax
% pp = *funappx_t*(f)
%
% pp = *funappx_t*(f,a,b,abstol,nlo,nhi,nmax)
%
% pp = *funappx_t*(f,'a',a,'b',b,'abstol',abstol,'nlo',nlo,'nhi',nhi,'nmax',nmax)
%
% pp = *funappx_t*(f,in_param)
%
% [pp, out_param] = *funappx_t*(f,...)
%% Description
% 
% pp = *funappx_t*(f) |recovers function|  f  |on the default interval
%  [0,1] by a piecewise polynomial structure pp to within the guaranteed
%  absolute error tolerance of 1e-6. Default initial number of points is
%  100 and default cost budget is 1e7.  Input| f |is a function handle. The
%  statement| y=f(x) |should accept a vector argument x and return a
%  vector y of function values that is the same size as x. Output pp
%   may be evaluated via| ppval.
%
% pp = *funappx_t*(f,a,b,abstol,nlo,nhi,nmax) |for a given function|  f
%  |and the ordered input parameters that define the finite interval [a,b],
%  a guaranteed absolute error tolerance bstol, a lower bound of initial
%  number of points nlo, an upper bound of initial number of points nhi, and
%  cost budget nmax.|
%
% pp = *funappx_t*(f,'a',a,'b',b,'abstol',abstol,'nlo',nlo,'nhi',nhi,'nmax',nmax)
%  |recovers function|  f  |on the finite interval [a, b], given a guaranteed
%  absolute error tolerance abstol, a lower bound of initial number of
%  points nlo, an upper bound of initial number of points nhi, and a cost
%  budget nmax. All six field-value pairs are optional and can be supplied
%  in different order.|
%
% pp = *funappx_t*(f,in_param) |recovers function|  f  |on the finite
%  interval [in_param.a, in_param.b], given a guaranteed absolute error
%  tolerance in_param.abstol, a lower bound of initial number of points
%  in_param.nlo, an upper bound of initial number of points in_param.nhi,
%  and a cost budget in_param.nmax. If a field is not specified, the
%  default value is used.|
%
% [pp, out_param] = *funappx_t*(f,...) |returns a piecewise polynomial
%   structure pp and an output structure out_param.|
%
% *Input Arguments*
% 
% * f --- |function handle|
%
% * in_param.a --- |left end point of interval, default value is 0|
%
% * in_param.b --- |right end point of interval, default value is 1|
%
% * in_param.abstol --- |guaranteed absolute error tolerance, default value
%  is 1e-6|
%
% * in_param.nlo --- |lower bound of initial number of points we used,
%  default value is 10|
%
% * in_param.nhi --- |upper bound of initial number of points we used,
%  default value is 100|
%
% * in_param.nmax --- |cost budget, default value is 1e7|
%
% *Output Arguments*
%
% * pp.form --- |pp means piecewise polynomials|
%
% * pp.breaks --- |show the location of interpolation points|
%
% * pp.coefs --- |coefficients for piecewise linear polynomials|
%
% * pp.pieces --- |number of piecewise linear polynomials|
%
% * pp.order --- |be 2 as we use piecewise linear polynomials|
%
% * pp.dim --- |be 1 as we do univariate approximation|
%
% * pp.orient --- |always be 'first'|
%
% * out_param.nmax --- |cost budget|
% 
% * out_param.exceedbudget  --- |it is 0 if the number of points used in the 
%   construction of fappx is less than cost budget, 1 otherwise.|
% 
% * out_param.ninit --- |initial number of points we used|
%
% * out_param.npoints --- |number of points we need to reach the guaranteed
% absolute error|
% 
% * out_param.errorbound --- |an upper bound of the absolute error|
% 
% * out_param.nstar --- |final value of the parameter defining the cone of
% functions for which this algorithm is guaranteed; nstar = ninit-2
% initially and is increased as necessary|
%
% * out_param.a --- |left end point of interval|
%
% * out_param.b --- |right end point of interval|
%
% * out_param.abstol --- |guaranteed absolute error|
% 
% * out_param.nlo --- |lower bound of initial number of points we used|
%
% * out_param.nhi --- |higher bound of initial number of points we used|
%
%% Guarantee
%    
% |If the function to be approximated,|  $f$  |satisfies the cone condition|
%
% $$\|f''\|_\infty \le \frac { 2\mathrm{nstar} }{b-a } \left\|f'-\frac{f(b)-f(a)}{b-a}\right\|_\infty,$$
% 
% |then the|  $pp$  |output by this algorithm is guaranteed to
% satisfy|
%
% $$\| f-ppval(pp,)\|_{\infty} \le \mathrm{abstol},$$
%
% |provided the flag| $\mathrm{exceedbudget} = 0.$
%
% |And the upper bound of the cost is|
%
% $$\sqrt{ \frac{\mathrm{nstar}(b-a)^2 
% \|f''\|_\infty}{2 \times \mathrm{abstol}}} + 2 \times \mathrm{nstar}+4.$$
%
%
%% Examples
% *Example 1*

f = @(x) x.^2; [pp, out_param] = funappx_t(f)

% Approximate function x^2 with default input parameter to make the error
% less than 1e-6.
%%
% *Example 2*

[pp, out_param] = funappx_t(@(x) x.^2,0,100,1e-7,10,1000,1e8)

% Approximate function x^2 on [0,100] with error tolerence 1e-7, cost
% budget 10000000, lower bound of initial number of points 10 and upper
% bound of initial number of points 100

%%
% *Example 3*

clear in_param; in_param.a = -20; in_param.b = 20; in_param.nlo = 10;
in_param.nhi = 100; in_param.nmax = 1e8; in_param.abstol = 1e-7; 
[pp, out_param] = funappx_t(@(x) x.^2, in_param)

% Approximate function x^2 on [-20,20] with error tolerence 1e-7, cost
% budget 1000000, lower bound of initial number of points 10 and upper
% bound of initial number of points 100
%%
% *Example 4*

clear in_param; f = @(x) x.^2;
[pp, out_param] = funappx_t(f,'a',-10,'b',50,'nmax',1e6,'abstol',1e-8)

% Approximate function x^2 with error tolerence 1e-8, cost budget 1000000,
% lower bound of initial number of points 10 and upper
% bound of initial number of points 100
%% See Also
%
% <html>
% <a href="help_integral_g.html">integral_g</a>
% </html>
%
% <html>
% <a href="help_meanMC_g.html">meanMC_g</a>
% </html>
%
% <html>
% <a href="help_cubMC_g.html">cubMC_g</a>
% </html>
%
%% Reference
% [1]  N. Clancy, Y. Ding, C. Hamilton, F. J. Hickernell, and Y. Zhang, The
% Cost of Deterministic, Adaptive, Automatic Algorithms:  Cones, Not Balls,
% Journal of Complexity 30 (2014) 21�45
%
% [2]  Sou-Cheng T. Choi, Yuhan Ding, Fred J. Hickernell, Lan Jiang, and
% Yizhi Zhang, "GAIL: Guaranteed Automatic Integration Library (Version
% 1.3.0)" [MATLAB Software], 2014. Available from
% http://code.google.com/p/gail/
%
% If you find GAIL helpful in your work, please support us by citing the
% above paper and software.
%