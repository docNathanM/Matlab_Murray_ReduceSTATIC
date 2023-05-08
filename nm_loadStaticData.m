function [dStaticMN,dStaticVAR,dStaticArray] = nm_loadStaticData( eVnum )
%nm_loadStaticData( eVnum ) => dStatic loads the run data.

rdirAVG = rdir('**/*_averages.txt');
[~,fnameAVG,~] = fileparts(rdirAVG.name);

expName = erase(fnameAVG,'_averages');
staticPath = rdirAVG.folder;

staticFname = sprintf([expName '_%04d.txt'],eVnum);
fName = fullfile(staticPath,staticFname);

warning('off','MATLAB:table:ModifiedAndSavedVarnames')
Traw = readtable(fName,'FileType','text','ReadVariableNames',true);

dS = table2struct(Traw,'ToScalar',true);

% %% FIX ... for LLNL Panel Data
% % I had to include this to fix a problem with events 30 -- 38.
% 
%     BLlabel = 'BL_03_1';
%     fldN = fieldnames(dS);
%     a = find(strcmp(fields(dS),BLlabel));
%     if ( ~isempty(a) )
%         dS.BL_03 = getfield(dS,fldN{a});
%         dS = rmfield(dS,fldN{a});
%     else
%     end
% 
%     BLlabel = 'BL_06_1';
%     fldN = fieldnames(dS);
%     a = find(strcmp(fields(dS),BLlabel));
%     if ( ~isempty(a) )
%         dS.BL_06 = getfield(dS,fldN{a});
%         dS = rmfield(dS,fldN{a});
%     else
%     end
% 
% %%

dStaticMN = structfun(@meanOnStructEntry,dS,'UniformOutput',false);
dStaticVAR = structfun(@varOnStructEntry,dS,'UniformOutput',false);
dStaticArray = dS;

end

function structEntryMN = meanOnStructEntry(xS)
    if ( isnumeric(xS) )
        structEntryMN = mean(xS);
    else
        structEntryMN = xS(1);
    end
end

function structEntryMN = varOnStructEntry(xS)
    if ( isnumeric(xS) )
        structEntryMN = var(xS);
    else
        structEntryMN = xS(1);
    end
end