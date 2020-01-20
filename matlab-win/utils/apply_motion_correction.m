function regM = apply_motion_correction(ImgM,resM,Transform,Output,isMovie)
%ImgM - moving file
%resMoving - resolution of Moving
%Transform - path to transform mat file
%Output - output file path

%% apply transform
tform = affine3d(Transform);

RM = imref3d(size(ImgM),resM(1),resM(2),resM(3));
RF = RM;
regM = imwarp(ImgM,RM,tform,'OutputView',RF);

if and(isfile(Output),isMovie==0)
    disp({['Skipping ',Output];'File already exists.';...
        'Remove the file and try again.'});
else
    for z = 1:size(ImgM,3)
        imwrite(uint16(regM(:,:,z)),Output,'WriteMode', 'append',  'Compression','none');
    end
    disp(' ')
    disp('Done')
end

end