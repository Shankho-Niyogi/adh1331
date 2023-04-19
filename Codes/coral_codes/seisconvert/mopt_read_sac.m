function [ok,calib,comment,data,extras,loc,record,station,filenamesac,  ...
                raystuff] = mopt_read_sac(n_smat,mevent,msite,mchan, ...
                mselect,msort1,msort2,msps,mdemean,mwind,lmwind,imwind);
%function [ok,calib,comment,data,extras,loc,record,station,filenamesac,  ...
%   raystuff] = mopt_read_sac(n_smat,mevent,msite,mchan, ...
%               mselect,msort1,msort2,msps,mdemean,mwind,lmwind,imwind);
%Reads sac data into coral.
%Note mchan = 5 and 6 specify radial and transverse horizontal components
%with data rotated within this routine

global VERBOSE
mbyte_big=8;

ok=0;
if n_smat>1
   disp('MREAd requires zero input arguements, try again')
   disp('Input files are specified by commands MEVEnt MSITe MCHAn')
   disp('MSPEC determinses trace sorting, selection, sampling rate, and demeaning')
   disp('MWINd determines the time window')
   return
end
if ~length(mchan)
   disp('MREAd requires you first select channel(s) using MCHAn, try again')
   return
end
if ~length(mevent)
   disp('MREAd requires you first select an event using MEVEnt, try again')
   return
end
if ~length(msite)
   disp('MREAd requires you first select site(s) using MSITe, try again')
   return
end

% Memory is a premium for big data sets so find out how many files exist
nexpect=length(mchan)*length(msite);
mbytemax=(diff(mwind)*lmwind+7200*(~lmwind))*(msps+(~msps)*16)*8*nexpect/1e6;
if mbytemax>mbyte_big
   if VERBOSE, disp('Determining the number of SAC files'); end
   nexpect=0;
   for s=msite
     if s<10; csite=['0' int2str(s)]; else; csite=int2str(s); end
     for c=mchan
       if c=='5' | c==6
         c1='2'; c2='3';
       else
         c1=c; c2=c;
       end
       if ~mselect |  (melttracestatus(mevent,s,c1) ...
                        & melttracestatus(mevent,s,c2))
         filename1=meltfilename(mevent,s,c1);
         filename2=meltfilename(mevent,s,c2);
         if exist(filename1) & exist(filename2)
           nexpect=nexpect+1;
         end
       end
     end
   end
end
station=blanks(20)'; station=station(:,ones(nexpect,1));
loc=zeros(8,nexpect);
calib=zeros(62,nexpect);
comment=blanks(362)'; comment=comment(:,ones(nexpect,1));
record=zeros(6,nexpect);
extras=zeros(21,nexpect);
data=zeros(1,nexpect);
filenamesac=blanks(nexpect);
if VERBOSE, disp('Reading Sac files'); end

