% renameFictracVid.m
%
% Function that renames all FicTrac video tiff files by generating and
%  calling Powershell script. 
% Assumes FicTrac video tiff files are named fictracVid_dateTime_#.tiff.
% Basically same function as renameLegVid(), except meant to run on Fictrac
%  videos collected by camera connected to separate computer
%
% INPUTS:
%   rawFictracVidPath - full path to rawFictracVid folder
%   scriptsPath - full path to folder to save scripts
%   flyName - name of fly (e.g. fly01)
%   cellName - name of cell (e.g. cell01)
%
% OUTPUTS:
%   renameStatus - status of renaming, returns 0 for success and 1 for
%     failure
%
% CREATED:
%   12/16/20 - variant of renameLegVid()
%
% UPDATED:
%   12/16/20 - HHY
%   12/25/20 - HHY
%

function renameStatus = renameFictracVid(rawFictracVidPath, scriptsPath, ...
    flyName, cellName) 

    % get present working directory
    curDir = pwd;
    
    % go to rawFictracVid folder (necessary for Powershell script call to 
    %  work)
    cd(rawFictracVidPath)

    % generate Powershell script to rename fictracVid files
    renameScriptFname = [flyName '_' cellName ...
        '_fictracVidRenameScript.ps1'];
    renameScriptPath = [scriptsPath filesep renameScriptFname];
    renameScriptFID = fopen(renameScriptPath, 'w');

    % write command to go to right folder
    fprintf(renameScriptFID, 'cd "%s"\n', rawFictracVidPath);
    % write rename command
    fprintf(renameScriptFID, ...
        'get-childitem fictracVid* | rename-item -newname{[string] ($_.name).substring(25) -replace "-", "fictracVid-"}');

    % close file
    fclose(renameScriptFID);

    disp('Renaming FicTrac vid images');

    % call script to do renaming              
    renameCmd = sprintf(...
        'Powershell -NoProfile -ExecutionPolicy Bypass -Command "%s"', ...
        renameScriptPath);
    renameStatus = system(renameCmd);

    if ~(renameStatus)
        disp('FicTrac vid images renamed successfully!');
    else
        disp('Error renaming FicTrac vid images');
        return; % end function here; this is a problem
    end
    
    % return to original directory
    cd(curDir);
end