% getFlyMetadata.m
%
% Function that prompts user to enter metadata about the experimental fly
%  and returns it in a single struct. Also, saves identifying info about
%  fly (date and fly number).
% Metadata:
%   genotype - as string, fly genotype
%   manipulation - as string, anything done to fly (e.g. starvation,
%       pharmacology, etc.)
%   prepType - as string, how was fly mounted (which mount, postion, etc.)
%   dissectionNotes - as string, any comments about the dissection
%   ageUnits - whether age expressed in hours or days
%   age - in units specified by ageUnits, as single number or range 
%
% INPUTS:
%   dateDir - name of date directory, only YYMMDD portion, not full path
%   flyDir - name of fly directory, only fly## portion
%
% OUTPUTS:
%   flyData - struct of all of the above info (metadata and inputs)
%
% Created: 7/27/18
% Updated: 7/27/18 - HHY
%

function flyData = getFlyMetadata(dateDir, flyDir)
    flyData.dateDir = dateDir;
    flyData.flyDir = flyDir;
    
    % prompt user for manually entered metadata, in dialog box
    prompt = {'Genotype', 'Manipulation', 'Prep Type', ...
        'Dissection Notes', 'Age Units (hrs/days)', 'Age'};
    title = 'Fly Metadata';
    % dimensions; allows multiple lines and arbitrary length for genotype, 
    %  manipulation, prep type, dissection notes fields
    dims = [2 60; 2 60; 2 60; 2 60; 1 10; 1 10];
    
    % do it this way so cancel just brings up dialog box again
    metadata = {};
    while isempty(metadata)
        metadata = inputdlg(prompt, title, dims);
    end
    
    % save metadata into flyData struct
    flyData.genotype = metadata{1};
    flyData.manipulation = metadata{2};
    flyData.prepType = metadata{3};
    flyData.dissectionNotes = metadata{4};
    flyData.ageUnits = metadata{5};
    flyData.age = str2num(metadata{6}); % convert age to numerical value
    
end
