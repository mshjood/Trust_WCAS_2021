% This script is used to assess the ex ante and ex post forecast values
% under three scenarios:
% case 1: information: forecast, trust=tau (complete distribution)
% case 2: information: forecast, trust=full (tau=1)
% case 3: information: perfect forecast, trust=full (tau=1)


p_1=0.3; %climatological probability of droughts; also user's belief about drought

% Read time series of drought events (observations) from Excel
filename='InputData.xlsx';
sheet='Drought_Timeseries';
xlRange='c3:c102';
Drought = xlsread(filename,sheet,xlRange);

T=length(Drought); %Total number of time steps (T=100)

% Read time series of drought forecasts from Excel 
sheet='Forecast_Timeseries';
xlRange='c3:c102';
pd = xlsread(filename,sheet,xlRange); %probabilistic drought forecast

% User's trust information
xlRange='f3:f102';
mu_tau=xlsread(filename,sheet,xlRange);
xlRange='h3:h102';
p_1_updated=xlsread(filename,sheet,xlRange); %update belief based on forecast

% crop yield information 
a1=0.4; %crop A's yield in drought state
a2=0.6; %crop A's yield in no-drought state
b1=0.1; %crop B's yield in drought state
b2=0.9; %crop B's yield in no-drought state

% decision maker's information
r=0.5; %user's risk aversion
W=1.5; %user's wealth level
y=ceil(W)+1;
%%

V_1=zeros(T,1); % ex ante value for case 1
V_1_expost=zeros(T,1); %ex post value: using case 1 decisions and actual weather

V_2=zeros(T,1); % ex ante value for case 2
V_2_expost=zeros(T,1); %ex post value: using case 2 decisions and actual weather

V_3=zeros(T,1); % ex ante value for case 3
V_3_expost=zeros(T,1); %ex post value: using case 3 decisions and actual weather

% x is the fraction of land allocated to crop A
x_new_1=zeros(T,1); % optimal x for case 1
expected_payoff_1=zeros(T,1);% expected payoff for case 1
expost_payoff_1=zeros(T,1); % ex post payoff for case 1

x_new_2=zeros(T,1); % optimal x for case 2
expected_payoff_2=zeros(T,1);% expected payoff for case 2
expost_payoff_2=zeros(T,1); % ex post payoff  for case 2

x_new_3=zeros(T,1); % optimal x for case 3
expected_payoff_3=zeros(T,1);% expected payoff for case 3
expost_payoff_3=zeros(T,1); % ex post payoff  for case 3

% functions to calculate optimal crop allocation and ex ante value
if r==1
    x_optimal_fun = @(x,a1,a2,b1,b2,W,r,p) -(p*(log(W+x*a1+(1-x)*b1))+(1-p)*(log(W+x*a2+(1-x)*b2)));
    exante_value_fun = @(x_zero,x_new,a1,a2,b1,b2,W,r,p,V) p*(log(W+x_zero*a1+(1-x_zero)*b1+V))+(1-p)*(log(W+x_zero*a2+(1-x_zero)*b2+V))-...
                                                    p*(log(W+x_new*a1+(1-x_new)*b1))-(1-p)*(log(W+x_new*a2+(1-x_new)*b2)); 
else
    x_optimal_fun = @(x,a1,a2,b1,b2,W,r,p) -(p*(((W+x*a1+(1-x)*b1)^(1-r))/(1-r))+(1-p)*(((W+x*a2+(1-x)*b2)^(1-r))/(1-r)));
    exante_value_fun = @(x_zero,x_new,a1,a2,b1,b2,W,r,p,V) p*((W+x_zero*a1+(1-x_zero)*b1+V)^(1-r)/(1-r))+(1-p)*((W+x_zero*a2+(1-x_zero)*b2+V)^(1-r)/(1-r))-...
                                                   p*((W+x_new*a1+(1-x_new)*b1)^(1-r)/(1-r))-(1-p)*((W+x_new*a2+(1-x_new)*b2)^(1-r)/(1-r));   
end

% analysis based on climatology : p_1
fun = @(x) x_optimal_fun(x,a1,a2,b1,b2,W,r,p_1) ;
x_zero = fminbnd(fun,0,1); %optimal decision using climotological information (p_1)

if x_zero<0.001
    x_zero=0;
else
    if x_zero>0.999
        x_zero=1;
    end
end

expected_payoff_zero=(p_1)*(W+x_zero*a1+(1-x_zero)*b1)+(1-p_1)*(W+x_zero*a2+(1-x_zero)*b2);

expost_payoff_zero=zeros(T,1); % ex post payoff based off of p_1 and x_zero

