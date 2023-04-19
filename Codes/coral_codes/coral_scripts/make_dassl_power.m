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

[D,F]=ft_part(DATA,HEADER);  
W=2*pi*F;
Pdd=D.*conj(D)./W./W;

clf 
for i=1:3:12; 
  ii=i:i+2;
  if i==10,ii=i:i+3; end; 
  h=subplot(2,2,(i-1)/3+1);
  semilogy(1./F(:,ii),sqrt(Pdd(:,ii)));
  axis([2 16 2e4 4e6]); 
  set(h,'Xgrid','on');
  temp=setstr(Station(1:6,header1(5,ii)));title(temp(:)');
  xlabel('period (s)'); 
  ylabel('velocity amplitude'); 
end                                   
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



