%define test function
f1 = @(x) x;
f2 = @(x) x.^2;
f3 = @(x,a) exp(-1000*(x-a).^2);
f4 = @(x,a) 1/4*a*exp(-2*x).*(a-2*exp(x).*(-1 + a*cos(x) - a*sin(x))...
    +exp(2*x).*(a + 2*cos(x) - 2* sin(x) - a *sin(2*x)));
n = 4;
time = zeros(n,2);
npoints = zeros(n,2);
nrep = 10;
a = -2;
b = 2;
randa = rand(nrep,1)*(b-a)+a;
warning('off','MATLAB:funappx_g:peaky')
for i = 1:nrep;
    tic;
    [~, out_param] = funappx_g(f1,a,b,1e-6,9,25);
    t=toc;
    time(1,1) = time(1,1) + t;
    npoints(1,1) = out_param.npoints;
    tic;
    [~, out_param] = funappxlocal_g(f1,a,b,1e-6,9,25);
    t=toc;
    time(1,2) = time(1,2) + t;
    npoints(1,2) = out_param.npoints;
    tic;
    [~, out_param] = funappx_g(f2,a,b,1e-6,9,25);
    t=toc;
    time(2,1) = time(2,1) + t;
    npoints(2,1) = out_param.npoints;
    tic;
    [~, out_param] = funappxlocal_g(f2,a,b,1e-6,9,25);
    t=toc;
    time(2,2) = time(2,2) + t;
    npoints(2,2) = out_param.npoints;
    f3 = @(x) exp(-1000*(x-randa(i)).^2);
    tic;
    [~, out_param] = funappx_g(f3,a,b,1e-6,9,25);
    t=toc;
    time(3,1) = time(3,1) + t;
    npoints(3,1) = out_param.npoints;
    tic;
    [~, out_param] = funappxlocal_g(f3,a,b,1e-6,9,25);
    t=toc;
    time(3,2) = time(3,2) + t;
    npoints(3,2) = out_param.npoints;
    f4 = @(x) 1/4*randa(i)*exp(-2*x).*(randa(i)-2*exp(x).*(-1 +...
        randa(i)*cos(x) - randa(i)*sin(x))+exp(2*x).*(randa(i) + 2*cos(x)...
        - 2* sin(x) - randa(i)*sin(2*x)));
    tic;
    [~, out_param] = funappx_g(f4,a,b,1e-6,9,25);
    t=toc;
    time(4,1) = time(4,1) + t;
    npoints(4,1) = out_param.npoints;
    tic;
    [~, out_param] = funappxlocal_g(f4,a,b,1e-6,9,25);
    t=toc;
    time(4,2) = time(4,2) + t;
    npoints(4,2) = out_param.npoints;
end;

display(' ')
display('   Test        # Points          Time Used')
display(' Function    Global   Local    Global     Local')
for i=1:n
    display(sprintf(['%8.0f %8.0f  %7.0f %10.6f  %10.6f'],...
        [i npoints(i,1) npoints(i,2) time(i,1)/nrep time(i,2)/nrep])) 
end