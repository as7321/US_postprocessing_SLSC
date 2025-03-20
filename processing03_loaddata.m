addpath('/Volumes/One Touch/JHU/Backup/Breast Work/THI/Programs/Utils/');
addpath('/Volumes/One Touch/JHU/Backup/Breast Work/Reader_study/ReaderStudy/Codes/utils')
location = '/Volumes/One Touch/JHU/Backup/Breast Work/Reader_study/ReaderStudy/';
breast_details_file_name = fullfile([location 'patient_details_pc.xlsx']);
close all
mass_details = readtable(breast_details_file_name, 'Sheet', 'mass_details');
num_masses = size(mass_details, 1);
idx = 33;
%idx = idx - 1
%for idx = 10%:num_masses
    folder_name = cell2mat(mass_details.mass_number(mass_details.idx == idx));
    folder_path = fullfile([location 'Data/Processed/' folder_name])
 if idx~=34 & idx~=36 & idx~=39 & idx~=68 & idx~=118
    data_rad = load([folder_path '/Rad_img.mat']);
    data_arad = load([folder_path '/Arad_img.mat']);
    data_arad.SLSC(data_arad.SLSC(:, :, :)<0) = 0;
    data_rad.SLSC(data_rad.SLSC(:, :, :)<0) = 0;
elseif idx == 34
    data_rad = load([folder_path '/Rad_img.mat']);
    data_arad = load([folder_path '/Rad_img.mat']);
    data_arad.SLSC(data_arad.SLSC(:, :, :)<0) = 0;
    data_rad.SLSC(data_rad.SLSC(:, :, :)<0) = 0;
elseif idx == 36
    data_rad = load([folder_path '/Arad_img.mat']);
    data_arad = load([folder_path '/Arad_img.mat']);
    data_arad.SLSC(data_arad.SLSC(:, :, :)<0) = 0;
    data_rad.SLSC(data_rad.SLSC(:, :, :)<0) = 0;
else
    data_rad = load([folder_path '\Sag_img.mat']);
    data_arad = load([folder_path '\Trans_img.mat']);
    data_arad.SLSC(data_arad.SLSC(:, :, :)<0) = 0;
    data_rad.SLSC(data_rad.SLSC(:, :, :)<0) = 0;
end
        formusimage(data_arad.x_axis, data_arad.z_axis, data_arad.DAS, 'bmode');
        formusimage(data_arad.x_axis, data_arad.z_axis, data_arad.SLSC, 'slsc')
        formusimage(data_rad.x_axis, data_rad.z_axis, data_rad.DAS, 'bmode');
        formusimage(data_rad.x_axis, data_rad.z_axis, data_rad.SLSC, 'slsc')
%end
