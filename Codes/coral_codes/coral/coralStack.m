

%Input: 
%D0   coral data structure
%opt.Group  Index for groups of data to stack: eg. opt.Group{1}=[6 3 4]; opt.Group{2}=[2 5]; opt.Group{3}=1;
%opt.absTimeField name of field within D0 that contains absolute times for alignments eg. opt.absTimeField='absPickTime';


%Output:
%D1   coral data structure of stacked data
%median of the staLat, staLon, eqLat, eqLon, eqDepth, eqStaAzim, eqStaDist, staEqAzim, 
