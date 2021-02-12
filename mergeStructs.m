% mergeStructs.m
%
% Function to merge two structs into one struct with fields from both
%  structs.
% NOTE: only works if the two structs don't share fields with the same name
%
% INPUTS:
%   struct1 - struct 1 to merge
%   struct2 - struct 2 to merge
%
% OUTPUTS:
%   mergedStruct - single struct with fields from both structs
%
% CREATED: 2/11/21 - HHY
%
% UPDATED:
%   2/11/21 - HHY
%
function mergedStruct = mergeStructs(struct1, struct2)

    mergedStruct = ...
        cell2struct([struct2cell(struct1);struct2cell(struct2)],...
        [fieldnames(struct1); fieldnames(struct2)]);
end