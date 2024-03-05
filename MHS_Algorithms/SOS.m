function SOS(OPTIM_DATA)
ObjectiveFunction=OPTIM_DATA.ObjectiveFunction;

%% PARAMETERS
ALGO='SOS';
% Upper Bounds
UB=OPTIM_DATA.UB;
% Lower Bounds
LB=OPTIM_DATA.LB;
% Problem Size
n=size(LB,2);
% Runtime
RT=OPTIM_DATA.RT;
% Maximum Function Evaluations
MXFE_C=OPTIM_DATA.MXFE_D;
MXFE=MXFE_C*n;

%% CONTROL PARAMETERS 
POP=50;

%% **********  RESULT REPORTS  **********
    dosya_adi1=['RESULTS/',ALGO,'_REPORT_',OPTIM_DATA.problem_name,'.txt']; 
    glorap= fopen(dosya_adi1,'wt');
    dosya_adi2=['RESULTS/',ALGO,'_PARAMETERS_',OPTIM_DATA.problem_name,'.txt'];
    PARAM_RAP= fopen(dosya_adi2,'wt');
%% ALGORITHM
for run=1:RT
    
       	rand('seed', sum(100 * clock)); 
        FUNCEVA=0;   % Function of Evaluation Counter
         tStart(run)=tic;
                           
eco=zeros(POP,n);           % Ecosystem Matrix
fitness =zeros(POP,1);      % Fitness Matrix
 

% --- Ecosystem Initialization
for i=1:POP
    % Initialize the organisms randomly in the ecosystem 
    eco(i,:)=round(rand(1,n).*(UB-LB))+LB;
    % Evaluate the fitness of the new solution
    [CIKIS]=ObjectiveFunction(eco(i,:));
    fitness(i,:)=CIKIS.CEZALI;
    FUNCEVA=FUNCEVA+1;
end

iter=1;
% --- Main Looping
while   FUNCEVA<MXFE

    for i=1:POP % Organisms' Looping

        % Update the best Organism
        [bestFitness,idx]=min(fitness); 
        bestOrganism=eco(idx,:);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Mutualism Phase
            % Choose organism j randomly other than organism i           
            j=i;
            while i==j
                seed=randperm(POP); 
                j=seed(1);                  
            end
            % Determine Mutual Vector & Beneficial Factor
            mutualVector=mean([eco(i,:);eco(j,:)]);
            BF1=round(1+rand); 
            BF2=round(1+rand);

            % Calculate new solution after Mutualism Phase
            ecoNew1=round(eco(i,:)+rand(1,n).*(bestOrganism-BF1.*mutualVector)); 
            ecoNew2=round(eco(j,:)+rand(1,n).*(bestOrganism-BF2.*mutualVector));

%% --- Boundary Handling --- 
ecoNew1(ecoNew1>UB)=UB(ecoNew1>UB); 
ecoNew1(ecoNew1<LB)=LB(ecoNew1<LB);

ecoNew2(ecoNew2>UB)=UB(ecoNew2>UB); 
ecoNew2(ecoNew2<LB)=LB(ecoNew2<LB);

            % Evaluate the fitness of the new solution
                [CIKIS]=ObjectiveFunction(ecoNew1);
                fitnessNew1=CIKIS.CEZALI;
                FUNCEVA=FUNCEVA+1;
               	[CIKIS]=ObjectiveFunction(ecoNew2);
                fitnessNew2=CIKIS.CEZALI;
                FUNCEVA=FUNCEVA+1;

            % Accept the new solution if the fitness is better
            if fitnessNew1<fitness(i)
                fitness(i)=fitnessNew1;
                eco(i,:)=ecoNew1;
            end
            if fitnessNew2<fitness(j)
               fitness(j)=fitnessNew2;
               eco(j,:)=ecoNew2;
            end


        %End of Mutualism Phase 
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
        %Commensialism Phase

           % Choose organism j randomly other than organism i
            j=i;
            while i==j
                seed=randperm(POP); 
                j=seed(1);                  
            end

            %Calculate new solution after Commensalism Phase    
            ecoNew1=round(eco(i,:)+(rand(1,n)*2-1).*(bestOrganism-eco(j,:)));
          % ecoNew1=bound(ecoNew1,UB,LB);

ecoNew1(ecoNew1>UB)=UB(ecoNew1>UB); 
ecoNew1(ecoNew1<LB)=LB(ecoNew1<LB);

            % Evaluate the fitness of the new solution
                [CIKIS]=ObjectiveFunction(ecoNew1);
                fitnessNew1=CIKIS.CEZALI;
                FUNCEVA=FUNCEVA+1; 
            % Accept the new solution if the fitness is better
            if fitnessNew1<fitness(i)
                fitness(i)=fitnessNew1;
                eco(i,:)=ecoNew1;
            end


         % End of Commensalism Phase
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Parasitism Phase

            % Choose organism j randomly other than organism i 
            j=i;
            while i==j
                seed=randperm(POP);
                j=seed(1);
            end

            % Determine Parasite Vector & Calculate the fitness
            parasiteVector=eco(i,:);
            seed=randperm(n);           
            pick=seed(1:ceil(rand*n));  % select random dimension
            parasiteVector(:,pick)=round(rand(1,length(pick)).*(UB(pick)-LB(pick))+LB(pick));
                [CIKIS]=ObjectiveFunction(parasiteVector);
                fitnessParasite=CIKIS.CEZALI;
                FUNCEVA=FUNCEVA+1;        
            % Kill organism j and replace it with the parasite 
            % if the fitness is lower than the parasite
            if fitnessParasite < fitness(j)
                fitness(j)=fitnessParasite;
                eco(j,:)=parasiteVector;
            end


        % End of Parasitism Phase
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    end % End of Organisms' Looping
[fmin,K]=min(fitness) ;
Best_Solution=eco(K,:);
BestCost(iter)=fmin;    

   % Show Iteration Information
    fprintf('ITERATION = %5.0f  ||  FUNC. EVALUATIONS = %15d  --->  COST = %10.3f \n',iter,FUNCEVA,BestCost(iter))

 iter=iter+1; 
end % End of Main Looping

[val,ind]=min(BestCost);
SUM_FUNCEVA(run)=FUNCEVA;
bestt(run)=val;
GlobalParams(run,:)=Best_Solution;
tEnd(run)=toc(tStart(run));

fprintf(PARAM_RAP,'%g\t',GlobalParams(run,:));
fprintf(PARAM_RAP,'\n');

fprintf(glorap,' RUN NO = %5d  ||  COST = %30.8f ($)  ||  FUNC. EVALUATIONS = %10d  ||  COMP. DURATION = %f (s) \n',run,bestt(run),SUM_FUNCEVA(run),tEnd(run));
end
return