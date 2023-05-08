%% WHAT is this?
% For the 202009_TSWT_Panel effort, the event files did not have all of the
% data that I needed for analysis. So, I had to go back to the log files
% that keep *all* the data and process them to pull out the event-based
% information. This may be a useful tool if needed somewhere later.

%% FIRST Brute Force Separate Logs at Headers

clear variables

% These have already been completed ...
%     logFiles = {...
%         '202009_TSWT_Panel_Log_0007-0038.txt';... 
%         '202009_TSWT_Panel_Log_0039-0042.txt';... 
%         '202009_TSWT_Panel_Log_0043-0051.txt';... 
%         '202009_TSWT_Panel_Log_0052-0056.txt';...
%         '202009_TSWT_Panel_Log_0057-0066.txt',...
%         '202009_TSWT_Panel_Log_0067-0069.txt';...
%         '202009_TSWT_Panel_Log_0070-0081.txt';...
%         '202009_TSWT_Panel_Log_0082-0090.txt';...
%         '202009_TSWT_Panel_Log_0091-0094.txt';...
%         '202009_TSWT_Panel_Log_0095-0107.txt';...
%           };
    logFiles = {...
          '202009_TSWT_Panel_Log_0108-0113.txt';...
          '202009_TSWT_Panel_Log_0114-0125.txt';...
        };

staticPath = 'DATA_Static';

for lfN = 1:numel(logFiles)

    fName = fullfile(staticPath,logFiles{lfN});
    INfileID = fopen(fName,'r');

    % Find Header Rows ...
    frewind(INfileID)

    eofFound = false;
    hN = 0;
    n = 1;
    headerRow = [];
    startRow = [];
    endRow = [];
    while not(eofFound)
        tLine = fgetl(INfileID); % Read a line ...
        if ( tLine == -1 ) % Check for EOF ...
            eofFound = true;
            endRow(hN) = n;
        elseif ( ~isempty(tLine) && strcmp(tLine(1:4),'Date') )
            hN = hN + 1;
            headerRow(hN) = n;
            startRow(hN) = n+1;
            if ( n > 1)
                endRow(hN-1) = n-1;
            end
            n = n + 1;
        else
            n = n + 1;
        end
    end

    nHdrs = numel(headerRow);

    for hdN = 1:nHdrs
        newLgF = fullfile(staticPath,...
            ['202009_TSWT_Panel_LogPart_' ...
             sprintf('lfN%02d_',lfN) sprintf('hdN%02d',hdN) '.txt']);
        OUTfileID = fopen(newLgF,'w');

        frewind(INfileID)
        % Use fgetl to advance to the section of interest ...
        for n = 1:startRow(hdN)-1 % read each line and keep the last one read
            a = fgetl(INfileID);
        end

        fprintf(OUTfileID,'%s\n',a);

        for lN = 1:(endRow(hdN) - startRow(hdN))
            a = fgetl(INfileID);
            fprintf(OUTfileID,'%s\n',a);
        end
    end
end
     

%% NEXT Search Logs for Events and Save

clear variables
staticPath = 'DATA_Static';
searchN = fullfile(staticPath,'202009_TSWT_Panel_LogPart*.txt');
listing = dir(searchN);

for lfN = 1:numel(listing)
    % I need the variable names ... so open the file
	fN = fullfile(listing(lfN).folder,listing(lfN).name);
    fileID = fopen(fN,'r');
    % Read the header line ...
    a = fgetl(fileID);
    % Split the line using spaces as delimiters ...
    sa = strsplit(a,' ');
    % File the number of variables in the header ...
    nVars = numel(sa);
    % Close the file
    fclose(fileID);
    
    % Set options for readtable() ...
    opts = delimitedTextImportOptions("NumVariables", nVars);

    % Specify range and delimiter
    opts.DataLines = [2, Inf];
    opts.Delimiter = " ";
    
    % Matlab can't have parenthesis in variable names so fix this ...
    saN = strrep(sa,'(F)','_degF');
    opts.VariableNames = saN;
    
    % Specify file level properties
    opts.ExtraColumnsRule = "ignore";
    opts.EmptyLineRule = "read";
    opts.ConsecutiveDelimitersRule = "join";
    opts.LeadingDelimitersRule = "ignore";
    
    % Set variable types ...
    opts = setvartype(opts,[1 2],'datetime');
    for nV = 3:nVars
        opts = setvartype(opts,saN{nV},'double');
    end
    opts = setvaropts(opts, 'Date', 'InputFormat', 'yyy/MM/dd');
    opts = setvaropts(opts, 'Time', 'InputFormat', 'HH:mm:ss.SSS');
    
    % Read the table
    myT = readtable(fN,opts);
    
    % Pull out the part that goes with each wind tunnel run ...
    myTsub = myT(myT.P0state>=3,:);
    
    TRs = unique(myTsub.TR);
    EVs = unique(myTsub.Event);
    
    for cEV = 1:numel(EVs)
        OUTfileN = fullfile(staticPath,...
            sprintf('202009_TSWT_Panel_%04d_fullTR.mat',EVs(cEV)));
        eventLog = myTsub(myTsub.Event==EVs(cEV),:); 
        save(OUTfileN,'eventLog')
    end
end



