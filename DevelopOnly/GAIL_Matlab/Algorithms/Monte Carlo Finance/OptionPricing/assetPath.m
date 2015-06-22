classdef assetPath < brownianMotion

%% assetPath
% is a class of discretized stochastic processes that model the values of
% an asset with respect to time. Browniam motions are used to build these
% asset paths.
% 
%
% Example 1
% >> obj = assetPath
% obj = 
%   assetPath with properties:
% 
%                 inputType: 'n'
%        timeDim_timeVector: [1 2 3]
%         timeDim_startTime: 1
%           timeDim_endTime: 3
%          timeDim_initTime: 0
%         timeDim_initValue: 10
%        wnParam_sampleKind: 'IID'
%       wnParam_distribName: 'Gaussian'
%          wnParam_xDistrib: 'Uniform'
%      bmParam_assembleType: 'diff'
%       assetParam_pathType: 'GBM'
%      assetParam_initPrice: 10
%       assetParam_interest: 0.0100
%     assetParam_volatility: 0.5000

% Authors: Fred J. Hickernell

%% Properties
% This process inherits properties from the |stochProcess| class.  Below are 
% values assigned to that are abstractly defined in that class plus some
% properties particulary for this class

   properties (SetAccess=public) %so they can only be set by the constructor
      assetParam = struct('pathType', 'GBM', ... %type of asset path
         'initPrice', 10, ... %initial asset price
         'interest', 0.01, ... %interest rate
         'volatility', 0.5) %volatility      
   end
   
   properties (Constant, Hidden) %do not change & not seen
      allowPathType = {'GBM'} 
         %kinds of asset paths that we can generate
   end



%% Methods
% The constructor for |assetPath| uses the |brownianMotion| constructor
% and then parses the other properties. The function |genStockPaths| generates
% the asset paths based on |whiteNoise| paths.

   methods
        
      % Creating an asset path process
      function obj = assetPath(varargin)         
         obj@brownianMotion(varargin{:}) %parse basic input
         if isfield(obj.restInput,'assetParam')
            val = obj.restInput.assetParam;
            obj.assetParam = val;
            obj.restInput = rmfield(obj.restInput,'assetParam');
         end
         obj.timeDim = struct('initTime',0, ...
            'initValue',obj.assetParam.initPrice);
      end
           
      % Set the properties of the payoff object
      function set.assetParam(obj,val)
         if isfield(val,'pathType') %data for type of option
            assert(any(strcmp(val.optType,obj.allowPathType)))
            obj.assetParam.pathType=val.pathType; %row
         end
         if isfield(val,'initPrice') %data for type of option
            validateattributes(val.initPrice,{'numeric'}, ...
               {'nonnegative'})
            obj.assetParam.initPrice=val.initPrice; %row
         end
         if isfield(val,'interest') %data for type of option
            validateattributes(val.interest,{'numeric'}, ...
               {'nonnegative'})
            obj.assetParam.interest=val.interest; %row
         end
         if isfield(val,'volatility') %data for type of option
            validateattributes(val.volatility,{'numeric'}, ...
               {'nonnegative'})
            obj.assetParam.volatility=val.volatility; %row
         end
      end
      
      % Generate Brownian Motion paths
      function paths=genPaths(obj,val)
         paths = genPaths@brownianMotion(obj,val);
         if strcmp(obj.assetParam.pathType,'GBM')
            paths = obj.assetParam.initPrice * ...
               exp(bsxfun(@plus,(obj.assetParam.interest - obj.assetParam.volatility.^2/2) ...
               .* obj.timeDim.timeVector, obj.assetParam.volatility .* paths));
         end
      end
                 
   end

   methods (Access = protected)

      function propList = getPropertyList(obj)
         propList = getPropertyList@brownianMotion(obj);
         propList.assetParam_pathType = obj.assetParam.pathType;
         propList.assetParam_initPrice = obj.assetParam.initPrice;
         propList.assetParam_interest = obj.assetParam.interest;
         propList.assetParam_volatility = obj.assetParam.volatility;
      end

   end

end

