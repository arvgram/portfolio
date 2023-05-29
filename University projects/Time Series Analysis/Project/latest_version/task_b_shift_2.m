rng(0)
addpath Project/latest_version/custom_functions/
clear 
clc
df = loadCleanValidate(0);
start_date = '1994-09-01';

%%
df = shift_exo(df, 1);
[df_train, df_val, df_test] = trainValTestSplit(df, start_date, 1);


%%
testdf = df;
interpolated = mod(testdf.hour,3) ~= 1;
testdf.tp_vxo(interpolated) = nan;
testdf.tp_stu(interpolated) = nan;
testdf.tp_stu = fillmissing(testdf.tp_stu,"previous");
testdf.tp_vxo = fillmissing(testdf.tp_vxo,"previous");

shift = 3;
shiftedStu = testdf.tp_stu(1+shift:end);
shiftedVxo = testdf.tp_vxo(1+shift:end);

plot(testdf.time(12000:12500),testdf.t_sla(12000:12500))
hold on
plot(testdf.time(12000:12500),df.tp_stu(12000:12500))

legend(["Svedala temp", "Sturup pred shifted"])