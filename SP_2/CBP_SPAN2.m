function [CIKIS]=CBP_SPAN2(Foodsi)
% CBP with two span
% © Assoc.Prof.Dr.Hasan Tahsin ÖZTÜRK         2024
% Please refer to the article titled "Research on Optimal Solutions and 
% Algorithm Stability Analyses in RC Continuous Beam Problems" for details.

% Reading Design Parameters and Data Pool
[TP]=DP_SPAN2;

% Assignment of Design Variables
PRM.ASALUST_DONATI_food=Foodsi(1);      % Top Reýnforcement Template No.
PRM.ASALALT_DONATI_food=Foodsi(2);      % Bottom Reýnforcement Template No.
HK1=TP.DDHK(Foodsi(3));                 % Height of Beam 1
HK2=TP.DDHK(Foodsi(4));                 % Height of Beam 2 
PRM.fcd=TP.fcd_data(Foodsi(5));         % Design compressive strength of concrete
PRM.fctd=TP.fctd_data(Foodsi(5));       % Design tensile strength of concrete
PRM.k1=TP.k1_data(Foodsi(5));           % Equivalent compression block depth coefficient
PRM.Ec=TP.Ec_data(Foodsi(5));           % Modulus of elasticity of concrete
PRM.fyd=TP.fyd_data(Foodsi(6));      	% Yield strength of reinforcement
PRM.CC=TP.Cc_data(Foodsi(5));           % Unit cost of concrete
PRM.CST=TP.Cs_data(Foodsi(6));          % Unit cost of steel
% Stirrup spacing in the confinement zone
PRM.s_sar=[TP.etr_ara(Foodsi(7)) TP.etr_ara(Foodsi(9))];
% Stirrup spacing in the mid zone
PRM.s_orta=[TP.etr_ara(Foodsi(8)) TP.etr_ara(Foodsi(10))];

PRM.kiris_HK=[HK1 HK2];
%% STRUCTURAL ANALYSIS MODULE
[PRM.MOM,PRM.KESME]=CONTBEAM_2D_SPAN2(TP,PRM);

%% TOP AND BOTTOM REINFORCEMENT MODULES 
[PRM.UST_IND,PRM.UST_AS,PRM.UST_d,PRM.UST_MR,PRM.UST_RHO]=SELECT_TOP_TEMPLATE(TP,PRM);
[PRM.ALT_IND,PRM.ALT_AS,PRM.ALT_MR,PRM.ALT_RHO]=SELECT_BOT_TEMPLATE(TP,PRM);

%% SHEAR REINFORCEMENT MODULE
[PRM.VD,PRM.VR,PRM.Vcr,PRM.ASW,PRM.ETR_SAY,PRM.ETR_AGIRLIK]=SHEAR(TP,PRM);

%% TOP AND BOTTOM REINFORCEMENT LAYOUTS MODULES
[PRM.W_DON_UST,PRM.DON_UST,PRM.FI_UST,PRM.DONATI_BOY_UST]=TOP_REBAR_SPAN2(TP,PRM);  
[PRM.W_DON_ALT,PRM.DON_ALT,PRM.FI_ALT,PRM.DONATI_BOY_ALT]=BOT_REBAR_SPAN2(TP,PRM);

%% WEB REINFORCEMENT MODULE
[PRM.W_DON_GOVDE,PRM.govde_fi]=WEB_REBAR(TP,PRM);

%% CONSTRAINT CALCULATION MODULE
g = CONSTRAINT_MODULE_SPAN2(TP,PRM);
    
%% PENALIZED OBJECTIVE FUNCTION

% TOTAL REINFORCEMENT WEIGHT
WST=PRM.W_DON_UST+PRM.W_DON_ALT+PRM.W_DON_GOVDE+sum(PRM.ETR_AGIRLIK);

% CONCRETE VOLUME
VCK(1)=(TP.L_kiris(1)+TP.ustkolon_HK(1)/2)*TP.kiris_BW(1)*PRM.kiris_HK(1)/10^9;
VCK(2)=(TP.L_kiris(2)+TP.ustkolon_HK(3)/2)*TP.kiris_BW(2)*PRM.kiris_HK(2)/10^9;
VC=sum(VCK);

% OBJECTIVE FUNCTION
ObjVal=WST*PRM.CST+VC*PRM.CC;    %($) Total cost

Z=0;
for k=1:length(g)
     Z=Z+ TP.PEN*g(k);
end

CIKIS.CEZALI=ObjVal+Z;
end