i=1;
for s=msite
   if s<10; csite=['0' int2str(s)]; else; csite=int2str(s); end
   for c=mchan
     if c=='5' | c=='6'
       c1='2'; c2='3';
     else
       c1=c; c2=c;
     end
     filename1=meltfilename(mevent,s,c1);
     if ~exist('ifp'); ifp=length(filename1); ifp=ifp-32:ifp-4; end;
     filename2=meltfilename(mevent,s,c2);
     if ~exist(filename1)
       if c1~=c2 & ~exist(filename2)
         if VERBOSE, disp([filename1(ifp) ' & ' filename2(max(ifp)) ...
             '  - No file      - Not loaded']); end
       else
         if VERBOSE, disp([filename1(ifp) '  - No file      - Not loaded']); end
       end
     end
     if ~(exist(filename1) & exist(filename2))
       ok=0;
     else
       if ~(~mselect |  (melttracestatus(mevent,s,c1) ...
                        & melttracestatus(mevent,s,c2)))
         ok=0;
         if c1==c2
           if VERBOSE, disp([filename1(ifp) '  - Visually bad - Not loaded']); end;
         else
           if VERBOSE, disp([filename1(ifp) ' & ' filename2(max(ifp)) ...
            '  - Visually bad - Not loaded or rotated']); end;
         end
       else
         [ok,stationvec,locvec,calibvec,commentvec,recordvec,extrasvec,...
            datavec,raystuffvec] = sac2coral(filename1,lmwind*imwind,mwind,1);
         if ~ok
           if VERBOSE, disp([filename1(ifp) '  - Visually bad - Not loaded']); end;
         else
           if msps              
             [datavec,recordvec]=melttraceresample(datavec,recordvec,msps,0);
           end
           if c1==c2 & mdemean;
             datavec=demean(datavec);
             recordvec(5)=max(datavec);
           end
         end
         if c1~=c2
           [ok2,stationvec2,locvec2,calibvec2,commentvec2,recordvec2, ...
             extrasvec2,datavec2,raystuffvec2] = sac2coral(filename2, ...
                                                lmwind*imwind,mwind,1);
           if ok2 & msps;        
             [datavec2,recordvec2]=melttraceresample(datavec2,recordvec2,msps,0);
           end
           if ok & ok2
             [ok,datarot]=meltrotate([datavec datavec2], ...
                 [recordvec recordvec2],[locvec locvec2], ...
                 [stationvec stationvec2]);
             if ok
               if mdemean
                 datarot=demean(datarot);
               end
               stationrot=[stationvec stationvec2];
               locrot=[locvec locvec2];
               calibrot=[calibvec calibvec2];
               commentrot=[commentvec commentvec2];
               recordrot=[recordvec recordvec2];
               extrasrot=[extrasvec extrasvec2];
               raystuffrot=[raystuffvec raystuffvec2];
               stationrot(7:12,1)=['R Rot1']';
               stationrot(7:12,2)=['T Rot2']';
               commentrot(33:38,1)=['R Rot1']';
               commentrot(33:38,2)=['T Rot2']';
               recordrot(5,:)=max(datarot);
               filenamerot=[blanks(length(filename1)); blanks(length(filename1))];
               filenamerot(1,1:9)='Rotated 1';
               filenamerot(2,1:9)='Rotated 2';
               filenamerot=filenamerot';
             else
               if VERBOSE, disp([filename1(ifp) ' & ' ...
                  filename2(max(ifp)) ' - Rotation failed']); end;
             end
           else
             ok=0;
             if VERBOSE, disp([filename1(ifp) ' & ' filename2(max(ifp)) ...
                '  - Bad SAC file(s) - Not loaded or rotated']); end;
           end
         end
       end
     end
     if ok
       if c=='5'
         stationvec=stationrot(:,1);
         locvec=locrot(:,1);
         calibvec=calibrot(:,1);
         commentvec=commentrot(:,1);
         recordvec=recordvec(:,1);
         extrasvec=extrasrot(:,1);
         datavec=datarot(:,1);
         raystuffvec=raystuffrot(:,1);
         filename=filenamerot(:,1)';
       elseif c=='6'
         stationvec=stationrot(:,2);
         locvec=locrot(:,2);
         calibvec=calibrot(:,2);
         commentvec=commentrot(:,2);
         recordvec=recordrot(:,2);
         extrasvec=extrasrot(:,2);
         datavec=datarot(:,2);
         raystuffvec=raystuffrot(:,2);
         filename=filenamerot(:,2)';
       else
         filename=filename1;
       end
       if i==1
         if mbytemax>mbyte_big
           mbyte=nexpect*length(datavec)*8/1e6;
           if VERBOSE, disp(['Assigning ' num2str(mbyte) ' MByte for data matrix']); end
         end
       end
       station(:,i)=stationvec;
       loc(:,i)=locvec;
       calib(1:length(calibvec),i)=calibvec;
       comment(1:length(commentvec),i)=commentvec;
       record(:,i)=recordvec;
       extras(1:length(extrasvec),i)=extrasvec;
       data(1:length(datavec),i)=datavec;
       filenamesac(1:length(filename),i)=filename';
       raystuff(1:4,i)=raystuffvec;
       i=i+1;
       if c1==c2;
         if VERBOSE, disp([filename(ifp) '      - loaded']); end
       else
         if VERBOSE, disp([filename1(ifp) ' & ' filename2(max(ifp))  ...
                '  - Successfully loaded and rotated']); end
       end
     end
   end
end
if i==1
   disp('MREAd has not found any data, try again')
   clear station loc calib comment record extras data
   return
else
   i=i-1;
   if i<nexpect
     if VERBOSE, disp('Fewer seismograms than maximum - Fixing matricies'); end;
     if mbytemax>mbyte_big
       keyboard
     end
     station=station(:,1:i);
     loc=loc(:,1:i);
     calib=calib(:,1:i);
     comment=comment(:,1:i);
     record=record(:,1:i);
     extras=extras(:,1:i);
     data=data(:,1:i);
     filenamesac=filenamesac(:,1:i);
   elseif i>nexpect
     disp('More seismograms than expected - May have slowed code')
     keyboard
   end
   if (max(loc(7,:))-min(loc(7,:))+max(loc(8,:))-min(loc(8,:))) > 0
     disp('Warning - Event times differ and will not be fixed');
%@BH 5/15/97 - some output lines to go with this warning.
%    if VERBOSE
% dates
%       format long;
%       disp('Dates:');
%       dt=sort(uniq_num(loc(7,:)));
%       dt=[dt  zeros(length(dt),1)];
%       for ids = 1:length(dt)
%          idscnt=length(find(loc(7,:)==dt(ids)));
%          dt(ids,2) = idscnt;
%       end;
%       dt
%       disp('Times:');
%       dt=sort(uniq_num(loc(8,:)));
%       dt=[dt  zeros(length(dt),1)];
%       for ids = 1:length(dt)
%          idscnt=length(find(loc(8,:)==dt(ids)));
%          dt(ids,2) = idscnt;
%       end;
%       dt
%       format short;
% times
%    end
% END stuff added by bill
%    keyboard
%@BH 5/15/97 - end changes
   end
end

[calib,comment,data,extras,loc,record,station,filenamesac,raystuff] ...
    =meltsorttrace(msort1,msort2,calib,comment,data,extras, ...
                   loc,record,station,filenamesac,raystuff);
ok=1;