function [Data, Extras, Record, Comment, Calib, Loc, Station] = ...
       sort_ah(Data, Extras, Record, Comment, Calib, Loc, Station, key);
%   sort_ah       sort data in matlab/ah format
% usage: [Data, Extras, Record, Comment, Calib, Loc, Station] = ...
%      sort_ah(Data, Extras, Record, Comment, Calib, Loc, Station, key);
% 
%  Reorder, duplicate, or delete data/header records using the
%  vector 'key'. For example, if there are 4 records, and you want
%  two copies of the third record followed by one of the second record,
%  while deleting the first and forth, set key=[3 3 2].
%  To sort by distance define key by:  [junk,key]=sort(Delta)
%  To sort by decreasing distance   :  [junk,key]=sort(-Delta)

if max(key) > length(Data(1,:)),
   error=[' Error in SORTAH, there are only ' num2str(n) ...
   ' records, but you attempted to sort the ' num2str(max(key)) ...
   'th record']
else
  Station=Station(:,key);
  Loc    =Loc(:,key);
  Calib  =Calib(:,key);
  Comment=Comment(:,key);
  Record =Record(:,key);
  Extras =Extras(:,key);
  Data   =Data(:,key);
end
