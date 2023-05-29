function [df_train,df_val, df_test] = trainValTestSplit(df, start_date, plotIt)
%TRAINVALTESTSPLIT Summary of this function goes here
%   Detailed explanation goes here
start_train = find(df.time == start_date);
end_train= start_train + 10*24*7;

start_val = end_train;
end_val = end_train + 2*24*7;

start_test = end_train + 20*24*7;
end_test = start_test + 2*24*7;


df_train = df(start_train:end_train,:);
df_val = df(start_val:end_val,:);
df_test = df(start_test:end_test,:); %Never touch this :)


if plotIt == 1
    f = figure;
    newcolors = ["#0072BD","#D95319","#77AC30"];
    colororder(newcolors);
    f.Position = [100 100 700 300];
    
    subplot(311)
    plot(df_train.time, df_train.t_sla)
    hold on
    plot(df_val.time, df_val.t_sla)
    plot(df_test.time, df_test.t_sla)
    title('SVEDALA')
    l1 = legend(["Train", "Validation", "Test"]);
    l1.Location = "south";
    
    subplot(312)
    
    plot(df_train.time, df_train.tp_stu)
    hold on
    plot(df_val.time, df_val.tp_stu)
    plot(df_test.time, df_test.tp_stu)
    title('STURUP')
    l2 = legend(["Train", "Validation", "Test"]);
    l2.Location = "south";

    subplot(313)
    
    plot(df_train.time, df_train.tp_vxo)
    hold on
    plot(df_val.time, df_val.tp_vxo)
    plot(df_test.time, df_test.tp_vxo)
    title('VÄXJÖ')
    l3 = legend(["Train", "Validation", "Test"]);
    l3.Location = "south";
end
end

