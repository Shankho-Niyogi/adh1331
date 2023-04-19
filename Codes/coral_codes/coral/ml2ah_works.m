SS=setstr(Station_out);
ORIG_TIME=time_reformat(Loc_out(7:8,:));
START_TIME=time_reformat(Loc_out(1:2,:));
[fid,fmessage]=fopen('test.out','w')
i=1;
sprintf('%s','station information')
sprintf('%s\t %s','code:', SS(1:5,i))
sprintf('%s\t %s','channel:', SS(7:10,i))
sprintf('%s\t %s','type:', SS(14:20,i))
sprintf('%s\t %f','latitude:',  Loc_out(1,i))
sprintf('%s\t %f','longitude:', Loc_out(2,i))
sprintf('%s\t %f','elevation:', Loc_out(3,i))
 
sprintf('%s\t %f','gain:',         Calib(2,i))
sprintf('%s\t %f','normalization:', Calib(1,i))
sprintf('%s','calibration information')
sprintf('%s\t %s\t %s\t %s','pole.re','pole.im','zero.re','zero.im')
sprintf('%f\t %f\t %f\t %f', real(Calib(3,i)), 0, real(Calib(33,i)), 0)
for j=4:32
  sprintf('%f\t %f\t %f\t %f', real(Calib(j,i)), imag(Calib(j,i)), real(Calib(j+30,i)), imag(Calib(j+30,i)))
end
sprintf('%s','event information')
sprintf('%s\t %f','latitude:',  Loc_out(4,i))
sprintf('%s\t %f','longitude:', Loc_out(5,i))
sprintf('%s\t %f','elevation:', Loc_out(6,i))
sprintf('%s\t %d\t %d\t %d\t %d\t %d\t %10.5f','origin_time:',ORIG_TIME(:,i))
sprintf('%s\t %s','comment:','null')
sprintf('%s','record information')
sprintf('%s\t %d','type:',  1)
sprintf('%s\t %d','ndata:', Record_out(3,i))
sprintf('%s\t %d','delta:', Record_out(4,i))
sprintf('%s\t %f','max_amplitude:', Record_out(5,i))
sprintf('%s\t %d\t %d\t %d\t %d\t %d\t %10.5f','start_time:',START_TIME(:,i))
sprintf('%s\t %f','abscissa_min:', Record_out(6,i))
sprintf('%s\t %s','comment:','null')
sprintf('%s\t %s','log:','null')

sprintf('%s','extras:')
for j=1:21
  sprintf('%d:\t %f',i-1,Extras_out(j,i) )
end

sprintf('%s','data:')
sprintf('%f\n',Data_out(1:Record_out(3,i),i))

fclose(fid)
!more test.out
