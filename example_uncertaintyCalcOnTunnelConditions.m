%% Uncertainty Calculation on Tunnel Conditions

clear variables
addpath(genpath('Matlab_Murray_UtilitiesGeneral_v1.1'))

% %% OPEN MASTER Summary Run Catalog
% % The master spreadsheet with the static data averages is ... 
% %   202009_TSWT_Panel_runConditions_Summary_MASTER.xlsx
% 
% nm_openWithSysCmd(...
%     '202009_TSWT_Panel_runConditions_Summary_MASTER.xlsx');

%% Import MASTER SHEET Info

masterSheet = ...
    '202009_TSWT_Panel_runConditions_Summary_MASTER.xlsx';
cInfo = nm_importMasterSheetXLSX(masterSheet);
sNums = cInfo.Event(cInfo.sConfID==3);

%% Percentile Quantification of Random Uncertainty in Tunnel Conditions

% x is a vector, matrix, or any numeric array of data. NaNs are ignored.
% p is the confidence level (ie, 95 for 95% CI)
% The output is 1x2 vector showing the [lower,upper] interval values.
p = 95; % for 95% confidence interval (CI)
CIFcn = @(x,p) prctile(x,abs([0,100]-(100-p)/2));
errEst = @(v) diff(CIFcn(v,p))/2;

clear ucert

for n = 1:numel(sNums)
    sN = sNums(n);
    dS = nm_load_dSet(sN);

    clear TRdata SlogTabl sLog
    TRdata = dS.tunnelRunData;
    SlogTabl = dS.staticRunData;
    sLog = table2struct(SlogTabl,'ToScalar',true);
    sLog.time_sec = milliseconds(sLog.Time(:) - sLog.Time(1))/1000;

    iX = find(sLog.InEvent == 1,1,'first');
    iY = find(sLog.InEvent == 1,1,'last');

    ucert.Pamb_psia(n,1) = errEst(dS.staticRunData.P_atm(iX:iY));
    ucert.P0_psia(n,1) = errEst(dS.staticRunData.P_total(iX:iY));
    ucert.Ps_psia(n,1) = errEst(dS.staticRunData.P_static(iX:iY));
    ucert.T0_degF(n,1) = errEst(dS.staticRunData.WTC_TT210_degF(iX:iY));
end
    
%%

writetable(struct2table(ucert),'temp.xlsx')