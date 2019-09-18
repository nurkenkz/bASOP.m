%ECE686 Project: implementation of 
%"Simulation-Based stochastic optimal control design and its application to
%building control problems" Lee et al. (2018)
%by Nurken Tuktibayev, University of Waterloo, 2019

clear all;
clc;
tic
%picking random day between 01 Jan 2018 and 30 Dec 2018 
dayn=randi([1 364],1,1);
dayn=80;%{or you can insert any day manually between 1 and 364}

[inp]=inputData(dayn); %initialize state-space model for stochastic system and load weather data for dayn
if inp.noData==1 
    return
else
end;
%%%%%%Stochastic Algorithm for beta-ASOCP
%Algorithm settings and initial data
N_of_iterations=10000;%NOTE: THIS CAN BE LOWERED TO SAVE TIME, BUT 10000 ITERATIONS PROVIDES "GOOD ENOUGH" RESULT
beta = 0.001;
Nj=20;
Nn=1;
delta=0.1;
gamma=0.0001;
Theta1=zeros(50,6);
Theta2=zeros(1,51);
psy1=Theta1*0;
psy2=Theta2*0;

for ii=1:N_of_iterations
%%%%computing stochastic gradient estimate%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
g1=0;
g2=0;
    for j=1:Nn
        sumplus=0;
        summinus=0;
        nu1=randn(50,6); %generate i-th sample of nu
        nu2=randn(1,51); %generate i-th sample of nu
        %computing the sample average for (Theta+beta*nu)
        for i=1:Nj
            w1=randi(inp.as,1,1);
            w2=randi(inp.ds,1,1);
            s=simulation(inp,w1,w2,Theta1+beta*nu1,Theta2+beta*nu2);
            sumplus=sumplus+s.cost;
        end
        sumplus=sumplus/Nj;
        %computing the sample average for (Theta-beta*nu)
        for i=1:Nj
            w1=randi(inp.as,1,1);
            w2=randi(inp.ds,1,1);
            s=simulation(inp,w1,w2,Theta1-beta*nu1,Theta2-beta*nu2);
            summinus=summinus+s.cost;
        end
        summinus=summinus/Nj;
        g1=g1+(1/(2*beta))*nu1*(sumplus-summinus); %sum of differences
        g2=g2+(1/(2*beta))*nu2*(sumplus-summinus); %sum of differences
    end
    g1=g1/Nn; %taking average of the sum
    g2=g2/Nn; %taking average of the sum
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%heuristic modification of Algorithm 1 
    psy1=psy1+delta*(g1-psy1);
    psy2=psy2+delta*(g2-psy2);
    Theta1=Theta1-gamma*psy1;
    Theta2=Theta2-gamma*psy2;
    IterationsLeftInCycle1=N_of_iterations-ii %countdown
    toc
end
disp('New control policy computed based on data for day');
num2str(dayn) %training day number

%Test:
%comparing beta-ASOCP control policy with LQG 
%for the (dayn+1) day of 2018
[inp]=inputData(dayn);
if inp.noData==1 
    return
else
end;
tN=1000;%number of samples
histN=0;
histL=0;
for i=1:tN
w1=randi(inp.as,1,1);
w2=randi(inp.ds,1,1);
%Simulation with new control policy (LQG+calculated parameter theta)
sN=simulation(inp,w1,w2,Theta1,Theta2);
histN(i)=sN.cost;
%Simulation with LQG only
sL=simulation(inp,w1,w2,Theta1*0,Theta2*0);
histL(i)=sL.cost;
IterationsLeftInCycle2=tN-i
end
%output plots for the last simulation and histogram for tN samples
outputData(inp,sN.x,sN.u,sN.z,sN.M,'New',sN.cost,histN,max(max(histN),max(histL))+20);
outputData(inp,sL.x,sL.u,sL.z,sL.M,'LQG',sL.cost,histL,max(max(histN),max(histL))+20);





