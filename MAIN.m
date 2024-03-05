% Continuous Beam Problem Tools 
% Reference Paper: Research on Optimal Solutions and Algorithm Stability 
% Analyses in RC Continuous Beam Problems
% © Assoc.Prof.Dr.Hasan Tahsin ÖZTÜRK         2024

% Three different CBP problems can be optimized with the COA and SOS 
% algorithms proposed in the reference paper.

clear all
clc

addpath common_subfunctions
addpath MHS_Algorithms
addpath rebar_datapool
addpath SP_1
addpath SP_2
addpath SP_3


prompt = {'Stopping Criteria coefficient (MXFEC x Number of Design Variables) MXFEC=','Runtime ='};
dlgtitle = 'MaxFEs ve Runtime';
fieldsize = [1 70; 1 70];
definput = {'10000','21'};
answer = inputdlg(prompt,dlgtitle,fieldsize,definput);

OPTIM_DATA.MXFE_D=str2num(answer{1});
OPTIM_DATA.RT=str2num(answer{2});

msg1 = "Problem Type";
opts = ["1 SPAN CBP" "2 SPAN CBP" "3 SPAN CBP"];
prtype = menu(msg1,opts);

msg2 = "OPTIMIZATION ALGORITHM";
opts2 = ["COA" "SOS"];
opt_algo = menu(msg2,opts2);

if prtype==1
OPTIM_DATA.problem_name='1 SPAN CBP';
% Definition of Objective Function for 1 SPAN CBP
OPTIM_DATA.ObjectiveFunction = @(Design_variables) CBP_SPAN1(Design_variables);
% Definition of Design Variable Limits  for 1 SPAN CBP
[OPTIM_DATA.LB,OPTIM_DATA.UB,OPTIM_DATA.variable_type]=BOUNDS_SPAN1;
elseif prtype==2
OPTIM_DATA.problem_name='2 SPAN CBP';
% Definition of Objective Function for 2 SPAN CBP
OPTIM_DATA.ObjectiveFunction = @(Design_variables) CBP_SPAN2(Design_variables);
% Definition of Design Variable Limits  for 2 SPAN CBP
[OPTIM_DATA.LB,OPTIM_DATA.UB,OPTIM_DATA.variable_type]=BOUNDS_SPAN2;
elseif prtype==3
OPTIM_DATA.problem_name='3 SPAN CBP';
% Definition of Objective Function for 3 SPAN CBP
OPTIM_DATA.ObjectiveFunction = @(Design_variables) CBP_SPAN3(Design_variables);
% Definition of Design Variable Limits  for 3 SPAN CBP
[OPTIM_DATA.LB,OPTIM_DATA.UB,OPTIM_DATA.variable_type]=BOUNDS_SPAN3;
end

switch opt_algo
    case 1
        COA(OPTIM_DATA)
    case 2
        SOS(OPTIM_DATA)    
end

f = msgbox({'Operation Completed' ;'Please review the results from the reports in the RESULTS folder.';'Run DESIGN_VIEWER for Design Details.'},'Successfully Completed');