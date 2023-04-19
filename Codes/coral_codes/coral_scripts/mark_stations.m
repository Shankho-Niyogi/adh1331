disp('press any mouse button to mark a trace with a cross')
disp('unmark it by pressing the mouse button again')
disp('when done press return to delete all marked traces')
disp('or ''k'' to keep only marked traces, or')
disp('any other key to quit and not do anything with marked traces')
hold on
Ndata=length(data1(1,:));
timeshift=zeros(Ndata,1) ;
marked  =timeshift;
bbb=0;
while bbb <4,
   [xxx,yyy,bbb]=ginput(1)
   if bbb~=13,
     iii=round(yyy);
     if marked(iii)==0,      % if not selected, then select it
       timeshift(iii)=xxx;
       marked(iii)=1;
       h_plot1=plot(timeshift(iii),iii,'+','MarkerSize',20,'Erase','xor');   
     else,                   % if selected then unselect it
       h_plot1=plot(timeshift(iii),iii,'+','MarkerSize',20,'Erase','xor');   
       marked(iii)=0;
     end
  end
end
hold off
marked    
if bbb==13 | bbb==abs('k'),
  if bbb==13,
    index=find(marked==0)';
  else
    index=find(marked~=0)';
  end
  Tdur=header1(2,:);
  window=[index*0;Tdur(index);index];
  [data1,header1,label1,obs1]=apply_window(data1,header1,label1,obs1,window);
end

