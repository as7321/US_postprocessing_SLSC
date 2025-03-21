addpath('/Volumes/One Touch/JHU/Backup/Breast Work/THI/Programs/Utils/');
addpath('/Volumes/One Touch/JHU/Backup/GitRepositories/image_quality_metrics/utils/regions_of_interest')
location = '/Volumes/One Touch/JHU/Backup/Breast Work/Reader_study/ReaderStudy/';
breast_details_file_name = fullfile([location 'patient_details_pc.xlsx']);
mass_details = readtable(breast_details_file_name, 'Sheet', 'mass_details');
close all;
set(0, 'defaultAxesFontSize', 20, 'defaultlineLineWidth', 2, 'defaultErrorBarLineWidth', 0.1);
num_masses = size(mass_details, 1);
%idx = idx+1
removed_masses = [9, 20, 32, 33, 42, 45, 49, 53, 54, 56, 68, 87, ...
    102, 103, 105, 121, 138, 142, 154, 158, 159];
idx = 159;
folder_name = cell2mat(mass_details.mass_number(mass_details.idx == idx));
folder_path = fullfile([location 'Data/Processed/' folder_name])
if idx~=34 & idx~=36 & idx~=39 & idx~=70 & idx~=120
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
    data_rad = load([folder_path '/Sag_img.mat']);
    data_arad = load([folder_path '/Trans_img.mat']);
    data_arad.SLSC(data_arad.SLSC(:, :, :)<0) = 0;
    data_rad.SLSC(data_rad.SLSC(:, :, :)<0) = 0;
end

roi = readtable(breast_details_file_name, 'Sheet','roi');
target_desc = readtable(breast_details_file_name, 'Sheet','roi');
rows= find(roi.idx==idx);
for i = 1:length(rows)
    if strcmp(roi.Orientation(rows(i)), 'Rad')
        roi_params_rad = generateRoiParams(...
        'ellipse', ...
        'targetCenter', [...
        target_desc.TargetCenterX(rows(i)); ...
        target_desc.TargetCenterY(rows(i))], ...
        'backgroundOffset', ...
        [target_desc.BackgroundOffsetX(rows(i)); ...
        target_desc.BackgroundOffsetY(rows(i))], ...
        'targetParams', [target_desc.RadiusX(rows(i)); target_desc.RadiusY(rows(i))]);
    elseif strcmp(roi.Orientation(rows(i)), 'Arad')
        roi_params_arad = generateRoiParams(...
        'ellipse', ...
        'targetCenter', [...
        target_desc.TargetCenterX(rows(i)); ...
        target_desc.TargetCenterY(rows(i))], ...
        'backgroundOffset', ...
        [target_desc.BackgroundOffsetX(rows(i)); ...
        target_desc.BackgroundOffsetY(rows(i))], ...
        'targetParams', [target_desc.RadiusX(rows(i)); target_desc.RadiusY(rows(i))]);
    end
end

% formusimage(data_arad.x_axis, data_arad.z_axis, data_arad.DAS, 'bmode');
% hold on
% plotRoi(roi_params_arad);
% hold off
% 
% formusimage(data_arad.x_axis, data_arad.z_axis, data_arad.SLSC, 'slsc')
% hold on
% plotRoi(roi_params_arad);
% hold off
% 
% formusimage(data_rad.x_axis, data_rad.z_axis, data_rad.DAS, 'bmode');
% hold on
% plotRoi(roi_params_rad);
% hold off
% 
% formusimage(data_rad.x_axis, data_rad.z_axis, data_rad.SLSC, 'slsc')
% hold on
% plotRoi(roi_params_rad);
% hold off


figure,
subplot(2, 2, 1)
formusimage(data_arad.x_axis, data_arad.z_axis, data_arad.DAS, 'bmode', 'newfig', false, 'title', "ARAD");
hold on
%plotRoi(roi_params_arad);
hold off

subplot(2, 2, 2)
formusimage(data_arad.x_axis, data_arad.z_axis, data_arad.DAS, 'bmode', 'newfig', false, 'title', "ARAD with ROI");
hold on
plotRoi(roi_params_arad);
hold off

% subplot(2, 2, 2)
% formusimage(data_arad.x_axis, data_arad.z_axis, data_arad.SLSC, 'slsc', 'newfig', false)
% hold on
% plotRoi(roi_params_arad);
% hold off

subplot(2, 2, 3)
formusimage(data_rad.x_axis, data_rad.z_axis, data_rad.DAS, 'bmode', 'newfig', false, 'title', "RAD");
hold on
%plotRoi(roi_params_rad);
hold off

subplot(2, 2, 4)
formusimage(data_rad.x_axis, data_rad.z_axis, data_rad.DAS, 'bmode', 'newfig', false, 'title', "RAD with ROI");
hold on
plotRoi(roi_params_rad);
hold off

% subplot(2, 2, 4)
% formusimage(data_rad.x_axis, data_rad.z_axis, data_rad.SLSC, 'slsc', 'newfig', false)
% hold on
% plotRoi(roi_params_rad);
% hold off
