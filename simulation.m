function s = simulation(inp,w1,w2,weight1,weight2)
%initializing data
s.x(:,1)=inp.x0;
s.cost=0;
s.u=0;
s.z=0;
s.M=[0;0];
for k=1:inp.N-1 %24 hours cycle (96*15 minutes)
Pi=weight2*[1./(1+exp(-(weight1*[s.x(:,k);k;1])));1]; %new parameter
s.u(k)=1000*satlins((-inp.F(k,:)*s.x(:,k)+Pi)/1000); %control
%calculating day number%%%%%%%%%%%%%%
if (k/96)<(round(k/96)) 
dayn=round(k/96)-1;
else
dayn=round(k/96);
end
%cost function selection
if ((k<w1+dayn*96) || (k>w2+dayn*96))
s.cost=s.cost+s.u(k)'*inp.R*s.u(k);
else
s.cost=s.cost+s.x(:,k)'*inp.Q*s.x(:,k)+s.u(k)'*inp.R*s.u(k);
end 
%occupancy map: 1=occupant in the office, 2=occupant not in the office
if ((k<w1+dayn*96) || (k>w2+dayn*96))
s.M(k,1)=0;
else
s.M(k,1)=1;
end
%computing probablity of occupant action based indoor temperature using pdf
p_index=round(s.x(1,k))-inp.pdf_x(1)+1; %scaling current temperature into [10 30] scale
if p_index<1
    p_index=1;
end
if p_index>21
    p_index=21;
end
prob(1)=inp.pdf_y(p_index,1); %probability of feeling cold
prob(2)=inp.pdf_y(p_index,2); %probability of comfort feeling
prob(3)=inp.pdf_y(p_index,3); %probability of feeling hot
prob = prob /sum(prob); %scaling all 3 into [0 1] scale
random=rand;
lowest=0;
for i=1:3 %finding correct interval for the random value
if((random>=0)&&(random<lowest+prob(i)))
s.z(k) = i;
break;
end    
lowest=lowest+prob(i);
end
%selecting ocupants action based on occupancy and temperature feelings
w3=randi([0 1],1);
if s.z(k)==1
    s.M(k,2)=w3*s.M(k,1);
elseif s.z(k)==2
   s.M(k,2)=0;
elseif s.z(k)==3
    s.M(k,2)=-w3*s.M(k,1);
end
%state-space model
w=[inp.qsolar(k);75+70*s.M(k,1);s.M(k,2);inp.To(k+1)-inp.To(k);];%noise
s.x(:,k+1)=inp.A*s.x(:,k)+inp.B*s.u(k)+inp.D*w; %state

if s.x(3,k+1)>30 %setpoint limit
s.x(3,k+1)=30;
end
if s.x(3,k+1)<15
s.x(3,k+1)=15;
end

end
end

