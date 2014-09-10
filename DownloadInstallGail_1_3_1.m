% This scripts is to download and install GAIL version 1.3.1 into the
% location you choose
%
%   Step 1.  Place this M-file where you want GAIL to go
%
%   Step 2.  Run this M-file in MATLAB
%
%This file installs GAIL version 1.3.1 in the subdirectory
%"GAIL_1.3.0/GAIL_Matlab".
%% Download the package and change the directory
disp('The GAIL package is now being downloaded...')
unzip('http://math.iit.edu/~openscholar/sites/default/files/meshfree/files/gail_1_3_1.zip') %download and unzip
cd('GAIL_1_3_1')  %get to the right subdirectory

%% Install GAIL
GAIL_Install      %this installs GAIL
fprintf('\n\nNext we will run a quick test. Press RETURN to continue...\n')
pause

%% Run a quick test
fprintf('\nmuhat=meanMC_g(@(n) rand(n,1))\n')
muhat=meanMC_g(@(n) rand(n,1)) %run meanMC_g once
fprintf('\nThis answer should be close to 0.5.\n\n')
%Then you should be ready to use GAIL
disp('Next README.txt will be displayed. Press RETURN to continue to ');
disp('the next line, or press the spacebar to advance to the next page...');
pause

%% Print out README.txt
more on
type('README.txt')
more off