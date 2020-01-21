function ants_rigid_registration(movingImageFile, movingMaskFile,...
    fixedImageFile, fixedMaskFile, outputFile,writeImg,ants_exe_path)

% where ants exe are located
if isempty(ants_exe_path)
    ants_exe_path = ['D:\Code\repos\spim_gcmp_processing\',...
        'matlab-win\utils\ANTs_2.1.0_Windows'];
end
disk = ants_exe_path(1);

% usually 0.25 is enough, increase it for small images ( maybe 0.4)
SamplingRate = '0.25'; 

% wether or not to output an image with the transform
if writeImg
    outputImg = [',',outputFile,'.nii.gz]'];
else
    outputImg = ']';
end
    if (isempty(movingMaskFile)||isempty(fixedMaskFile))
                command = [disk,': &&',... % Folder with antsRegistration.exe 
            'cd ',ants_exe_path,' &&',... % Folder with antsRegistration.exe 
            ' antsRegistration.exe',... % Folder with antsRegistration.exe 
            '  --dimensionality 3',...
            '  --float 0',...
            ' --output [',outputFile,outputImg,...
            ' --interpolation Linear',...
            ' --winsorize-image-intensities [0.005,0.995]',...
            ' --use-histogram-matching 0',...
            ' --transform Rigid[0.1]',...
            ' --metric MI[',fixedImageFile,',',movingImageFile,',1,32,Regular,',SamplingRate,']',...
            ' --convergence [1000x500x250x100,1e-6,10]',...
            ' --shrink-factors 8x4x2x1',...
            '  --smoothing-sigmas 3x2x1x0vox '];
    else
        command = ['d: &&',... % Folder with antsRegistration.exe 
            'cd ',ants_exe_path,' &&',... % Folder with antsRegistration.exe 
            ' antsRegistration.exe',... % Folder with antsRegistration.exe 
            '  --dimensionality 3',...
            '  --float 0',...
            ' --output [',outputFile,outputImg,...
            ' --interpolation Linear',...
            ' --winsorize-image-intensities [0.005,0.995]',...
            ' --use-histogram-matching 0',...
            ' --transform Rigid[0.1]',...
            ' --metric MI[',fixedImageFile,',',movingImageFile,',1,32,Regular,',SamplingRate,']',...
            ' --convergence [1000x500x250x100,1e-6,10]',...
            ' --shrink-factors 8x4x2x1',...
            '  --smoothing-sigmas 3x2x1x0vox ',...
            ' -x [',fixedMaskFile,',',movingMaskFile,']'];
    end
            dos(command,'-echo')
end