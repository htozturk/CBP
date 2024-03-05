function DESIGNVIEWER_SPAN1(Design_variables)
% © Assoc.Prof.Dr.Hasan Tahsin ÖZTÜRK         2024
% Please refer to the article titled "Research on Optimal Solutions and 
% Algorithm Stability Analyses in RC Continuous Beam Problems" for details.

% Reading Design Parameters and Data Pool
[TP]=DP_SPAN1;

% Assignment of Design Variables
PRM.ASALUST_DONATI_food=Design_variables(1);  	% Top Reýnforcement Template No.
PRM.ASALALT_DONATI_food=Design_variables(2);   	% Bottom Reýnforcement Template No.
HK1=TP.DDHK(Design_variables(3));               % Height of Beam 1
PRM.fcd=TP.fcd_data(Design_variables(4));      	% Design compressive strength of concrete
PRM.fctd=TP.fctd_data(Design_variables(4));   	% Design tensile strength of concrete
PRM.k1=TP.k1_data(Design_variables(4));       	% Equivalent compression block depth coefficient
PRM.Ec=TP.Ec_data(Design_variables(4));       	% Modulus of elasticity of concrete
PRM.fyd=TP.fyd_data(Design_variables(5));      	% Yield strength of reinforcement
PRM.CC=TP.Cc_data(Design_variables(4));        	% Unit cost of concrete
PRM.CST=TP.Cs_data(Design_variables(5));       	% Unit cost of steel
% Stirrup spacing in the confinement zone
PRM.s_sar=TP.etr_ara(Design_variables(6));
% Stirrup spacing in the mid zone
PRM.s_orta=TP.etr_ara(Design_variables(7));

PRM.kiris_HK=HK1;

%% STRUCTURAL ANALYSIS MODULE
[PRM.MOM,PRM.KESME]=CONTBEAM_2D_SPAN1(TP,PRM);

%% TOP AND BOTTOM REINFORCEMENT MODULES 
[PRM.UST_IND,PRM.UST_AS,PRM.UST_d,PRM.UST_MR,PRM.UST_RHO]=SELECT_TOP_TEMPLATE(TP,PRM);
[PRM.ALT_IND,PRM.ALT_AS,PRM.ALT_MR,PRM.ALT_RHO]=SELECT_BOT_TEMPLATE(TP,PRM);

%% SHEAR REINFORCEMENT MODULE
[PRM.VD,PRM.VR,PRM.Vcr,PRM.ASW,PRM.ETR_SAY,PRM.ETR_AGIRLIK]=SHEAR(TP,PRM);

%% TOP AND BOTTOM REINFORCEMENT LAYOUTS MODULES
[PRM.W_DON_UST,PRM.DON_UST,PRM.FI_UST,PRM.DONATI_BOY_UST]=TOP_REBAR_SPAN1(TP,PRM);   
[PRM.W_DON_ALT,PRM.DON_ALT,PRM.FI_ALT,PRM.DONATI_BOY_ALT]=BOT_REBAR_SPAN1(TP,PRM);

%% WEB REINFORCEMENT MODULE
[PRM.W_DON_GOVDE,PRM.govde_fi]=WEB_REBAR(TP,PRM);

%% CONSTRAINT CALCULATION MODULE
g = CONSTRAINT_MODULE_SPAN1(TP,PRM);

%% PENALIZED OBJECTIVE FUNCTION

% TOTAL REINFORCEMENT WEIGHT
WST=PRM.W_DON_UST+PRM.W_DON_ALT+PRM.W_DON_GOVDE+sum(PRM.ETR_AGIRLIK);

% CONCRETE VOLUME
VCK(1)=(TP.L_kiris+TP.ustkolon_HK(1)/2)*TP.kiris_BW(1)*PRM.kiris_HK(1)/10^9;
VC=sum(VCK);

% OBJECTIVE FUNCTION
ObjVal=WST*PRM.CST+VC*PRM.CC;    %($) Total cost

Z=0;
for k=1:length(g)
     Z=Z+ TP.PEN*g(k);
end
CIKIS.CEZALI=ObjVal+Z;

%% Reports
fprintf('------------------------------------------------------------------------ \n')
fprintf('*********************     CBP with 1 SPAN     ************************** \n')
fprintf('*************************     GENERAL     ****************************** \n')
fprintf('************************************************************************ \n')
if sum(g)>0
fprintf('There is constraint violation. Solution is infeasible. ! \n')
else
fprintf('There is no constraint violation. The solution is feasible. \n')
end
fprintf('----------------------------------------------------------------- \n')
fprintf('Constraint violations \n')
g
fprintf('----------------------------------------------------------------- \n')
fprintf('Total constraint violation               =  %8.3f \n',sum(g))
fprintf('Beam height                              = %8d mm \n',PRM.kiris_HK)
fprintf('Concrete Grade                           = %8s  \n',TP.Csinif(Design_variables(4)))
fprintf('Steel Grade                              = %8s  \n',TP.Fsinif(Design_variables(5)))

