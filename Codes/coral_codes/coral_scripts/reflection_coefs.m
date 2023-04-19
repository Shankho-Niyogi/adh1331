format compact
disp('SH at surface and CMB:  Rss=1; Tss=0')
disp(' ')
disp('P-SV reflection/transmissions coefficients to first order in p')
disp('all mixed modes (P->S and S->P conversions should be multiplied by p)')
disp('matrices are ordered as [pp ps ; sp ss]')
disp(' ')
disp('Free surface')
r=6371-.01;
[a1,b1,r1]=prem(r+.01); 
Rpp=-1;
Rps=4*b1;
Rsp=4*b1*b1/a1;
Rss=-1;
R=[Rpp Rps; Rsp Rss]


for i=1:2
  if i==1;
    % CMB incident from above (solid):
    disp(' ')
    disp('CMB down')
    r=3480; 
    [a1,b1,r1]=prem(r+.01); 
    [a2,b2,r2]=prem(r-.01);
  elseif i==2;
    % ICB incident from below (solid):
    disp(' ')
    disp('ICB up')
    r=1221.5;
    [a1,b1,r1]=prem(r-.01); 
    [a2,b2,r2]=prem(r+.01);
  end

  I1=r1*a1;  J1=r1*b1;
  I2=r2*a2;  J2=r2*b2;

  Rpp = (I2-I1)/(I2+I1);
  Rps = 4*J1*a1/(I1+I2);
  Tpp = 2*I1/(I1+I2);
  Rss = 1;
  Rsp = 4*J1*b1/(I1+I2);
  Tsp = -4*J1*b1/(I1+I2);
  R=[Rpp Rps; Rsp Rss]
  T=[Tpp 0  ; Tsp 0  ]
end


for i=1:2
  if i==1;
    % CMB incident from below (fluid):
    disp(' ')
    disp('CMB up')
    r=3480; 
    [a1,b1,r1]=prem(r-.01); 
    [a2,b2,r2]=prem(r+.01);
  elseif i==2;
    % ICB incident from above (fluid):
    disp(' ')
    disp('ICB down')
    r=1221.5;
    [a1,b1,r1]=prem(r+.01); 
    [a2,b2,r2]=prem(r-.01);
  end

  I1=r1*a1;  J1=r1*b1;
  I2=r2*a2;  J2=r2*b2;

  Rpp = (I2-I1)/(I2+I1);
  Tpp = 2*I1/(I1+I2);
  Tps = -4*b2*I1/(I1+I2);
  R=Rpp
  T=[Tpp Tps; 0   0  ]
end



