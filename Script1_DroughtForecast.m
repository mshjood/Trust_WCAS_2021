% This script is used to geberate probabilistic drought forecasts


p_1=0.3; %climatological probability of droughts; also user's belief about drought

% Read time series of drought events (observations) from Excel 
filename='InputData.xlsx';
sheet='Drought_Timeseries';
xlRange='c3:c102';
Drought = xlsread(filename,sheet,xlRange); 

T=length(Drought); %Total number of time steps (T=100)

% generate probabilistic drought forecasts
N=50; %ensemble size
q_const=0.8; %objective forecast accuracy
pd=zeros(T,1); %probabilistic drought forecast

for t=1:T
    if Drought(t,1)==1
        for n=1:N
            det_forecast(n,1) = binornd(1,q_const); %intermediate variable
        end
    else
        if Drought(t,1)==0
            for n=1:N
                det_forecast(n,1) = binornd(1,1-q_const);
            end
        end
    end
    pd=(sum(det_forecast(:,1))+0.5)/(N+1);
end
