run coral, cut out data into data1

eval data4=data1;obs4=obs1;label4=label1;header4=header1;

read synthetics and cut into data 1

eval data2=data4;obs2=obs4;label2=label4;header2=header4;
cat 2 1
eval nsyn=size(data1,2)/2; yval=[1:nsyn,[1:nsyn]+.2];
eval my_rsx(plt_offset,data1,yval,header1,Syn,plot_scale,titl,' ',label1,1,[]);