fprintf('------------------------------------------------------------------------\n')
fprintf('********************  BOTTOM REINFORCEMENT DETAIL **********************\n')
fprintf('************************************************************************\n')
fprintf('Tensile reinforcement area at beam span #1  = %8.2f mm2 \n',PRM.ALT_AS)
fprintf('Tensile reinforcement ratio at beam span #1 = %8.4f \n',PRM.ALT_RHO)
fprintf('Moment bearing strength at beam span #1     = %8.2f kNm\n',PRM.ALT_MR)
bar_type_num=size(PRM.DON_ALT,1);
for bar_type=1:bar_type_num
    fprintf('Rebars #%2d = %2d Ø %2d + %2d Ø %2d + %2d Ø %2d + %2d Ø %2d \n',bar_type,PRM.DON_ALT(bar_type,1),PRM.FI_ALT(1),PRM.DON_ALT(bar_type,2),PRM.FI_ALT(2),PRM.DON_ALT(bar_type,3),PRM.FI_ALT(3),PRM.DON_ALT(bar_type,4),PRM.FI_ALT(4))
end


fprintf('------------------------------------------------------------------------\n')
fprintf('*********************   TOP REINFORCEMENT DETAIL ***********************\n')
fprintf('************************************************************************\n')
fprintf('Left support tensile reinforcement area at   beam #1 = %8.2f mm2 \n',PRM.UST_AS(1))
fprintf('Right support tensile reinforcement area at  beam #1 = %8.2f mm2 \n',PRM.UST_AS(3))

fprintf('Left support moment bearing strength at      beam #1 = %8.2f kNm\n',PRM.UST_MR(1))
fprintf('Right support moment bearing strength at     beam #1 = %8.2f kNm\n',PRM.UST_MR(3))

fprintf('Left support tensile reinforcement ratio at  beam #1 = %8.4f \n',PRM.UST_RHO(1))
fprintf('Right support tensile reinforcement ratio at beam #1 = %8.4f \n',PRM.UST_RHO(3))

bar_type_num=size(PRM.DON_UST,1);
for bar_type=1:bar_type_num
    fprintf('Rebars #%2d = %2d Ø %2d + %2d Ø %2d + %2d Ø %2d + %2d Ø %2d \n',bar_type,PRM.DON_UST(bar_type,1),PRM.FI_UST(1),PRM.DON_UST(bar_type,2),PRM.FI_UST(2),PRM.DON_UST(bar_type,3),PRM.FI_UST(3),PRM.DON_UST(bar_type,4),PRM.FI_UST(4))
end

fprintf('------------------------------------------------------------------------\n')
fprintf('*******************  SHEAR REINFORCEMENT INFORMATION *******************\n')
fprintf('************************************************************************\n')
fprintf('Stirrup (Confinement Zone)              = Ø %2d / %4d \n',TP.etrcap,PRM.s_sar)
fprintf('Stirrup (Mid Zone)                      = Ø %2d / %4d \n',TP.etrcap,PRM.s_orta)

fprintf('------------------------------------------------------------------------\n')
fprintf('*******************  WEB REINFORCEMENT INFORMATION **********************\n')
fprintf('************************************************************************\n')
fprintf('Web Reinforcement                       =  %2d Ø %2d \n',PRM.govde_fi(1,1),PRM.govde_fi(2,1))
fprintf('Web Reinforcement Area                  =  %8.2f mm2 \n',PRM.govde_fi(4,1))

fprintf('------------------------------------------------------------------------\n')
fprintf('************************  QUANTITIES OF MATERIALS ***********************\n')
fprintf('************************************************************************\n')
fprintf('Amount of Main Reinforcement            =  %8.2f kg \n',PRM.W_DON_UST+PRM.W_DON_ALT)
fprintf('Amount of Web Reinforcement             =  %8.2f kg \n',PRM.W_DON_GOVDE)
fprintf('Amount of Stirrup                       =  %8.2f kg \n',sum(PRM.ETR_AGIRLIK))
fprintf('                                          + ____________\n')
fprintf('Total Amount of Reinforcement           =  %8.2f kg \n',WST)
fprintf('Total Amount of Concrete                =  %8.2f m3 \n',VC)

fprintf('------------------------------------------------------------------------\n')
fprintf('********************************* COSTS ********************************\n')
fprintf('************************************************************************\n')
fprintf('Cost of Steel                           =  %8.2f $ \n',WST*PRM.CST)
fprintf('Cost of Concrete                        =  %8.2f $ \n',VC*PRM.CC)
fprintf('                                          + ____________\n')
fprintf('Total Cost                              =  %8.2f $ \n',ObjVal)