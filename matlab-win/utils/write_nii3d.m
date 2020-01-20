function write_nii3d(img,filename,header,nBit,resolution)
% writes volume into nifti
% saving it in the same position as the original tiff
% Change datattype, resolution as needed
% space units are set to Millimeter do avoid ITK crashes

if isempty(header)
    header = load('D:\Code\TR01\Utils\niftiInfo_channels_bin221');
end
img = permute(img,[2 1 3]);
header = modifyHeader(header,class(img),getSize(img),size(img),nBit,resolution);
niftiwrite(img,filename,header.info);
disp('Done');
end

function header = modifyHeader(header,classVolume,sizeBit,sizeVolume,nBit,resolution)
header.info.Filesize = sizeBit;
header.info.BitsPerPixel = nBit;
header.info.Datatype = classVolume;
header.info.ImageSize = sizeVolume;
header.info.PixelDimensions = resolution;
header.info.SpaceUnits = 'Millimeter';
end

% Code by Mario Reutter from
% https://www.mathworks.com/matlabcentral/answers/14837-how-to-get-size-of-an-object
function [ bytes ] = getSize( variable )
props = properties(variable); 
if size(props, 1) < 1, bytes = whos(varname(variable)); bytes = bytes.bytes;
else %code of Dmitry
  bytes = 0;
  for ii=1:length(props)
      currentProperty = getfield(variable, char(props(ii)));
      s = whos(varname(currentProperty));
      bytes = bytes + s.bytes;
  end
end
end

function [ name ] = varname( ~ )
name = inputname(1);
end

