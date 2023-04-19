function [data, ierr, header]=coralDeconInst(data, options, Calib, header);
%   coralDeconInst    deconvolve instrument response from data in coral format
% USAGE: [data, ierr]=coralDeconInst(data, options);
%
% Input:
% data    can be the coral structure, or it can be the data matrix from the old coral format.
%         If using the old coral format then Calib and header must be included in the input arguments
%         otherwise they should not be inclided
% options must be a structure containing the field opt which must be a character string
%         containing the deco or Deco command which is documented in coral.man
% Calib   complex matrix of instrument responses stored by columns
%         There are 62 rows in a format described below.
% header  header matrix 
%
% Output:
% data    is the deconvolved data in the coral structure or old coral matrix depending 
%         on input data variable
% ierr    = vector indicating which data were properly deconvolved
%         = 0 mean deconvolution is OK
%         = 3 if errors in input parameters
%
% header  is the update header matrix, only used for old coral format
%
% calls coralDeconInstPre and coralDeconInstPost
%
% K. Creager  kcc@ess.washington.edu   11/22/2004


if nargin == 2;
  
  [calib_old, calib_new, waterlevel, ierr] = coralDeconInstPre(data, options);
  if sum(ierr)>0; 
    return
  end
  [data,ierr]=coralDeconInstPost(data,calib_old,calib_new,waterlevel,options);
  
else
  
  [calib_old, calib_new, waterlevel, ierr] = coralDeconInstPre(data, options, Calib);
  if sum(ierr)>0; 
    return
  end
  [data,ierr,header]=coralDeconInstPost(data,calib_old,calib_new,waterlevel,options,header);
end
return


function [calib_old, calib_new, waterlevel, ierr] = coralDeconInstPre(data, options, Calib);
%   coralDeconInstPre    calculate calibration information to pass to coralDeconInst
% USAGE: [calib_old, calib_new, waterlevel, ierr] = coralDeconInstPre(data, options, Calib);
% Input:
% data    can be the coral structure, or it can be the header matrix from the old coral format
%         if using the old coral format then Calib must be included in the input arguments
%         otherwise it should not be inclided
% options must be a structure containing the field opt which must be a character string
%         containing the deco or Deco command which is documented on coral.man
% outputs are passed to coralDeconInst

% K. Creager  kcc@ess.washington.edu   2/17/2004

% default values for output parameters
calib_old  = [];
calib_new  = [];
waterlevel = 1e-8;
gain       = 1;
ierr       = 0;

header_class = class(data);

if strcmp(header_class,'struct');  % data is a structure; use methods for new data format
  
    if nargin<2;
    disp('error: coralDeconInstPre requires 1 arguments')
    ierr = 3;
    return
  end

  ndata = length(data);
  % indx is an index vector pointing to seismograms with pole-zero type instrument responses
  indx = [];
  if isfield(data,'staRespType');
    indx = find(strcmp('PZ',{data.staRespType}));
  end
  calib_old = zeros(62,ndata);
  for kk=1:length(indx);
    k=indx(kk);
    POLES = [data(k).staPoles];
    ZEROS = [data(k).staZeros];
    nPOLES= length(POLES);
    nZEROS= length(ZEROS);
    calib_old(1,k) = data(k).staNormalization;
    calib_old(2,k) = data(k).staGain;
    calib_old(3,k) = nPOLES;
    calib_old(33,k)= nZEROS;
    calib_old(3+[1:nPOLES],k)  = POLES;
    calib_old(33+[1:nZEROS],k) = ZEROS;
  end
  
  %calib_old = [[data.staNormalization]; [data.staGain]; [data.staPoles]; [data.staZeros]];
  
elseif strcmp(header_class,'double');  % header is a double; use methods for old data format

  if nargin<3;
    disp('error: coralDeconInstPre requires 3 arguments')
    ierr = 3;
    return
  end
  header = data; % this is actually the header matrix from the old coral format
  ndata = size(header,2);
  w_index=header(5,:);
  calib_old=Calib(:,w_index);

