%% motion correction
% this is a test to see if in generall ants works ok for the 3D motion
% correction with our data. Does it do well? Does it take forever? what do
% we need to tune...

% by Anna N. Jan 2020
%% Input 1 : Preparation

% the path to the folder with all the code for the motion correction
code_path = 'D:\Code\repos\spim_gcmp_processing\';

% MainFolder : subfolder 'registered' will be created here and registration
% results will be saved in it
main_folder = 'D:\Code\repos\spim_gcmp_processing';

% MainFolder : the tif file with the movie for the motion correction
process_file = [main_folder,'\data\test_downsampled.tif'];

% resolution : imaging resolution in xyz in micron
resolution = [1.74 1.74 5];

% nBit : bit depth of the tif image, probably 16 
nBit = 16;

% zslices : number of z slices in one full volume, your stack can have some
% extra z slices at the end, but for now I assume that it STARTS at the
% first slice of a whole volume.
zslices = 52;

% *_placeholder : nifti files created during the registration because ants
% (at least in a form of exe ...) needs a path to a nifti file
moving_placeholder = [main_folder,'\data\temp_moving.nii'];
fixed_placeholder = [main_folder,'\data\temp_fixed.nii'];

% nothing to write here, 
% this one checks if the file you entered really exists 
% will throw an error if there's no file
[no_frame,timepoints] = validate_file(process_file,zslices);
%% Input 2: Registration

% target_t: choose the target time point,
% everything will be ergistered to it
target_t = 1;

% timepoints_to_register :
% by default (when timepoints_to_register is left empty : [] )
% it will run registration for all the timepoints in the file
%
% if you provide timepoints_to_register = [2] or 2:4 or [2 16 42]
% only these timepoints will be registered to the target_t:
% 2 or 2, 3, 4 or 2, 16 and 42 correspondingly
%
% it might be a good idea at the begining to register only the "worst"
% frame or just a couple of frames to get the idea of how long it takes
timepoints_to_register = [2,3,9];

% nothing to write here, 
% this one checks if the timepoints you entered are valid 
% resets timepoints_to_register if needed
timepoints_to_register = validate_reg(timepoints,target_t,...
    timepoints_to_register)
%% Input 3: Check results

% timepoints_to_show: 
% by default (when timepoints_to_show is left empty : [] )
% WON'T save any images. 
%
% if you provide timepoints_to_show = [2] or 2:4 or [2 16 42]
% only these timepoints will be saved to disk 
% It means that only these transformed images will be generated , 
% it doesn't affect the transforms - they are always saved.
%
% set to timepoints_to_show = timepoints_to_register
% if you want all the registered images saved to disk 
timepoints_to_show = 9;

% do you want these images to be saved as a movie or as individual volumes?
% movie = 1 , individual volumes = 0
is_movie = 1;

% nothing to write here, 
% this one checks if the timepoints_to_show you entered are valid 
% resets timepoints_to_show if needed
timepoints_to_show = validate_show(timepoints_to_register,timepoints_to_show)
%% Run 1: prepares files etc. 
% Everything here should just work, no need to change stuff here


% add all the functions
addpath(genpath([code_path,'matlab-win']));

% HeaderFile : location of the template header file for saving nifti files
header_file = [code_path,'matlab-win\utils\niftiInfo_channels_bin221'];
header = load(header_file);

