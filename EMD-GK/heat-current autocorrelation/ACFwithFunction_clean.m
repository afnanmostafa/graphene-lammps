%%% Afnan Mostafa
%%% 06/08/2021
%%% This code uses 'J0Jt.data' file dumped from LAMMPS to plot the
%%% heat-current auto-correlation function (HCACF or HACF or ACF)
%%% w.r.to time or lag.
clear
clc

%% %% SECTION: getting the total number of lines/rows in data file %% %%
fid = fopen('J0Jt.data');
count = 0;
while true
  if ~ischar(fgetl(fid)); break; end
  count = count + 1;
end
fclose(fid);
hold on
%% %% SECTION: getting user-inputs for autocorrelation parameters %% %%
Nevery=3500; 
Nrepeat=100; 
total_runtime=27300000;
timestep_size=0.0001;
time_in_step=total_runtime*timestep_size;
time=time_in_step/(1e3); 

%% %% SECTION: calling the function %% %%
[z,timestep,intervals] = autocorrfunc(Nrepeat,Nevery,time,count,total_runtime);

%% %% SECTION: plotting ACF w.r.to time (CUSTOM) %% %%
acf=autocorr(double(z),'NumLags',intervals);
plot(timestep, acf,'-r','LineWidth',2)
xlabel('Time (ns)','FontSize', 18)
ylabel('HCACF','FontSize', 18)
grid on
title(sprintf('EMD, dt=0.1fs, s=%d, p=%d',Nevery, Nrepeat),'FontSize', 15)
set(gca,'FontSize',16)

%% %% SECTION: function to get correlated values (z) %% %%
function [z,timestep,intervals] = autocorrfunc(Nrepeat,Nevery, time,count,total_runtime)

j=4:Nrepeat+1:count-Nrepeat;   

intervals = (total_runtime)/(Nrepeat*Nevery); 
timestep=0:time/(intervals):time;
timestep=timestep';

p = cell(1,intervals+1);                                      
q = cell(1,intervals+1);         
r = cell(1,intervals+1);        
                               
%% %% SECTION: accessing data file %% %% 

for i=1:intervals+1
    fid = fopen('J0Jt.data');   
    s = textscan(fid,'%f %f %f %f %f %f',Nrepeat,'headerlines',j(i));
    fclose(fid);                
    
    a=s{1,4};                       
    p{1,i}=a;
    b=s{1,5};                  
    q{1,i}=b;
    c=s{1,6};                   
    r{1,i}=c;
end

%% %% SECTION: adding Jxx Jyy Jzz for ACF %% %%
z=zeros(intervals+1,1);                 
for k=1:intervals+1
    c = p{1,k}+q{1,k}+r{1,k};         
    %c = c/(p{1}(1)+q{1}(1)+r{1}(1)); %normalization             
    z(k,1) = mean(c);                   
                      
end
end
