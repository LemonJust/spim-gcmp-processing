function Img = read_tiff3d_movie_timepont(ProcessFile,zslices,starttime,PixelRegion)
% starttime: returns one volume at time starttime
% zslices: number of zslices in one whole vollume
% PixelRegion: rectangle coordinates - only read stuff inside it 

tiffInfo = imfinfo(ProcessFile);  %# Get the TIFF file information
Img.nFrame = zslices; 
Img.width = tiffInfo(1).Width;
Img.height = tiffInfo(1).Height;
Img.img = uint16(zeros(Img.height,Img.width,Img.nFrame));
timepoints = 1;

if isempty(zslices)
     zslices = 1;
end
Img.zslices = zslices;
if isempty(starttime)
     starttime = 1;
end

if isempty(PixelRegion)
for t = 1:timepoints
    for z = 1:zslices
        iFrame = zslices*(t + starttime - 2) + z;
        Img.img(:,:,z) = uint16(imread(ProcessFile,...
            'Index',iFrame,'Info',tiffInfo)); % im2double ?
    end
end
else
 for t = 1:timepoints
    for z = 1:zslices
        iFrame = zslices*(t + starttime - 2) + z;
        Img.img(:,:,z) = uint16(imread(ProcessFile,...
            'Index',iFrame,'Info',tiffInfo,'PixelRegion',PixelRegion)); % im2double ?
    end
end   
end
end