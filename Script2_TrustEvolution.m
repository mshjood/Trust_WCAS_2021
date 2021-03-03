% This script is used to model user's trust evolution


p_1=0.3; %climatological probability of droughts; also user's belief about drought

% Read time series of drought events (observations) from Excel 
filename='InputData.xlsx';
sheet='Drought_Timeseries';
xlRange='c3:c102';
Drought = xlsread(filename,sheet,xlRange);

% Read time series of drought forecasts from Excel 
sheet='Forecast_Timeseries';
xlRange='c3:c102';
pd = xlsread(filename,sheet,xlRange); %probabilistic drought forecast

T=length(Drought); %Total number of time steps (T=100)

% Learning: updating trust based on observation-forecast pairs
tau = 0:.0001:1; %user's trust in forecasts [0,1]
tau=transpose(tau);
L=length(tau);

pdf_tau=zeros(L,T); %PDF of tau
sheet='Trust_InitialPDF';
xlRange='C3:C10003';
pdf_tau(:,1)=xlsread(filename,sheet,xlRange); %read initial PDF from Excel

mu_tau=zeros(T,1); %mean of Trust
variance_tau=zeros(T,1); %variance of Trust
stdev_tau=zeros(T,1); %standard deviation of Trust

mu_tau_1=trapz(tau,tau.*pdf_tau(:,1)); %mean of Trust at t=1
variance_tau_1=trapz(tau,((tau-mu_tau_1).^2).*pdf_tau(:,1)); %variance of Trust at t=1
stdev_tau_1=sqrt(variance_tau_1); %standard deviation of Trust at t=1

mu_tau(1,1)=mu_tau_1;
variance_tau(1,1)=variance_tau_1;
stdev_tau(1,1)=stdev_tau_1;

clear area1
clear area2
clear area3
clear area4
        
p1=zeros(L,T); 
p2=zeros(L,T);
p3=zeros(L,T);
p4=zeros(L,T);

for t=1:T-1
            if Drought(t)==1  %PDF(tau|Drought=1 & pd)
                p1(:,t)= (p_1.*(tau.*pdf_tau(:,t)));  %p1 is p(tau|Drought=1,\teta_hat=1)
                area1(t)=trapz(tau,p1(:,t));
                p1(:,t)=p1(:,t)./area1(t);
                p2(:,t)= (p_1.*((1-tau).*pdf_tau(:,t)));  %p2 is p(tau|Drought=1,\teta_hat=0)
                area2(t)=trapz(tau,p2(:,t));
                p2(:,t)=p2(:,t)./area2(t);
        
                pdf_tau(:,t+1)=pd(t,1).*p1(:,t)+(1-pd(t,1)).*p2(:,t); %Equation A9
            else              %PDF(tau|Drought=0 & pd)
                p3(:,t)= ((1-p_1).*((1-tau).*pdf_tau(:,t)));  %p3 is p(tau|DroughtO=0,\teta_hat=1)
                area3(t)=trapz(tau,p3(:,t));
                p3(:,t)=p3(:,t)./area3(t);
                p4(:,t)= ((1-p_1).*(tau.*pdf_tau(:,t)));  %p4 is p(tau|Drought=0,\teta_hat=0)
                area4(t)=trapz(tau,p4(:,t));
                p4(:,t)=p4(:,t)./area4(t);
                
                pdf_tau(:,t+1)=pd(t,1).*p3(:,t)+(1-pd(t,1)).*p4(:,t); %Equation A13
            end
            mu_tau(t+1,1)=trapz(tau,tau.*pdf_tau(:,t+1)); %Calculate mean of trust
            variance_tau(t+1,1)=trapz(tau,((tau-mu_tau(t+1,1)).^2).*pdf_tau(:,t+1)); %Calculate variance of trust
            stdev_tau(t+1,1)=sqrt(variance_tau(t+1,1)); %Calculate standard deviation of trust
            
            pdf_tau(:,t+1)=pdf_tau(:,t+1);  
end

% Update user's belief about drought based on trust
p_1_updated=zeros(L,T); %Updated user's belief about drought for a given trust (tau) -- Equation 6
p_1_updated_predictive=zeros(T,1); %Updated user's belief about drought based on the entire distribution of trust (tau) -- Equation 7

for t=1:T
    for l=1:L
        p_1_updated(l,t)=pd(t,1)*(tau(l)*p_1/(tau(l)*p_1+(1-tau(l))*(1-p_1)))+...
                (1-pd(t,1))*((1-tau(l))*p_1/((1-tau(l))*p_1+tau(l)*(1-p_1)));
    end
    p_1_updated_predictive(t,1)=trapz(tau,p_1_updated(:,t).*pdf_tau(:,t));
end