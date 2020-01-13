function apply_transform(PathM,resM,PathF,resF,Transform,Output) % path to the mat file including the filename
%PathM - path to moving file, can be nifti of tif
%resM - resolution of Moving
%PathF - path to fixed file, should be tif 
%Transform - transform matrix 4D, should end with 0001
%Output - output file path, should be tif

%% load moving file
% *.tif
if (PathM(end) == 'f')
ImgM = read_tiff3d(PathM,0,[],[]);
ImgM = ImgM.img;
end
% *.nii or *.nii.gz
if or((PathM(end) == 'i'),(PathM(end) == 'z'))
ImgM = read_nii3d(PathM);
ImgM = ImgM.img;
end

%% get fixed file info
tiffInfo = imfinfo(PathF);  %# Get the TIFF file information
no_frameF = numel(tiffInfo);   %# Get the number of z slices
widthF = tiffInfo(1).Width;
heightF = tiffInfo(1).Height;
 
%% apply transform 
tform = affine3d(Transform);

RM = imref3d(size(ImgM),resM(1),resM(2),resM(3));
RF = imref3d([heightF,widthF,no_frameF],resF(1),resF(2),resF(3));
regM = imwarp(ImgM,RM,tform,'OutputView',RF);

%% write transformed image as tif  
for z = 1:no_frameF
imwrite(uint16(regM(:,:,z)),Output,'WriteMode', 'append',  'Compression','none');
end
disp(' ')
disp('Done')
end