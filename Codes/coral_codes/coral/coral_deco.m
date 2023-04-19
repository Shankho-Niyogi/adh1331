function [data1,err]=coral_deco(opt,data1,header1,Calib); 
%   coral_deco    frequency-domain instrument response deconvolution
% usage: [data1,err]=coral_deco(opt,data1,header1,Calib); 
% see help for script 'coral' for documentation of this routine

% set defaults
commands = ['from';'to  ';'wl  ';'gain';'cos ';'gaus'];
from='i';
to  ='d';   to_is_num='f';
wl  = 1e-6;
gain= 1;
cosf= [];
gaus= [];
err=0;
[str,n]=cut_string(opt);
str=[str,blanks(n)'];
[n,m]=size(str);
i=2;
while i<=n
  command=str(i,1:4);
  k=strcmp2(command,commands);
  if k==0,
    disp([' command ' command ' not recognized --retry'])
    err=1
    break
  end
  if    k==1, % command is 'from'
    if i+1>n,  
      err=2; break;
    else 
      from=str(i+1,1); 
      if ~findstr(from,'inIN'),
        disp(' deco from must have an argument of i or n')
        err=3, break
      end
    end
    i=i+2;
  elseif k==2, % command is 'to'
    if i+1>n,  
      err=2; break;
    else 
      to=str(i+1,1);
      if ~findstr(to,'slirvdan'),
        [to,count,ERRMSG]=sscanf(str(i+1,:),'%d');
        if length(ERRMSG)~=0,
          disp(' deco to must have an argument of l s i r v d a n or an integer')
          err=3, break
        else 
          to_is_num='t';
        end
      end
    end
    i=i+2;
  elseif k==3, % command is 'wl'
    if i+1>n,  
      err=2; break;
    else 
      [wl,count,ERRMSG]=sscanf(str(i+1,:),'%f');
      if length(ERRMSG)~=0,
        disp(' deco wl must have one argument that is a number')
        err=3, break
       end
    end
    i=i+2;
  elseif k==4, % command is gain
    if i+1>n,  
      err=2; break;
    else 
      [gain,count,ERRMSG]=sscanf(str(i+1,:),'%f');
      if length(ERRMSG)~=0,
        disp(' deco gain must have one argument that is a number')
        err=3, break
       end
    end
    i=i+2;
  elseif k==5, % command is cos 
    if i+4>n,
      err=2; break;
    else
      [cosf,count,ERRMSG]=sscanf(str(i+1:i+4,:)','%f');
      if length(ERRMSG)~=0,
        disp(' deco gain must have one argument that is a number')
        err=3, break
      end
    end
    i=i+5;
  elseif k==6, % command is gaus
    if i+2>n,
      err=2; break;
    else
      [gaus,count,ERRMSG]=sscanf(str(i+1:i+2,:)','%f');
      if length(ERRMSG)~=0,
        disp(' deco gaus must have two arguments that are numbers')
        err=3, return
       end
    end
    i=i+3;
  end
end

if err==0, 
  w_index=header1(5,:);
  sintr1=header1(6,:); 
  key=1:length(w_index);
  calib_old=Calib(:,w_index);

  calib_new=[];

%  if to is a number or one of  slri  then calib_new is described as pole-zeros
%  and no other frequency filters are applied.  

  if to_is_num=='t';
    if to<=length(w_index)
      calib_new=calib_old(:,to);
    else
      disp(' error in deco to integer where integer is too big')
      err=3;
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
      calib_old=conv_response(calib_old,'d',to,1,key);
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
    err=4;
    return
  else
    if from == 'n';
      calib_old=calib_old*0;
      calib_old(1:2,:)=calib_old(1:2,:)+1;
    end
  end
  
  if err==0,
    data1=decon_inst(data1,calib_old,calib_new,sintr1,key,wl)/gain;
  end
end

