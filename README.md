### SPIM-GCaMP-CaImAn data pipeline under developent
Added so far:
+ ANTs registration in matlab under windows , STATUS: testing ...

To test - fill in all the Input parts in the PIPELINE_registration.m and follow the instructions. 
PIPELINE_registration.m is the only file you need, keep away from the rest ;) 

Send me the errors if you have any ... 

Oh... and I forgot to make a variable for the filder where ants executables are ... can you please set by hand for now? 
To do so : 
go into the ants_rigid_registration function in utils and change 

ants_exe_path = ['D:\Code\repos\spim_gcmp_processing\',...
    'matlab-win\utils\ANTs_2.1.0_Windows']; 
    
to the folder where you have this folder. 
Also, on line 17: 

if (isempty(movingMaskFile)||isempty(fixedMaskFile))
-- HERE-->            command = ['d: &&',... % Folder with antsRegistration.exe 

change the small letter d to the disk letter that you are using 
(I was on D: , so d .. if you are on F: put f there, etc..) 
