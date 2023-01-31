%%% Afnan Mostafa
%%% 06/08/2021
%%% This code uses 'J0Jt.data' file dumped from LAMMPS to plot the
%%% heat-current auto-correlation function (HCACF or HACF or ACF)
%%% w.r.to time or lag
%%% Heads-up: Only 8 SECTIONS 1,2,3,(either 4 or 5),6.1, 6.2, 
%%%6.3(either 6.3.1 or 6.3.2) and 6.3.3 (JUST IGNORE! I OVERCOMPLICATE
%%%THINGS! SIGH!!!!

% clear
% clc

%% %% SECTION 1: getting the total number of lines/rows in data file %% %%
fid = fopen('J0Jt.data');
count = 0;
while true
  if ~ischar(fgetl(fid)); break; end
  count = count + 1;
end
fclose(fid);
hold on
%% %% SECTION 2: getting user-inputs for autocorrelation parameters %% %%
Nevery=3500; %s (sampling interval)           %hard-coding the value
Nrepeat=100; %p (correlation data points)     %hard-coding the value
total_runtime=27300000;
timestep_size=0.0001;
time_in_step=total_runtime*timestep_size;
time=time_in_step/(1e3); 

%or,
%user-inputs
% prompt1 = 'What is the value of sampling interval, Nevery? ';
% Nevery = input(prompt1);
% prompt2 = 'What is the value of correlation data points, Nrepeat? ';
% Nrepeat = input(prompt2);
% prompt3 = 'What is the total runtime steps? ';
% total_runtime = input(prompt3);
% prompt4 = 'What is the timestep size in picoseconds? ';
% timestep_size = input(prompt4);
% time_in_step=total_runtime*timestep_size;
% time=time_in_step/(1e3);

%% %% SECTION 3: calling the function %% %%
[z,timestep,intervals] = autocorrfunc(Nrepeat,Nevery,time,count,total_runtime);




%% %% SECTION 4: built-in ACF plot with time lags %% %%
% autocorr(double(z),'NumLags',Nrepeat)
% 
% set(gca,'FontSize',16)
% ylabel('HCACF')
% xlabel('Time (ns)','FontSize', 18)
% title(sprintf('10x10 EMD, dt=0.2fs, s=%d, p=%d',Nevery, Nrepeat),'FontSize', 13)

%% %% SECTION 5: plotting ACF w.r.to time (CUSTOM) %% %%
acf=autocorr(double(z),'NumLags',intervals);

%%%% animation
% h = animatedline;
%     a=tic;
%     for j = 1:length(timestep)
%         addpoints(h,timestep(j),acf(j));
%         b = toc(a); % check timer
%         if b < (1/3)
%             drawnow % update screen every 1/30 seconds
%             a = tic; % reset timer after updating
%         end
%     end
   
%%%%
plot(timestep, acf,'-r','LineWidth',2)
xlabel('Time (ns)','FontSize', 18)
ylabel('HCACF','FontSize', 18)
grid on
title(sprintf('EMD, dt=0.1fs, s=%d, p=%d',Nevery, Nrepeat),'FontSize', 15)
set(gca,'FontSize',16)
% axis square

%for roght y-axis (CAN IGNORE THE FOLLOWING)
% yyaxis right
% plot(timestep, acf)

%% %% SECTION 6: function to get correlated values (z) %% %%
function [z,timestep,intervals] = autocorrfunc(Nrepeat,Nevery, time,count,total_runtime)
%% %% SECTION:6.1 setting autocorrelation parameters %% %%
j=4:Nrepeat+1:count-Nrepeat;   %list of numbers representing headerlines

intervals = (total_runtime)/(Nrepeat*Nevery); 
timestep=0:time/(intervals):time;
timestep=timestep';

p = cell(1,intervals+1);       %creating empty cell to store Jxx values 
                               %%at timesteps multiples of Nevery*Nrepeat, 
                               %%(0,500000,1000000,....,50000000)(for
                               %%50ns), 0 to 101st or (Nrepeat+1)st point 
                               
q = cell(1,intervals+1);         %same as above for Jyy
r = cell(1,intervals+1);         %same as above for Jzz
                               
%% %% SECTION 6.2: accessing data file %% %% 
%At each iteration, the file is read and "Nrepeat" data points are
%extracted for Jxx, Jyy, Jzz. Headerlines are non-numeric data/unnecessary
%data for ACF. To exemplify, after 1st iteration, the headerline moves from
%"4" to "4+Nrepeat+1" or (4+101) so that it does not consider the values
%from previous iteration and can regard total 105 lines as headerlines for 
%2nd iteration. For 3rd, headerlines will be 105+Nrepeat+1 (105+101=206) 
%and it again disregards the J values of the first 2 iterations. Data from 
%each iteration is stored at different columns of the CELL. "click on p/q/r
%on the right side to see for yourself."

for i=1:intervals+1
    fid = fopen('J0Jt.data');   %opening file
    s = textscan(fid,'%f %f %f %f %f %f',Nrepeat,'headerlines',j(i));
    fclose(fid);                %closing file
    
    a=s{1,4};                   %getting forth column of s --> Jxx     
    p{1,i}=a;
    b=s{1,5};                   %getting fifth column of s --> Jyy
    q{1,i}=b;
    c=s{1,6};                   %getting sixth column of s --> Jzz
    r{1,i}=c;
end

%% %% SECTION 6.3: adding Jxx Jyy Jzz for ACF %% %%
z=zeros(intervals+1,1);                 %vector created to store ACF values
for k=1:intervals+1
    %SECTION 6.3.1: normal addition of Jxx Jyy Jzz
    c = p{1,k}+q{1,k}+r{1,k};         %adding 4th 5th and 6th column of s
    %c = c/(p{1}(1)+q{1}(1)+r{1}(1)); %normalization for normalized ACF
                          
    %% SECTION 6.3.2: Vector addition of Jxx Jyy Jzz  "SKIP THIS SECTION 5.2"
    % Not required but an option- I was unsure of how to add heat flux
    %     c = p{1,k};
    %     d = q{1,k};
    %     e = r{1,k};
    %     c=c.^2;
    %     d=d.^2;
    %     e=e.^2;
    %     f=sqrt(c+d+e);                    "CONTINUE FROM BELOW THIS LINE"
                                            
    %% SECTION 6.3.3
    z(k,1) = mean(c);                   %getting the mean of correlated 
                                        %points to store J value for 
                                        %each timestep
                                   
end
end
