function [new_data,new_header,new_label,new_obs]= ...
         apply_window(data,header,label,obs,window,ray_stuff,phase_names);
%   apply_window  apply time windows to coral data
% USAGE: [new_data,new_header,new_label,new_obs]= ...
%        apply_window(data,header,label,obs,window,ray_stuff,phase_names);
% apply window determined using rsx
% output vector has data for columns in input vector for which a
% window was defined.  The array 'window' is sorted by index to the
% trace data array, and redefined to end exactly on data points.

% sort window entries by index to data vector
% determine data point indices closest to window boundaries and
% reset window to start and stop exactly on data indices
% phase_names is optional. it enters phase names into columns 17:22 of label
% phase_names must be a character string of dimension (6,number of seismograms)
%
% new_header Tstart (start time of first sample relative to origin time)
%            Tend end time of desired window
%            index pointing from columns of new_data to columns of data
%            magnification/polarity flip of new_data relative to data
%            number of glitches removed from new_data
%            Hilbert transform switch (0 if it has been applied 1 if it has)
%            
%

% window(:,1) is window relative to first sample (s)
% window(:,2) is window duration (s)
% window(:,3) is index pointing from traces in data to header infromation in 
%             original data read from AH file

if nargin==4,   % only fix label
  new_data=data;
  new_header=header;
  new_label=label; 
  new_obs=obs; 
  resid=new_obs(2,:);
  resid=max(resid,-999.9);
  resid=min(resid, 999.9);
  for i=1:length(resid),
    if (abs(resid(i))==999.9 | isnan(resid(i))),
      temp=' ';
    else
      temp=sprintf('%6.1f',resid(i));
    end
    new_label(23:28,i)=[blanks(6-length(temp)) temp]';
  end
  Magnification=new_header(7,:);
  Phase_shift=new_header(8,:);
  ind=1:length(Magnification);
  new_label(29,ind)=setstr(zeros(size(ind))+abs('?'));
  ind=find(Magnification>0 & Phase_shift==0);
  if length(ind)>0,  new_label(29,ind)=setstr(zeros(size(ind))+abs('+'));  end
  ind=find(Magnification>0 & Phase_shift==90);
  if length(ind)>0,  new_label(29,ind)=setstr(zeros(size(ind))+abs('/'));  end
  ind=find(Magnification<0 & Phase_shift==0);
  if length(ind)>0,  new_label(29,ind)=setstr(zeros(size(ind))+abs('-'));  end
  ind=find(Magnification<0 & Phase_shift==90);
  if length(ind)>0,  new_label(29,ind)=setstr(zeros(size(ind))+abs('\'));  end
  return
end

w_index=window(3,:);
new_header=header(:,w_index);
new_label = label(:,w_index);
new_obs   = obs(:,w_index);

Tstart       =new_header(1,:);
Tdur         =new_header(2,:);
T0           =new_header(3,:);
T1           =new_header(4,:);
Index        =new_header(5,:);
Sintr        =new_header(6,:);
Magnification=new_header(7,:);
Phase_shift  =new_header(8,:);

if nargin<6, 
  Modeltime    =new_header(9,:); 
  Rayparm      =new_header(10,:);
  Dddp         =new_header(11,:);
  Dtdh         =new_header(12,:);
else
  Modeltime    =ray_stuff(1,:);
  Rayparm      =ray_stuff(2,:);
  Dddp         =ray_stuff(3,:);
  Dtdh         =ray_stuff(4,:);
end

if nargin>6, 
  new_label(17:22,:)=phase_names;
end


% force input window to cut along sampled points. ws, we are start and end of window
% (s) relative to start time of trace. is, ie are corresponding indices.

%ws=window(1,:);        we=window(1,:)+window(2,:); 
%is=round(ws./Sintr)+1; ie=round(we./Sintr)+1;      ilength=ie-is+1;
%ws=Sintr.*(is-1);      we=Sintr.*(ie-1);           wlength=Sintr.*(ilength-1);

ws=window(1,:);        
is=round(ws./Sintr)+1;                   ws=Sintr.*(is-1);      
ilength=round(window(2,:)./Sintr)+1;     ie=is+ilength-1;
we=Sintr.*(ie-1);                        wlength=Sintr.*(ilength-1);

n=max(ilength);               % maximum number of data points
m=length(w_index);            % number of traces
new_data=zeros(n,m);          % initialize new data array to zero

Tstart=Tstart+ws;             % new data are shifted in time by ws
T0=max(T0-ws,0);              % time of first non-zero data point shifted by ws
%T1=min(T1-ws,wlength);        % time of last non-zero data point shifted by ws
% above line corrected(?) by PDB, 01Feb99
T1=min(T1-ws,wlength+T0);     % time of last non-zero data point shifted by ws
Tdur  =Sintr.*(n-1);          % total duration of zero and non-zero points
i0=round(T0./Sintr)+1;        % index of first non-zero data point
i1=round(T1./Sintr)+1;        % index of last non-zero data point

% offset data into new data array
jj=0; keep_data_index=zeros(1,m);
for j = 1:m,
  index=i0(j):i1(j);
  if length(index)>1, 
    jj=jj+1; keep_data_index(jj)=j;
    offset=round(ws./Sintr);
    new_data(index,j)=data(index+offset(j),w_index(j));
  end
end
keep_data_index=keep_data_index(1:jj);

new_header=[Tstart;Tdur;T0;T1;Index;Sintr;Magnification;Phase_shift;...
Modeltime;Rayparm;Dddp;Dtdh];
 
% reset label
resid=new_obs(2,:);
resid=max(resid,-999.9);
resid=min(resid, 999.9);
for i=1:m,
  if (abs(resid(i))==999.9  | isnan(resid(i)))
    temp=' ';
  else
    temp=sprintf('%6.1f',resid(i));
  end
  new_label(23:28,i)=[blanks(6-length(temp)) temp]';
end

ind=1:length(Magnification);
new_label(29,ind)=setstr(zeros(size(ind))+abs('?'));
ind=find(Magnification>0 & Phase_shift==0);
if length(ind)>0,  new_label(29,ind)=setstr(zeros(size(ind))+abs('+'));  end
ind=find(Magnification>0 & Phase_shift==90);
if length(ind)>0,  new_label(29,ind)=setstr(zeros(size(ind))+abs('/'));  end
ind=find(Magnification<0 & Phase_shift==0);
if length(ind)>0,  new_label(29,ind)=setstr(zeros(size(ind))+abs('-'));  end
ind=find(Magnification<0 & Phase_shift==90);
if length(ind)>0,  new_label(29,ind)=setstr(zeros(size(ind))+abs('\'));  end

% some requested windows may not contain any data. remove these traces
if length(keep_data_index)<m,
  new_data  =new_data(:,keep_data_index');
  new_header=new_header(:,keep_data_index');
  new_label =new_label(:,keep_data_index');
  new_obs   =new_obs(:,keep_data_index');
end

