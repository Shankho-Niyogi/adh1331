opt1.pre_match = {'staNetworkCode', 'staCode', 'staChannel', 'staLocationCode'}; opt1.plot_duplicates=1;
[Dnew, results, problem,problem_summary] = coralUnique(D,opt1);
if results(2)<results(1);
  if length(Dnew)<length(D);
    keyboard
  else
    for k=1:length(problem_summary);
      indx=problem_summary(k).indx;
      Dprob=D(indx);
      delta=delaz([Dprob.staLat],[Dprob.staLon],[Dprob.eqLat],[Dprob.eqLon],0);
      T=get_ttt(phase,Dprob(1).eqDepth,delta(:)','iasp91');

      [recStartTime, recStartSampleI, recEndSampleI, recStartSampleErr, recStartTimeDiff, recEndTimeDiff]=...
        coralGetTimes(Dprob, Dprob(1).eqOriginTime);
      recStartTimeDiff = recStartTimeDiff - T';
      recEndTimeDiff = recEndTimeDiff -T';
      indx_g=find(recStartTimeDiff<=0 & recEndTimeDiff>=0);
      problem_summary(k).goodindx=indx(indx_g)';
      indx_b=find(recStartTimeDiff>0 | recEndTimeDiff<0);
      problem_summary(k).badindx=indx(indx_b)';
      problem_summary(k).numgood=length(problem_summary(k).goodindx);
      disp(problem_summary(k))
    end

    badindx = [problem_summary.badindx];
    if length(badindx)>0;
      indx = ones(size(D));
      indx(badindx)=0;
      D=D(find(indx));
    end

    disp([problem_summary.badindx])
    disp([problem_summary.goodindx])
  end
end
