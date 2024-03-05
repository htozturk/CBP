function COA(OPTIM_DATA)

ObjectiveFunction=OPTIM_DATA.ObjectiveFunction;


%% PARAMETERS
ALGO='COA';
% Upper Bounds
UB=OPTIM_DATA.UB;
% Lower Bounds
LB=OPTIM_DATA.LB;
% Problem Size
D=size(LB,2);
% Runtime
RT=OPTIM_DATA.RT;
% Maximum Function Evaluations
MXFE_C=OPTIM_DATA.MXFE_D;
MXFE=MXFE_C*D;

%% CONTROL PARAMETERS 
n_coy=5;
n_packs=20;
p_leave     = 0.005*n_coy^2;  % Probability of leaving a pack
Ps          = 1/D;



if n_coy < 3, error('At least 3 coyotes per pack!'); end


%% Packs initialization (Eq. 2)
pop_total   = n_packs*n_coy;

%% **********  RESULT REPORTS  **********
    dosya_adi1=['RESULTS/',ALGO,'_REPORT_',OPTIM_DATA.problem_name,'.txt']; 
    glorap= fopen(dosya_adi1,'wt');
    dosya_adi2=['RESULTS/',ALGO,'_PARAMETERS_',OPTIM_DATA.problem_name,'.txt'];
    PARAM_RAP= fopen(dosya_adi2,'wt');
    
%% ALGORITHM
    for run=1:RT
   
    rand('seed', sum(100 * clock)); 
    FUNCEVA=0;
    tStart(run)=tic;

    costs       = zeros(pop_total,1);
coyotes     = repmat(LB,pop_total,1) +round( rand(pop_total,D).*(repmat(UB,pop_total,1) - repmat(LB,pop_total,1)));
ages        = zeros(pop_total,1);
packs       = reshape(randperm(pop_total),n_packs,[]);
coypack     = repmat(n_coy,n_packs,1);
%% Evaluate coyotes adaptation (Eq. 3)
for c=1:pop_total
    [CIKIS]=ObjectiveFunction(coyotes(c,:));
        costs(c,1)=CIKIS.CEZALI;
        FUNCEVA=FUNCEVA+1;
   
end
% nfeval = pop_total;
% 
%% Output variables
[GlobalMin,ibest]   = min(costs);
GlobalParams        = coyotes(ibest,:);
    
%% Main loop
year=0;
iter=1;
while FUNCEVA<MXFE % Stopping criteria

    %% Update the years counter
    year = year + 1;

    %% Execute the operations inside each pack
    for p=1:n_packs
%         Get the coyotes that belong to each pack
        coyotes_aux = coyotes(packs(p,:),:);
        costs_aux   = costs(packs(p,:),:);
        ages_aux    = ages(packs(p,:),1);
        n_coy_aux   = coypack(p,1);
        
        % Detect alphas according to the costs (Eq. 5)
        [costs_aux,inds] = sort(costs_aux,'ascend');
        coyotes_aux      = coyotes_aux(inds,:);
        ages_aux         = ages_aux(inds,:);
        c_alpha          = coyotes_aux(1,:);
        
        % Compute the social tendency of the pack (Eq. 6)
        tendency         = median(coyotes_aux,1);
        
        % Update coyotes' social condition
        new_coyotes      = zeros(n_coy_aux,D);
        for c=1:n_coy_aux
            rc1 = c;
            while rc1==c
                rc1 = randi(n_coy_aux);
            end
            rc2 = c;
            while rc2==c || rc2 == rc1
                rc2 = randi(n_coy_aux);
            end
            
            % Try to update the social condition according to the alpha and
            % the pack tendency (Eq. 12)
            new_c = coyotes_aux(c,:) + round(rand*(c_alpha - coyotes_aux(rc1,:))+ ...
                                       rand*(tendency  - coyotes_aux(rc2,:)));
            
            % Keep the coyotes in the search space (optimization problem constraint)
            new_coyotes (c,:)= BoundaryControl(new_c,LB,UB);
            % Evaluate the new social condition (Eq. 13)
            
        [CIKIS]=ObjectiveFunction(new_coyotes(c,:));
        new_cost=CIKIS.CEZALI;
        FUNCEVA=FUNCEVA+1;  
            % Adaptation (Eq. 14)
            if new_cost < costs_aux(c,1)
                costs_aux(c,1)      = new_cost;
                coyotes_aux(c,:)    = new_coyotes(c,:);
            end
        end
         
        %% Birth of a new coyote from random parents (Eq. 7 and Alg. 1)
        parents         = randperm(n_coy_aux,2);
        prob1           = (1-Ps)/2;
        prob2           = prob1;
        pdr             = randperm(D);
        p1              = zeros(1,D);
        p2              = zeros(1,D);
        p1(pdr(1))      = 1; % Guarantee 1 charac. per individual
        p2(pdr(2))      = 1; % Guarantee 1 charac. per individual
        r               = rand(1,D-2);
        p1(pdr(3:end))  = r < prob1;
        p2(pdr(3:end))  = r > 1-prob2;
        
        % Eventual noise 
        n  = ~(p1|p2);

        % Generate the pup considering intrinsic and extrinsic influence
        pup =   p1.*coyotes_aux(parents(1),:) + ...
                p2.*coyotes_aux(parents(2),:) + ...
                n.*(LB + round(rand(1,D).*(UB-LB)));
        
        % Verify if the pup will survive
        [CIKIS]=ObjectiveFunction(pup);
        pup_cost=CIKIS.CEZALI;
        FUNCEVA=FUNCEVA+1; 
        
        worst       = find(pup_cost<costs_aux==1);
        if ~isempty(worst)
            [~,older]               = sort(ages_aux(worst),'descend');
            which                   = worst(older);
            coyotes_aux(which(1),:) = pup;
            costs_aux(which(1),1)   = pup_cost;
            ages_aux(which(1),1)    = 0;
        end
        
        %% Update the pack information
        coyotes(packs(p,:),:) = coyotes_aux;
        costs(packs(p,:),:)   = costs_aux;
        ages(packs(p,:),1)    = ages_aux;
    end
    
    %% A coyote can leave a pack and enter in another pack (Eq. 4)
    if n_packs>1
        if rand < p_leave
            rp                  = randperm(n_packs,2);
            rc                  = [randperm(coypack(rp(1),1),1) ...
                                   randperm(coypack(rp(2),1),1)];
            aux                 = packs(rp(1),rc(1));
            packs(rp(1),rc(1))  = packs(rp(2),rc(2));
            packs(rp(2),rc(2))  = aux;
        end
    end
    
    %% Update coyotes ages
    ages = ages + 1;
    
    %% Output variables (best alpha coyote among all alphas)
      
                       % update results
    [BestCost(iter),indexbest]=min(costs);
    Best_Solution=coyotes(indexbest,:);
    
   % Show Iteration Information
    fprintf('ITERATION = %5.0f  ||  FUNC. EVALUATIONS = %15d  --->  COST = %10.3f \n',iter,FUNCEVA,BestCost(iter))

iter=iter+1;
end

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

function pop = BoundaryControl(pop,low,up)
[popsize,dim] = size(pop);
for i = 1:popsize
    for j = 1:dim
        F = rand.^3 ;
        if pop(i,j) < low(j), pop(i,j) = low(j) +  round(F .* ( up(j)-low(j) ));  end
        if pop(i,j) > up(j),  pop(i,j) = up(j)  +  round(F .* ( low(j)-up(j)));   end
    end
end
return


