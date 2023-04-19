if exist('view_no')~=1,
  view_no=1;
end
if view_no>=1 & view_no<=3,
  eval(['HEADER=header' num2str(view_no) ';']);
  eval(['DATA=data' num2str(view_no) ';']);
elseif view_no==0,
  eval('HEADER=Header;');
  eval('DATA=Data;');
else
  disp('retry: view_no must be 0, 1, or 2');
  return
end

% current_directory=pwd; cd /u0/kcc/matlab/class ; mode_freqs ; eval(['cd ' current_directory])


[D,F]=ft_part(DATA,HEADER);  
W=2*pi*F;
Pdd=D.*conj(D)./W./W;
loglog(F,Pdd)
return
ii=25:205;
for jj=1:15; 
  FF=F(ii,jj); PP=Pdd(ii,jj);maxPP=max(PP);
  plot(FF,PP,T(:,3)/1000,(T(:,1)+2)*max(PP)/8,'.','marker',10);
  xlabel('frequency (Hz)')
  %axis([.001 .004 0 maxPP]);
  pause;
end

%clear HEADER D,N_INDEX OUTPUT OUTPUT1 AMAT



