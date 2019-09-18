function [inp] = inputData(dayn)

inp.N=96; %discrete time horizon
dt=15*60; %sampling time in seconds

inp.as=[32 36];  %arrival time distribution set (8-9AM)
inp.ds=[64 76]; %departure time distribution set (4-7PM)

%importing thermal probability density function
if (exist('pdf_data.mat')==2)
    load('pdf_data.mat','pdf_x','pdf_y');
    inp.pdf_x=pdf_x;
    inp.pdf_y=pdf_y;
    inp.noData=0;
else disp('Please load thermal pdf to pdf_data.mat and restart the program');
    inp.noData=1;
    return
end

%importing weather data weather2018.cvs (Source: http://weather.uwaterloo.ca/)
if (exist('weather2018.mat')==2)
    load('weather2018.mat','To','qsolar');
    inp.noData=0;
else disp('Please load weather data to weather2018.mat and restart the program');
    inp.noData=1;
    return
end

%loading data for selected day
inp.dayn=dayn;
for i=1:inp.N
inp.To(i)=To((inp.dayn-1)*96+i);
inp.qsolar(i)=qsolar((inp.dayn-1)*96+i);
end

%Data from Table I for 3x3 sqm room with 2.5 sqm window (from EnergyBuild)
R1=0.0084197;
R2=0.044014;
R3=4.38;
C1=9861100;
C2=128560;
a=0.55;

%cost function data
inp.R=0.00001;%(by experiments)
inp.Q=[1 0 -1 0]'*[1 0 -1 0];

%STATE-SPACE MODEL
inp.x0=[21 21 21 To(1)]';
inp.A=[1-dt/(C2*R2)-dt/(C2*R1) dt/(C2*R1) 0 dt/(C2*R2); dt/(C1*R1) 1-dt/(C1*R1)-dt/(C1*R3) 0 dt/(C1*R3); 0 0 1 0; 0 0 0 1];
inp.B=[dt/C2; 0; 0; 0];
inp.D=[(dt*(1-a))/C2 dt/C2 0 0;(dt*a)/C1 0 0 0;0 0 1 0;0 0 0 1];

%FINITE-HORIZON LQR
G(:,:,inp.N)=inp.Q;
for i=inp.N-1:-1:1
inp.F(i,:)=inv(inp.R+inp.B'*G(:,:,i+1)*inp.B)*inp.B'*G(:,:,i+1)*inp.A;
G(:,:,i)=inp.Q+inp.A'*G(:,:,i+1)*inp.A-inp.F(i,:)'*(inp.R+inp.B'*G(:,:,i+1)*inp.B)*inp.F(i,:);
end
end

