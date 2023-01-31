%%% Afnan Mostafa
%%% 06/11/2021
%%% This code uses log.lammps file dumped from LAMMPS to extract the
%%% thermodyamics of the system (dumped via "thermo" command)
%%% Heads-up: Only 8 SECTIONS 1,2,3,(either 4 or 5),6.1, 6.2, 
%%%6.3(either 6.3.1 or 6.3.2) and 6.3.3 (JUST IGNORE! I OVERCOMPLICATE
%%%THINGS! SIGH!!!!

clear
clc

%% %% SECTION 1: getting user-inputs for autocorrelation parameters %% %%
Nevery=1000; %s (sampling interval)           %hard-coding the value
Nrepeat=1000; %p (correlation data points)     %hard-coding the value
time=10;
ensembles=2;
%or,
%user-inputs
% prompt1 = 'What is the value of sampling interval, Nevery? ';
% Nevery = input(prompt1);
% prompt2 = 'What is the value of correlation data points, Nrepeat? ';
% Nrepeat = input(prompt2);
% prompt3 = 'What is the total runtime in ns? ';
% time = input(prompt3);
% prompt4 = 'How many ensemble runs did you do for equilibration? ';
% ensembles = input(prompt4);

%% %% SECTION 2: %% %%
A = regexp(fileread('log.lammps'),'\n','split');
whichline = find(contains(A,'Step'));
headerline = whichline(ensembles+1);


%% %% SECTION 3:  %% %%
fid = fopen('log.lammps');
s = textscan(fid,'%f %f %f %f %f %f %f %f %f %f %f %f %f %f', 'headerlines', headerline);
fclose(fid);

fid = fopen('log.lammps');
tline = fgetl(fid);
tlines = cell(0,1);
while ischar(tline)
    disp(tline);
    tlines{end+1,1} = tline;
    tline = fgetl(fid);
end
str = tlines(headerline);
str = split(str);

isKxx = cellfun(@(x)isequal(x,'v_k11'),str);
[row_kxx] = find(isKxx);
isKyy = cellfun(@(x)isequal(x,'v_k22'),str);
[row_kyy] = find(isKyy);
isKzz = cellfun(@(x)isequal(x,'v_k33'),str);
[row_kzz] = find(isKzz);
isK = cellfun(@(x)isequal(x,'v_k'),str);
[row_k] = find(isK);
fclose(fid);

kx=s{1,row_kxx};
ky=s{1,row_kyy};
kz=s{1,row_kzz};
k=s{1,row_k};

intervals= (time*1e6)/(Nrepeat*Nevery);
timestep=0:time/(intervals):time;
timestep=timestep'


set(gca,'FontSize',16)
plot(timestep, kx,'b','LineWidth', 2)
hold on
grid on
ax = gca;
ax.FontSize = 18;
plot(timestep, ky,'c','LineWidth', 2)
plot(timestep, kz,'g','LineWidth', 2)
plot(timestep, k,'r','LineWidth', 2)
legend('kx', 'ky', 'kz', 'k','FontSize', 20);
title('10x10 EMD, dt=0.2fs, s=100, p=1000','FontSize', 15)
xlabel('Time (ns)','FontSize', 18)
ylabel('k (W/m-K)','FontSize', 18)
% yyaxis right;
% plot(time, kx,'b','LineWidth', 2)
% plot(time, ky,'c','LineWidth', 2)
% plot(time, kz,'g','LineWidth', 2)
% plot(time, k,'r','LineWidth', 2)