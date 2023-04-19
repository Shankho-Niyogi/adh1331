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
  indx = zeros(ndata,1);
  if isfield(data,'staRespType');
    indx = find(strcmp('PZ',{data.staRespType}));
  end
  calib_old = zeros(ndata,62);
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
 
 