% create folder for registration results
reg_folder = [main_folder,'\registered\'];
mkdir(reg_folder);

% create folder for ants transforms
ants_out_folder = [reg_folder,'\0GenericAffine\'];
mkdir(ants_out_folder);


%% Run 2: Registration

% write down the target_t to the disk as nifti
Img = read_tiff3d_movie_timepont(process_file,52,target_t,[]);
write_nii3d(Img.img,fixed_placeholder,header,16,resolution);

% register all timepoints to the target
transform = register_in_loop(timepoints,...
    target_t,timepoints_to_register,...
    process_file,header,zslices,resolution,nBit,...
    moving_placeholder,fixed_placeholder,ants_out_folder);

transform_file = [reg_folder,'mc_transforms_to_t',num2str(target_t),'.mat'];
save(transform_file,'transform');

%% Run 3 : Check results - save transformed images to disk
% this can be done after the registration or anytime later 
% in which case you will need to load the transforms by running 
% load(transform_file);
ouput_name = [reg_folder,'mc_to_t',num2str(target_t),'_Rigid'];

if is_movie
    % checks that the file doesn't already exist
    % if it does adds '_new' to the end
    ouput_file = validate_filename(ouput_name);
end

for t = timepoints_to_show
    disp(['Working on ',num2str(t)]);
    
    if ~is_movie
        ouput_file = [ouput_name,'_t',num2str(t)];
        ouput_file = validate_filename(ouput_file);
    end
    
    disp(string(['Saving to ',ouput_file]));

    Img = read_tiff3d_movie_timepont(process_file,zslices,t,[]);
    apply_motion_correction(Img.img,resolution,transform{t},...
        ouput_file,is_movie);
end


%% HELPER FUNCTIONS: *******************************************

function [no_frame,timepoints] = validate_file(process_file,zslices)
% Get the TIFF file information 
% returns number of frames in the file

tiffInfo = imfinfo(process_file);
no_frame = numel(tiffInfo);

% get how many full timepoints there are
timepoints = floor(no_frame/zslices);

disp(['Getting first ',num2str(timepoints),' timepoints.']);
disp(['Throwing away ',num2str(no_frame - timepoints*zslices),' z slices.']);

end

function timepoints_to_register = validate_reg(timepoints,...
    target_t,timepoints_to_register)
% checks if the timepoints values entered are valid
% if timepoints_to_register are outside the timepoints range - 
% keeps only the ones that are in

if target_t>timepoints
    disp(string(['OOPS! target_t ',num2str(target_t),' is too large,',...
        ' only have ',num2str(timepoints),' timepoints in file.']));
    disp("Resetting target_t to 1.");
    target_t = 1;
end
if any(timepoints_to_register>timepoints)
    disp("OOPS! Some timepoints_to_register ");
    disp("are larger than the total number of timepoints");
    disp("and will be ignored ! ");
    good_tp = timepoints_to_register<timepoints;
    timepoints_to_register = timepoints_to_register(good_tp);
end
end

function timepoints_to_show = validate_show(timepoints_to_register,...
    timepoints_to_show)
% checks if the timepoints values entered are valid
isreg = ismember(timepoints_to_show,timepoints_to_register);
if ~all(isreg)
    disp("OOPS! Some timepoints_to_show ");
    disp("are not in timepoints_to_register");
    disp("and will be ignored ! ");
    timepoints_to_show = timepoints_to_show(isreg);
end

end

function ouput_file = validate_filename(ouput_file)
% to validate the filename you need to validate the filename
check_file = [ouput_file,'.tif'];
if isfile(check_file)
    ouput_file = [ouput_file,'_new'];
    ouput_file = validate_filename(ouput_file);
    disp("File already exists! Adding '_new' and trying again...");
else
    ouput_file = check_file;
end
end

function transform = register_in_loop(timepoints,...
    target_t,timepoints_to_register,...
    process_file,header,zslices,resolution,nBit,...
    moving_placeholder,fixed_placeholder,ants_out_folder)
% performs the registration of the selected timepoints

    % prepare transforms for full timepoints
    % the ones not calculated will remain empty
    transform = cell(timepoints,1);
    
    % run for all the timepoints
    for t = 1:timepoints
        if t == target_t
            transform{t} = eye(4);
        else
            if or(ismember(t,timepoints_to_register),...
                    isempty(timepoints_to_register))
                
                % read and write t timepoint to nifti file
                Img = read_tiff3d_movie_timepont(process_file,zslices,t,[]);
                write_nii3d(Img.img,moving_placeholder,header,nBit,resolution)
                
                % run registration
                ouput_file = ['t',num2str(t),'_to_t',num2str(target_t),'_Rigid'];
                ouput_file = [ants_out_folder,ouput_file];
                ants_rigid_registration(moving_placeholder, [],...
                    fixed_placeholder, [],...
                    ouput_file,0);
                
                % record transform
                ouput_transform = [ouput_file,'0GenericAffine'];
                transform{t} = ants2affine(ouput_transform);
                
            end
        end
    end
end


















