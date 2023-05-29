load Project/projDatafiles/utempSla_9395.dat
load Project/projDatafiles/utempHar_9395.dat
load Project/projDatafiles/utempAva_9395.dat
%%
clear all
clc
close all
%% making a table of the data with a datetime column
start_time = '1-Jan-1993'; %% for datetime series
y = utempSla_9395(:,3);
t = datetime(start_time):hours(1):datetime(start_time) + hours(length(y)-1);

df = array2table(utempSla_9395, 'VariableNames',{'year','hour','temperature'});
df.('time') = t';
df = df(6803:end, :);

%% data wrangling, handling missing values with linear interpolation
% 
idx = df.hour == 23;
df.temperature(idx) = NaN; 
df.temperature = fillmissing(df.temperature,'linear'); 
sum(isnan(df.temperature))

idx = df.temperature == 0;
df.temperature(idx) = NaN; 
df.temperature = fillmissing(df.temperature,'linear'); 
sum(isnan(df.temperature)) %% if this is 0 we have successfully removed all NaN
%%
plot(df.time,df.temperature)
%%


tacfEstimate = tacf(df_train.temperature);
acfEstimate = acf(df_train.temperature);

figure
subplot(211)
plot(acfEstimate)
subplot(212)
plot(tacfEstimate)