for i=1:T
    if Drought(i,1)==1
        expost_payoff_zero(i,1)=W+x_zero*a1+(1-x_zero)*b1;
    else
        expost_payoff_zero(i,1)=W+x_zero*a2+(1-x_zero)*b2;
    end
end

% analysis for cases 1-3
for i=1:T    
    % case 1: information: forecast, trust=tau
    fun = @(x) x_optimal_fun(x,a1,a2,b1,b2,W,r,p_1_updated(i,1)) ;
    x_new_1(i,1)=fminbnd(fun,0,1);
    
    if x_new_1(i,1)<0.001
        x_new_1(i,1)=0;
    else
        if x_new_1(i,1)>0.999
            x_new_1(i,1)=1;
        end
    end
    
    expected_payoff_1(i,1)=(p_1_updated(i,1)*(W+x_new_1(i,1)*a1+(1-x_new_1(i,1))*b1)+(1-p_1_updated(i,1))*(W+x_new_1(i,1)*a2+(1-x_new_1(i,1))*b2));
    
    fun = @(V) exante_value_fun(x_zero,x_new_1(i,1),a1,a2,b1,b2,W,r,p_1_updated(i,1),V) ;
    V_1(i,1)=fzero(fun,0.3);
    if abs(V_1(i,1))<0.001
        V_1(i,1)=0;
    end
    
    if Drought(i,1)==1
        expost_payoff_1(i,1)=W+x_new_1(i,1)*a1+(1-x_new_1(i,1))*b1;       
    else
        expost_payoff_1(i,1)=W+x_new_1(i,1)*a2+(1-x_new_1(i,1))*b2;        
    end
    V_1_expost(i,1)=expost_payoff_1(i,1)-expost_payoff_zero(i,1);
    
    % case 2: information: forecast, tau=1
    fun = @(x) x_optimal_fun(x,a1,a2,b1,b2,W,r,pd(i,1)) ;
    x_new_2(i,1)=fminbnd(fun,0,1);
    if x_new_2(i,1)<0.001
        x_new_2(i,1)=0;
    else
        if x_new_2(i,1)>0.999
            x_new_2(i,1)=1;
        end
    end
    
    expected_payoff_2(i,1)=(pd(i,1)*(W+x_new_2(i,1)*a1+(1-x_new_2(i,1))*b1)+(1-pd(i,1))*(W+x_new_2(i,1)*a2+(1-x_new_2(i,1))*b2));

    fun = @(V) exante_value_fun(x_zero,x_new_2(i,1),a1,a2,b1,b2,W,r,pd(i,1),V) ;
    V_2(i,1)=fzero(fun,0.3);
    if abs(V_2(i,1))<0.001
        V_2(i,1)=0;
    end
    
    if Drought(i,1)==1
        expost_payoff_2(i,1)=W+x_new_2(i,1)*a1+(1-x_new_2(i,1))*b1;        
    else
        expost_payoff_2(i,1)=W+x_new_2(i,1)*a2+(1-x_new_2(i,1))*b2;
    end
    V_2_expost(i,1)=expost_payoff_2(i,1)-expost_payoff_zero(i,1);
      
    % case 3: information: perfect, tau=1
    fun = @(x) x_optimal_fun(x,a1,a2,b1,b2,W,r,Drought(i,1)) ;
    x_new_3(i,1)=fminbnd(fun,0,1);
    if x_new_3(i,1)<0.001
        x_new_3(i,1)=0;
    else
        if x_new_3(i,1)>0.999
            x_new_3(i,1)=1;
        end
    end
    
    expected_payoff_3(i,1)=(Drought(i,1)*(W+x_new_3(i,1)*a1+(1-x_new_3(i,1))*b1)+(1-Drought(i,1))*(W+x_new_3(i,1)*a2+(1-x_new_3(i,1))*b2));
    
    fun = @(V) exante_value_fun(x_zero,x_new_3(i,1),a1,a2,b1,b2,W,r,Drought(i,1),V) ;
    V_3(i,1)=fzero(fun,0.3);
    if abs(V_3(i,1))<0.001
        V_3(i,1)=0;
    end
    
    if Drought(i,1)==1
        expost_payoff_3(i,1)=W+x_new_3(i,1)*a1+(1-x_new_3(i,1))*b1;        
    else
        expost_payoff_3(i,1)=W+x_new_3(i,1)*a2+(1-x_new_3(i,1))*b2;         
    end    
    V_3_expost(i,1)=expost_payoff_3(i,1)-expost_payoff_zero(i,1);
end