else
  
  disp('Error in ''coralDeconInstPre'': data must be a structure or double array')
  ierr=3;
  return
  
end
ierr_tmp=1;
if strcmp(class(options),'struct');  % Is input parameter a structure?
  if any(strcmp('opt',fieldnames(options))) % Does 'options' contain the field 'opt'?
    opt = options.opt;
    if strcmp(class(opt),'char');  % Is options,opt a character array?
      ierr_tmp=0;
    end
  end
end
if ierr_tmp==1;
  disp('Error in ''coralDeconInstPre'': second input argument must be a structure containing the field ''opt'' which is a character array')
  ierr=3;
  return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Determine parameters calib_new, waterlevel, gain using the Deco option
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(opt(1:4), 'Deco')
  % deconvolve instrument response decode the inputs
  
  % set defaults
	commands = ['from';'to  ';'wl  ';'gain';'cos ';'gaus'];
	from='i';
	to  ='d';   to_is_num='f';
	cosf= [];
	gaus= [];
	ierr=0;
	[str,n]=cut_string(opt);
	str=[str,blanks(n)'];
	[n,m]=size(str);
	i=2;
	while i<=n
      command=str(i,1:4);
      k=strcmp2(command,commands);
      if k==0,
        disp([' command ' command ' not recognized --retry'])
        ierr=1;
        break
      end
      if    k==1, % command is 'from'
        if i+1>n,  
          ierr=2; break;
        else 
          from=str(i+1,1); 
          if ~findstr(from,'inIN'),
            disp(' deco from must have an argument of i or n')
            ierr=3, break
          end
        end
        i=i+2;
      elseif k==2, % command is 'to'
        if i+1>n,  
          ierr=2; break;
        else 
          to=str(i+1,1);
          if ~findstr(to,'slirvdan'),
            [to,count,ERRMSG]=sscanf(str(i+1,:),'%d');
            if length(ERRMSG)~=0,
              disp(' deco to must have an argument of l s i r v d a n or an integer')
              ierr=3, break
            else 
              to_is_num='t';
            end
          end
        end
        i=i+2;
      elseif k==3, % command is 'wl'
        if i+1>n,  
          ierr=2; break;
        else 
          [waterlevel,count,ERRMSG]=sscanf(str(i+1,:),'%f');
          if length(ERRMSG)~=0,
            disp(' deco wl must have one argument that is a number')
            ierr=3, break
           end
        end
        i=i+2;
      elseif k==4, % command is gain
        if i+1>n,  
          ierr=2; break;
        else 
          [gain,count,ERRMSG]=sscanf(str(i+1,:),'%f');
          if length(ERRMSG)~=0,
            disp(' deco gain must have one argument that is a number')
            ierr=3, break
           end
        end
        i=i+2;
      elseif k==5, % command is cos 
        if i+4>n,
          ierr=2; break;
        else
          [cosf,count,ERRMSG]=sscanf(str(i+1:i+4,:)','%f');
          if length(ERRMSG)~=0,
            disp(' deco cos must have four arguments that is are numbers')
            ierr=3, break
          end
        end
        i=i+5;
      elseif k==6, % command is gaus
        if i+2>n,
          ierr=2; break;
        else
          [gaus,count,ERRMSG]=sscanf(str(i+1:i+2,:)','%f');
          if length(ERRMSG)~=0,
            disp(' deco gaus must have two arguments that are numbers')
            ierr=3, break
           end
        end
        i=i+3;
      end
	end

      
	if ierr==0, 
    
 
	%  if to is a number or one of  slri  then calib_new is described as pole-zeros
	%  and no other frequency filters are applied.  
	
      if to_is_num=='t';
        if to<=ndata;
          calib_new=calib_old(:,to);
        else
          disp(' error in Deco to integer where integer is too big')
          ierr=3;
          return
        end
      else
        if findstr(to,'slir');
          calib_new=get_inst_resp(to);
        end
      end
	
	%  if  from i to vda  then change calib_old to proper units
	%  in this case and from n to n, apply cosine or gaussian filter
      temp=length(findstr(to,'vda'));
      if (from=='i' & temp) | (from=='n' & to=='n')
        if from=='i' & findstr(to,'vda')
          calib_old=conv_response(calib_old,'d',to,1);
        end
        if     length(cosf)>0,
          calib_new=[3,1,cosf'];
        elseif length(gaus)>0, 
          calib_new=[4,1,gaus'];
        end
      end
	
	
      if length(calib_new)==0,
        disp('some combination of parameters set for deconvolution is not valid')
        disp('type help')
        ierr=4;
        return
      else
        if from == 'n';
          calib_old=calib_old*0;
          calib_old(1:2,:)=calib_old(1:2,:)+1;
        end
      end
      
 %     if ierr==0,
 %       data1=decon_inst(data1,calib_old,calib_new,sintr1,key,waterlevel)/gain;
 %    end
	end
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Determine parameters calib_new, waterlevel, gain using the deco option
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
elseif strcmp(opt(1:4), 'deco')
 
  %[data1,ierr] = coral_deco (opt,data1,header1,Calib);

 % deconvolve instrument response 
   [smat,n_smat]=cut_string(opt);
   calib_key=-1;
   if n_smat==1,
     disp('deco requires at least one argument')
     calib_key=-1;
   else
     [calib_new,calib_count,ERRMSG]=sscanf(opt, ... 
     '%*s %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f');
     if length(ERRMSG)==0,
       if calib_count<=2,% if there are 1 or 2 arguments and both are numbers
         calib_key=2;    % the first is an index. reconvolve Calib(index) 
         calib_no=calib_new(1);
         if calib_no<1 | calib_no>ndata;
           disp('first argument of deco out of range of possible integers--retry') 
           calib_key=-1;
         end
       else                  % if there are more than 2 arguments, the first
                             % is a key to determine type of reconvolution
         calib_key=calib_new(1); 
         if calib_key==3,
           if calib_count~=7,
             disp('deco key equals 3 for cos tapered output filter response')
             disp('arguments must be: waterlevel,gain,f1,f2,f3,f4--retry')
             calib_key=-1;
           else
             calib_new=calib_new([1,3:7]);
           end
         elseif calib_key==4,
           if calib_count~=3 & calib_count~=4
             disp('deco key equals 4 for gaussian tapered output filter response')
             disp('arguments must be: waterlevel,gain,f2,[f0]--retry')
             calib_key=-1;
           else
             calib_new=calib_new([1,3:length(calib)]);
           end
         else  
           disp('Error in definition of new response--retry')
           calib_key=-1;
         end
       end  
     elseif smat(2)=='s' | smat(2)=='i' | smat(2)=='l' | smat(2)=='r',
       calib_key=1;
     else   
       disp('error in definition of new response--retry')
       calib_key=-1;
     end
     if calib_key~=-1;
       if n_smat>=3, waterlevel=sscanf(smat(3,:)','%f'); else, waterlevel=1e-6; end

       if calib_key==1,
         calib_new=get_inst_resp(smat(2));
       elseif calib_key==2,
         calib_new=calib_old(:,calib_no);
         if strcmp(header_class,'struct');  % header is a structure; use methods for new data format
           station_deco = data(calib_no).staCode;
         else
           station_deco = setstr(Station(2:5,w_index(calib_no)));
         end
         disp(['convolve with instrument response of:' station_deco ])
       end
       %data1=decon_inst(data1,calib_old,calib_new,sintr1,key,waterlevel);
     end
   end
   if calib_key==-1; ierr=4; else; ierr=0; end
   
 end
 
 return




function [data,ierr,header]=coralDeconInstPost(data,calib_old,calib_new,waterlevel,options,header);
%   decon_inst    deconvolve instrument response
% Usage: [data,ierr,header]=coralDeconInst(data,calib_old,calib_new,waterlevel,options,header);
%
% Deconvolve old instrument response from data and convolve new 
% instrument response.  Stabilize using a waterlevel (eg = 1e-8).
%
%INPUT PARAMETERS:
% see coral for explanation of the structures header and data
% calib_old   = complex matrix of instrument responses stored by columns
%               There are 62 rows in a format described below.
% calib_new   = complex column vector describing the new instrument response
%               If there are 62 rows it contains poles and zeros in the 
%               format described below.
%               If calib_new has fewer than 62 elements, the first
%               element is a key to the description of the new response
%               If calib_new(1)==3 then use a zero-phase cos (hanning) taper in the
%                 frequency domain
%                 In this case calib_new contains 6 numbers:
%                 [3,gain,f1,f2,f3,f4] 
%               If calib_new(1)==4 then use a zero-phase gaussian filter
%                 In this case calib_new contains 3 or 4 numbers:
%                 [4,gain,f2,[f0]]    G(f) = exp( -((f-f0)/f2).^2 )
%                                     f0=0 if not specified
% sintr       = real row vector of sample intervals (s)
% waterlevel  = optional parameter used to stabilize the deconvolution
%               default value is 1.e-8

%OUTPUT parameters:
% header, data  :see coral
% ierr        = vector indicating which data were properly deconvolved
%             = 0 mean deconvolution is OK
%             = 3 if errors in input parameters
%
% Format of calibration array:
% Calib(1)    = normalization
% Calib(2)    = meands (gain)
% Calib(3)    = number of poles
% Calib(4:32) = complex poles
% Calib(33)   = number of zeros
% Calib(34:62)= complex zeros

header_class = class(data);

if strcmp(header_class,'struct');  % data is a structure; use methods for new data format
  
  ndata = length(data);
  sintr = [data.recSampInt]';
  if nargin~=5;
    disp('error: ''coralDeconInst'' requires 5 arguments')
    ierr = 3;
    return
  end
  header=[];
  
elseif strcmp(header_class,'double');  % header is a double; use methods for old data format

  ndata = size(header,2);
  sintr = header(6,:)'; 
  if nargin ~=6 ;
    disp('error: ''coralDeconInst'' requires 6 arguments')
    ierr = 3;
    return
  end

else
  
  disp('Error in ''coralDeconInst'': data must be a structure or double array')
  ierr=3;
  return
  
end

ierr  = zeros(ndata,1);

ierr_tmp=1;
if strcmp(class(options),'struct');  % Is input parameter a structure?
  if any(strcmp('opt',fieldnames(options))) % Does 'options' contain the field 'opt'?
    opt = options.opt;
    if strcmp(class(opt),'char');  % Is options,opt a character array?
      ierr_tmp=0;
    end
  end
end
if ierr_tmp==1;
  disp('Error in ''coralDeconInst'': fifth input argument must be a structure containing the field ''opt'' which is a character array')
  ierr=3;
  return
end
 
% The input parameters 

% calib_key == 1 it poles and zeros; else should be 3 or 4 as described above
if length(calib_new) == 62,
  calib_key = 1;                 % poles and zeros
else
  calib_key = real(calib_new(1));
end

% You can speed this up considerably by not repeating the ffts for the new (common) instrument reponse.
% to do this you need to check that the data all have the same sample interval and the
% same number of samples.  
% if sample intervals differ by more than the tolerance set below then group the data into the different rates
% and deconvolve them separately

% calculate the column vector np2 containing the next power of 2 for each of the data.
if strcmp(header_class,'struct');  % header is a structure; use methods for new data format
  np2=zeros(ndata,1);
  for idata=1:ndata
    nsamp       = length(data(idata).data);
    np2(idata)  = nextpow2(nsamp);
  end
else
    nsamp        = size(data,2);
    np2          = nextpow2(nsamp);
end

% find unique pairs of sample interval and next power of 2
sintr_tol=1e-6;                                  % sample interval tolerance (seconds)
sintr1   = round(sintr(:)/sintr_tol)*sintr_tol;  % sample intervals rounded to the nearst 'sintr_tol' seconds
[target_vals,temp,key_ind]=unique([sintr1,np2(:)],'rows');
target_sintr=target_vals(:,1);                   % unique adjusted sample intervals
target_np2  = target_vals(:,2);                  % unitue next power of two values

icount = 0;
for ikey = 1:max(key_ind);                      % loop over data sets with unique values of sample interval/np2
	nn=2^target_np2(ikey);                        % 2^(next power of 2 for FFT)
	f =make_freq(nn,target_sintr(ikey));          % define frequency vector for ffts

  key = find(key_ind == ikey);                  % key to original data for this set
	
	if calib_key==1,                              % new response in poles and zeros
      inst_new=inst_response(calib_new,1,f,[]); % frequency domain version of normalized instrument response
      meands_new=calib_new(2);                  % gain
	
	elseif calib_key == 3,                        % new response is cos taper
      meands_new=real(calib_new(2));            % gain
      f1=real(calib_new(3));f2=real(calib_new(4));
      f3=real(calib_new(5));f4=real(calib_new(6));
      inst_new=f*0;
      g=abs(f);
      i1=find(g>f1&g<f2);i2=find(g>f3&g<f4);i3=find(g>=f2&g<=f3);
      inst_new(i3)=inst_new(i3)+1;
      inst_new(i1)=0.5*(1-cos(pi*(g(i1)-f1)/(f2-f1)));
      inst_new(i2)=0.5*(1+cos(pi*(g(i2)-f3)/(f4-f3))); % frequency domain version of normalized instrument response
	
	elseif calib_key == 4,                        % new response is gausian taper
      meands_new=real(calib_new(2));            % gain
      f2=real(calib_new(3));
      if length(calib_new>3); f0=real(calib_new(4));
      else                    f0=0;
      end
      ff=(f-f0)./f2;
      inst_new=exp(-(ff.*ff));                  % frequency domain version of normalized instrument response
      
	end
	
  for i = 1:length(key);   % loop through individual seismograms
    idata=key(i);
    if strcmp(header_class,'struct');  % data is a structure; use methods for new data format
      temp_data = data(idata).data;
    else
      temp_data = data(:,idata);
    end
    n=length(temp_data);
    DATA=fft(temp_data,nn);
    skip_decon='f';
    if calib_key==1,
      if calib_old(3:62,idata) == calib_new(3:62),
%     poles and zeros are the same, so change only the gain
        skip_decon='t';
      end
    end
    if skip_decon=='f',
%   deconvolve this instrument
      icount=icount+1;
      if icount==1;  disp('Deconvolving instrument response from trace...');
      elseif mod(icount,30)==0; disp(' '); % start a new line
      else fprintf('%d ',idata); % write the station number of data being deconvolved
      end
      
      if calib_old([3,33],idata)==[0;0]; % if no poles and no zeros then old resp = 1
        temp=inst_new;
      else
        inst_old=inst_response(calib_old,idata,f,[]);
        temp1=inst_old.*conj(inst_old);
        gamma=max(temp1)*waterlevel;
        temp=inst_new.*conj(inst_old)./(temp1+gamma);
     end
      temp_data=real(ifft(DATA.*temp));
      temp_data=temp_data(1:n);
    end 
    meands_old=calib_old(2,idata);
    temp_data = temp_data*meands_new/meands_old;  
    if strcmp(header_class,'struct');  % data is a structure; use methods for new data format
      data(idata).data       = temp_data;
      data(idata).recLog     = sprintf('%s%s;',data(idata).recLog,opt);
    else
      data(:,idata) = temp_data;
    end
  end
end
return
 