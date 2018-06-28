function [fileName, pathName, filterIndex] = loadFileDialog(fileExtensions, dialogTitle, startPath, multiselect, selectmode)
if nargin == 4
    multiselectmode = true;
else
    multiselectmode = false;
end


if multiselectmode
    [fileName, pathName, filterIndex] = uigetfile(fileExtensions, dialogTitle,...
        startPath, multiselect, selectmode);
else
    [fileName, pathName, filterIndex] = uigetfile(fileExtensions, dialogTitle, startPath);
end

if filterIndex == 0
    return
end

end

