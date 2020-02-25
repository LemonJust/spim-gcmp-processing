function Img = read_tiff3d_timepont(ProcessFiles,tp_lookup,tp_to_read,PixelRegion)
% tp_to_read: returns one volume at time starttime
% tp_lookup: array with file and frame in that file for each timepoint
% PixelRegion: rectangle coordinates - only read stuff inside it

file_start = tp_lookup(tp_to_read,1,1);
tiffInfo = imfinfo(ProcessFiles{file_start});  %# Get the TIFF file information
[timepoints,zslices,~] = size(tp_lookup);

Img.nFrame = zslices;
Img.zslices = zslices;
Img.width = tiffInfo(1).Width;
Img.height = tiffInfo(1).Height;
Img.img = uint16(zeros(Img.height,Img.width,Img.nFrame));

if tp_to_read>timepoints
    error('Timepoint to read is not in the recording.')
end

% get all the region in XY
if isempty(PixelRegion)
    for z = 1:zslices
        iFile = tp_lookup(tp_to_read,z,1);
        tiffInfo = imfinfo(ProcessFiles{iFile});
        iFrame = tp_lookup(tp_to_read,z,2);
        Img.img(:,:,z) = uint16(imread(ProcessFiles{iFile},...
            'Index',iFrame,'Info',tiffInfo)); % im2double ?
    end
% get the PixelRegion only
else
    for z = 1:zslices
        iFile = tp_lookup(tp_to_read,z,1);
        tiffInfo = imfinfo(ProcessFiles{iFile});
        iFrame = tp_lookup(tp_to_read,z,2);
        Img.img(:,:,z) = uint16(imread(ProcessFiles{iFile},...
            'Index',iFrame,'Info',tiffInfo,'PixelRegion',PixelRegion)); % im2double ?
    end 
end
end