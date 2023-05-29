function [df] = loadCleanValidate(plotIt)
%loadCleanValidate loads temperature data used in project
%   Detailed explanation goes here
%   arg ploIt (int): flag that determines weather to plot some of the steps
%   in the cleaning process. Plots if set to 1 otherwise does not
%   return df: A cleaned table containing the temperature data in svedala
%   coupled with the temperature in the other places by hour.
dir_suffix = "Project/latest_version";
dir_stem = dir_suffix + "/projDatafiles/";

load(dir_stem + "utempSla_9395.dat")

load (dir_stem + "ptstu93.mat")
load (dir_stem + "ptstu94.mat")
load (dir_stem + "ptstu95.mat")

load (dir_stem + "ptvxo93.mat")
load (dir_stem + "ptvxo94.mat")
load (dir_stem + "ptvxo95.mat")

load (dir_stem + "tid93.mat")
load (dir_stem + "tid94.mat")
load (dir_stem + "tid95.mat")


T = vertcat(tid93, tid94, tid95);
utetempstur = vertcat(ptstu93,ptstu94,ptstu95);
utetempvxo = vertcat(ptvxo93,ptvxo94,ptvxo95);

% since they differ in length we zeropad to make ends meet
zeropad = zeros(1,length(utetempstur)-length(utetempvxo))';
utetempvxo = vertcat(utetempvxo,zeropad);
shift = 2;
% We begin by making one dataset with time and temperature data, and alining
% them 
big = horzcat(utetempvxo,utetempstur, utempSla_9395, T(1:length(utempSla_9395),:)); %Ok since they start on same date

% Data validation checks
% we check that the year time stamp (which is present in both sets) aline
assert(mean(big(:,1+shift) == big(:,5+shift)) == 1)
% we check that the hourly time stamp also aline
assert(mean(big(:,2+shift) == big(:,8+shift)) == 1)
% if both of the above values are 1 then our concatenation is successful


% removing unnecessary columns
new_big = big(:,[1 2 1+shift 2+shift 3+shift]);

% using table format instead, for less cumbersome handling 
df = array2table(new_big, 'VariableNames',{'tp_vxo','tp_stu','year','hour','t_sla'});

% making a date-time-table instead for easier represenation 
start_time = '1-Jan-1993';
t = datetime(start_time):hours(1):datetime(start_time) + hours(length(df.t_sla)-1);
df.('time') = t';

% removing the first samples that are from before start of measurements 
df = df(6803:end, :);

if plotIt == 1
    for name = ["t_sla", "tp_stu", "tp_vxo"]
        
        figure
        start = length(df.(name)) / 2;
        ed = start + 10*24*7 ;
        plot(df.time(start:ed), df.(name)(start:ed))
        title(name)
    end 
end

%handling the 23 oclock-thing by setting it as NaN and fill them as linear intepolation
idx = df.hour == 23;
df.t_sla(idx) = NaN; 
df.t_sla= fillmissing(df.t_sla,'linear'); 

%checking that we caught all NaN
assert(sum(isnan(df.t_sla))==0)


if plotIt == 1
    figure()
    plot(df.time, df.t_sla)
end


% We figure that the best way is to handle all identically zero values as 
% a linear interpolation between previous and next value. This will not 
% disturb the winter temperature that actually are zero too much since we 
% measure with one decimal and they will probably be close to their acutal
% value after interpolation

idx = df.t_sla == 0;
df.t_sla(idx) = NaN; 
df.t_sla = fillmissing(df.t_sla,'linear'); 
assert(sum(isnan(df.t_sla))==0)

if plotIt == 1
    figure()
    plot(df.time,df.t_sla)
end


end

