function outputData(inp,x,u,z,M,method,cost,h,h_xlim)
figure();
subplot(5,1,1);
hold on
plot(x(1,:));
plot(x(3,:),'--');
plot(x(4,:),'-.');
axis([1, inp.N, -40, 50]);
xlabel('k'); ylabel('Ta Tref(-) To(-.)');
if (method == 'New') 
title(['beta-ASOCP control policy for day=' num2str(inp.dayn) '. Cost=' num2str(round(cost))]);
else 
title(['LQR control policy for day=' num2str(inp.dayn) '. Cost=' num2str(round(cost))]);
end
subplot(5,1,2);
stairs(z(:),'--');
axis([1, inp.N, 0.5, 3.5]);
xlabel('k'); ylabel('User feel');
subplot(5,1,3);
stairs(M(:,1));
axis([1, inp.N, -0.5, 1.5]);
xlabel('k'); ylabel('Occupancy');
subplot(5,1,4);
plot(u(:));
axis([1, inp.N, -1050, 1050]);
xlabel('k'); ylabel('Control');
subplot(5,1,5);
histogram(h);
xlim([0, h_xlim]);
hold off
end

