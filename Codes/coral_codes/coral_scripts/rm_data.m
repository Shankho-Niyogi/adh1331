% coral script to remove data from data1;
% before running this script you must construct 'keep_key'
% which is a vector of indices to the data in data1 that you
% want to keep.  This set of code is identical to a part of
% code in coral.m

m_data=size(data1,2);
if length(keep_key)<m_data & length(keep_key)>0
  data1=data1(:,keep_key);  header1=header1(:,keep_key);
  label1=label1(:,keep_key); obs1=obs1(:,keep_key);
end