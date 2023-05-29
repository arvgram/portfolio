%run 'Lab 3'/lab3_code/init_quadcopter_model.m
%run 'Lab 3'/lab3_code/init_quadcopter_states.m
%run 'Lab 3'/lab3_code/init_quadcopter_states.m
addpath ('Lab 3/lab3_code/')
run init_quadcopter_model.m
run init_quadcopter_states.m
run init_noise_levels.m
%%
maxrpm = 100000;
Omega_in.time = (0:inner_h:10)';
Omega_in.signals.values = linspace(1,maxrpm*2*pi/60,length(Omega_in.time))'*ones(1,4); %You will need to change ones to something better, HINT linspace
%%
disp('starting sim')
out = sim('omega_input','StopTime', '5');
disp('sim done')
%%
figure(1)
clf
plot(out.p)
title('Position')
legend('x','y','z')
%% Using Toolbox, estimating from accelerometer.
dat1 = iddata(out.acc.data(:,3)+g,4*out.Omega.data(:,1),inner_h);      % testing omega^1
dat2 = iddata(out.acc.data(:,3)+g,4*out.Omega.data(:,1).^2,inner_h);    % testing omega^2
dat3 = iddata(out.acc.data(:,3)+g,4*out.Omega.data(:,1).^3,inner_h);    % testing omega^3
sys1 = procest(dat1,'p0');
sys2 = procest(dat2,'p0'); %p0 means zero poles
sys3 = procest(dat3,'p0');

figure(2)
clf
subplot(311)
compare(dat1,sys1)
subplot(312)
compare(dat2,sys2)
subplot(313)
compare(dat3,sys3)
k_est = sys2.Kp*m;
disp("Estimated k: "+ k_est + ". True k: " + k)

