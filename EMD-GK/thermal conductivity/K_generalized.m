%%% Afnan Mostafa
%%% 06/11/2021
%%% This code uses log.lammps file dumped from LAMMPS to extract the
%%% thermodyamics of the system (dumped via "thermo" command)
%%% HEADS-UP: either SECTION 1.1 or 1.2 to be used
clear
clc

%% %% SECTION 1.1: getting user-inputs for correlation parameters %% %%
Nevery=3500;    %s (sampling interval)           %hard-coding the value
Nrepeat=100;  %p (correlation data points)     %hard-coding the value
total_runtime=52500000;
timestep_size=0.0001;
time_in_step=total_runtime*timestep_size;
time=time_in_step/(1e3);  %total runtime in ns from ps (metal units)
ensembles=4;        %how many ensemble-driven equilibration is performed to 
                    %attain stability (in my case, it was NPT and NVE
%%%or,
%% SECTION 1.2: getting user-inputs for correlation parameters %% %%
%%%user-inputs
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
% prompt5 = 'How many ensemble runs did you do for equilibration? ';
% ensembles = input(prompt5);

%% %% SECTION 2: reading the data file to get the starting point of data 
%(ending of command lines)%% %%
A = regexp(fileread('log.lammps'),'\n','split');
whichline = find(contains(A,'Step')); %every data section starts with 
                                      %'Step ...' and thus, 2 equilibration
                                      %ensembles and final run = 3 data 
                                      %sections with 'Step .....'
final_headerline = whichline(ensembles+1); %we need the final one for k;
                                           %the earlier 2 can be used for
                                           %plotting equilibration curves
                                           %like Energy Vs time or Pressure
                                           %vs Time and so on

%% %% SECTION 3: reading the data section of the interest %% %%
fid = fopen('log.lammps');
s = textscan(fid,'%f %f %f %f %f %f %f %f %f %f %f %f %f %f', 'headerlines', final_headerline);
fclose(fid);

%% %% SECTION 4: getting all the lines of the whole data file %% %%
fid = fopen('log.lammps');
tline = fgetl(fid);
tlines = cell(0,1);

while ischar(tline)
    disp(tline);
    tlines{end+1,1} = tline;   %listing each line as a separate array
    tline = fgetl(fid);
end
% split(tlines(whichline(1)))
fclose(fid);

%% %% SECTION 5: identifying k values (kxx, kyy, kzz, k) from the file %% %%
str = tlines(final_headerline);
str = split(str);
k_values = ["v_k11", "v_k22", "v_k33", "v_k"];
indices = zeros(4,1);
for i=1:4
    isK = cellfun(@(x)isequal(x,k_values(i)),str);
    [row, col] = find(isK);
    indices(i) = row;
end

%% %% SECTION 6: storing identified k values into variables and setting 
%timestep size %% %%
kx=s{1,indices(1)};
ky=s{1,indices(2)};
kz=s{1,indices(3)};
k=s{1,indices(4)};
intervals= (total_runtime)/(Nrepeat*Nevery); %time(ns) is multiplied by 10^6 
                                        %to get the runtime (10ns=10,000000 
                                        %steps) for 'metal' units
timestep=0:time/(intervals):time;
timestep=timestep';
kx = kx(1:2:end);
ky = ky(1:2:end);
kz = kz(1:2:end);
k = k(1:2:end);
%% %% SECTION 7: plotting k vs time graph %% %%
set(gca,'FontSize',16)
plot(timestep, kx,'-.b','LineWidth', 2)
hold on
grid on
ax = gca;
ax.FontSize = 18;
plot(timestep, ky,'-.c','LineWidth', 2)
plot(timestep, kz,'-.g','LineWidth', 2)
plot(timestep, k,'-.r','LineWidth', 2)
legend('kx', 'ky', 'kz', 'k','FontSize', 20);
title(sprintf('10x10 EMD, dt=0.2fs, s=%d, p=%d',Nevery, Nrepeat),'FontSize', 15)
xlabel('Time (ns)','FontSize', 18)
ylabel('k (W/m-K)','FontSize', 18)