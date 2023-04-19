p=[];
p(1)=-beta*w0 + i*w0*sqrt(1-beta*beta); p(2)=conj(p(1));
p(3)= -406.55 + i*1517.27;              p(4)=conj(p(3));
p(5)=-1110.72 + i*1110.72;              p(6)=conj(p(5));
p(7)=-1517.22 + i*406.55 ;              p(8)=conj(p(7));
z(1)=0;z(2)=0;
f0=.05;

a0=abs(prod(p+f0*2*pi*i)/prod(z+f0*2*pi*i))


format bank ;for kdep=1:(length(map3)-1) ; ind=[map3(kdep,kphs)+1:map3(kdep+1,kphs)]; 
t=bc(ind,7); d=bc(ind,1); n=length(ind); 
t(n)=t(n-1) + (t(n-1)-t(n-2)) / (d(n-1)-d(n-2)) * (d(n)-d(n-1));  bc(ind,7)=t; end
