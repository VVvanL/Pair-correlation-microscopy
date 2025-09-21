function [Images,FileName,PathName]=opentif()
% This will open multiple tiff files, and create cell arrays with the image
% data, another cell array with the filnames 

dialog_title = 'Locate the file';
[FileName,PathName] = uigetfile('*.*',dialog_title,'MultiSelect','On'); 

if ischar(FileName)
    tmp=FileName;
    FileName=cell(1);
    FileName{1}=tmp;
end
L=length(FileName);
Images=cell(L,1);
for i=1:L
fileID = strcat(PathName,FileName{i});
tiff_data = bfopen(fileID);
data_image = tiff_data{1,1}{1,1};
Images{i}=(data_image);
end 

end 




