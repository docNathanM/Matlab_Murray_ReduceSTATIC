function panelS = nm_staticPortConfigs(sConfID)
% Returns STATIC port configuration => panelS
%
% UPDATE This based on the static port configuration.

switch sConfID
    case 1
        panelS.X = [0.5 1.25 2.25 3.25 5.65 6.65];
        panelS.Y = [0 0 0 0 0 0];
        panelS.IDs = [1 2 3 4 5 6];
    case 2
        panelS.X = [0.5 1.25 2.25 3.25];
        panelS.Y = [0 0 0 0];
        panelS.IDs = [1 2 3 4];
    case 3
        panelS.X = [0.5 1.25 2.25 3.25 5.15];
        panelS.Y = [0 0 0 0 0.5];
        panelS.IDs = [1 2 3 4 5];
end

end

