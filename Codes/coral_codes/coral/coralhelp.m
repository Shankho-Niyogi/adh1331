function coralhelp(help_file,command);
%   coralhelp     help for coral using helpwin
% USAGE: coralhelp(help_file,command);
% help_file='/u0/iris/MATLAB/coral/coral.man';
% in the help file * should precede each command
% command is a character string that contains command of interest
% if command=[]; a list of commands is displayed

% read coral.man 
str=['fid=fopen(''' help_file ''',''r'');b=fscanf(fid,''%c'');fclose(fid);'];
eval (str);
c=findstr('*',b)'+1;                                % find *s which delimit command names
e=b([c,c+1,c+2,c+3]);                               % get index for 4 characters past *s

% find all real commands

k=find(e(:,1)~='#');
N=length(k)-1;
str1 = cell(N,2);   % str1 is an Nx2  cell array containing pairs of command names and their documentation
for i=1:N; str1{i,1} = e(k(i),:); str1{i,2}=b(c(k(i)):c(k(i)+1)-2); end

L=length(command);

if L==0;                            % write just  the names of commands
  helpwin(e,'', 'command names for Coral'); 
else;                               % write documentation for desired command
  if L>4, command=command(1:4);
  elseif L<4, command=[command blanks(4-L)];
  end
  i=strcmp2(upper(command),upper(e));
  if i==0, 
    disp(['command ' command ' not found--retry'])
  end
  if i<25;            % find desired command and point to first or second half of all commands
	                 % helpwin is not smart enough to show all the comands
    helpwin(str1,upper(command),'Coral commands (first half)')
  else
    helpwin(str1(20:end,:),upper(command),'Coral commands (second half)')
  end
  
end
