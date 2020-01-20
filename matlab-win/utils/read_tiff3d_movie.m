function Movie = read_tiff3d_movie(ProcessFile,zslices,starttime,timepoints,PixelRegion)
% returns movie z t

tiffInfo = imfinfo(ProcessFile);  %# Get the TIFF file information
no_frame = numel(tiffInfo);    %# Get the number of images in the file
Movie.width = tiffInfo(1).Width;
Movie.height = tiffInfo(1).Height;

if isempty(zslices)
     zslices = 1;
end
Movie.zslices = zslices;
if isempty(starttime)
     starttime = 1;
end
if isempty(timepoints)
     timepoints = floor(no_frame/zslices);
     disp(['Getting first ',num2str(timepoints),' timepoints.']); 
     disp(['Throwing away ',num2str(no_frame - timepoints*zslices),' z slices.']);
end
Movie.timepoints = timepoints;

Movie.imgSeq = cell(zslices,timepoints);  %# Preallocate the cell array
if isempty(PixelRegion)
for t = 1:timepoints
    for z = 1:zslices
        iFrame = zslices*(t + starttime - 2) + z;
        Movie.imgSeq{z,t} = double(imread(ProcessFile,'Index',iFrame,'Info',tiffInfo)); % im2double ?
    end
end
else
 for t = 1:timepoints
    for z = 1:zslices
        iFrame = zslices*(t + starttime - 2) + z;
        Movie.imgSeq{z,t} = double(imread(ProcessFile,'Index',iFrame,'Info',tiffInfo,'PixelRegion',PixelRegion)); % im2double ?
    end
end   
end
end