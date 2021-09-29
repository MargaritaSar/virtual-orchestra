classdef clappingAgent
%clappingAgent - Captures an agent that produces repeated claps at a period after a
% clap has happened and can correct for the asynchrony with other agents
%
%   Description: the class can be called multiple times to generate
%   ensamble of agents that synchronise to each other if their relative
%   error is passed to the other agents
%
%   Other m-files required: none
%   MAT-files required: none
%

%   Author: Max Di Luca
%   email: m.diluca@bham.ac.uk
%   Date: 11/03/2021
%
%   Last revision: $date, Author, Changes

    properties
        % variables, whose values are assigned to the instance
        alpha; %correcting factor, proportion of the asynchrony sensed
        error; %random noise in the timing of the clap
        period; %duration after which the next clap should happen
        clapTime; %actual clap time
    end
    
    methods
        % 'functions' that the agent can perform, including the constructor are defined in this block
        
        %this is the constructor, creating the agent. It just takes the
        %variables that defines the agent behaviour
        function obj=clappingAgent(alpha,noise,period)
            obj.alpha=alpha;
            obj.error=noise;
            obj.period=period;
        end
        
        %'get' methods are used to know the values of an agent/instance. Here to know when the agent has clapped
        function time=getClapTime(obj)
            time=obj.clapTime;
        end
        
        %The set is used to change variables of an agent/instance. Here it is used at the beginning of the clapping to determine when the first clap happens
        function obj=setClapTime(obj,timeclap)
            obj.clapTime=timeclap;
        end
        
        function obj=setAlpha(obj,a)
            obj.alpha=a;
        end
        
        %This function does the actual legwork to determine when the next clap happens
        function obj=playClap(obj,asynchronies)
            obj.clapTime=obj.clapTime + obj.period - mean(asynchronies*obj.alpha') + randn(1)*obj.error;
        end
         
    end
end

