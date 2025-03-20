% addpath('D:\Arunima\Work\THI Breast Data\Data\Programs\Utils\')
% addpath('D:\Arunima\Work\ReaderStudy\Codes\ultils')
% addpath('D:\Arunima\Work\GitRepositories\image_quality_metrics\utils\regions_of_interest')
% addpath(genpath(fullfile('D:\Arunima\Work\GitRepositories\image_quality_metrics\snr')));
% addpath(genpath(fullfile('D:\Arunima\Work\GitRepositories\image_quality_metrics\contrast')));
% addpath(genpath(fullfile('D:\Arunima\Work\GitRepositories\image_quality_metrics\cnr')));
% addpath(genpath(fullfile('D:\Arunima\Work\GitRepositories\image_quality_metrics\gcnr')));
% addpath(genpath(fullfile('D:\Arunima\Work\GitRepositories\image_quality_metrics\utils\histograms')));

addpath('/Volumes/One Touch/JHU/Backup/Breast Work/THI/Programs/Utils/');
addpath('/Volumes/One Touch/JHU/Backup/Breast Work/Reader_study/ReaderStudy/Codes/ultils')
addpath('/Volumes/One Touch/JHU/Backup/GitRepositories/image_quality_metrics/utils/regions_of_interest')
addpath(genpath(fullfile('/Volumes/One Touch/JHU/Backup/GitRepositories/image_quality_metrics/snr')));
addpath(genpath(fullfile('/Volumes/One Touch/JHU/Backup/GitRepositories/image_quality_metrics/contrast')));
addpath(genpath(fullfile('/Volumes/One Touch/JHU/Backup/GitRepositories/image_quality_metrics/cnr')));
addpath(genpath(fullfile('/Volumes/One Touch/JHU/Backup/GitRepositories/image_quality_metrics/gcnr')));
addpath(genpath(fullfile('/Volumes/One Touch/JHU/Backup/GitRepositories/image_quality_metrics/utils/histograms')));
%location = 'D:\Arunima\Work\ReaderStudy\';
location = '/Volumes/One Touch/JHU/Backup/Breast Work/Reader_study/ReaderStudy/';
breast_details_file_name = fullfile([location 'patient_details_pc.xlsx']);
mass_details = readtable(breast_details_file_name, 'Sheet', 'mass_details');
target_desc = readtable(breast_details_file_name, 'Sheet','roi');
num_masses = size(mass_details, 1);
M_slsc = 7;
writing =0;

for idx = [1]%:num_masses
    folder_name = cell2mat(mass_details.mass_number(mass_details.idx == idx));
    folder_path = fullfile([location 'Data/Processed/' folder_name]);
    [data_arad, data_rad] = load_breast_data(folder_path, idx);  
    rows= find(target_desc.idx==idx);
    for i = 1:length(rows)
        if strcmp(target_desc.Orientation(rows(i)), 'Rad')
            roi_params_rad = generateRoiParams(...
                'ellipse', ...
                'targetCenter', [...
                target_desc.TargetCenterX(rows(i)); ...
                target_desc.TargetCenterY(rows(i))], ...
                'backgroundOffset', ...
                [target_desc.BackgroundOffsetX(rows(i)); ...
                target_desc.BackgroundOffsetY(rows(i))], ...
                'targetParams', [target_desc.RadiusX(rows(i)); target_desc.RadiusY(rows(i))]);
        elseif strcmp(target_desc.Orientation(rows(i)), 'Arad')
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

[cnr.das.arad, snr.das.arad, contrast.das.arad, gcnr.das.arad] = computeimagingmetrics(data_arad.DAS, ...
        roi_params_arad, data_arad.x_axis, data_arad.z_axis);
[cnr.slsc.arad, snr.slsc.arad, contrast.slsc.arad, gcnr.slsc.arad] = computeimagingmetrics(data_arad.SLSC(:, :, 7), ...
        roi_params_arad, data_arad.x_axis, data_arad.z_axis);
[cnr.das.rad, snr.das.rad, contrast.das.rad, gcnr.das.rad] = computeimagingmetrics(data_rad.DAS, ...
        roi_params_rad, data_rad.x_axis, data_rad.z_axis);
[cnr.slsc.rad, snr.slsc.rad, contrast.slsc.rad, gcnr.slsc.rad] = computeimagingmetrics(data_rad.SLSC(:, :, 7), ...
        roi_params_rad, data_rad.x_axis, data_rad.z_axis);

  if writing
      disp(idx)
        destination_file = readtable(breast_details_file_name, 'Sheet','CNR');
        total_rows = 1:size(destination_file, 1);
        row = total_rows(destination_file.idx == idx) + 1;
        destination_cell = "C" + num2str(row);
        gcnr_values = [gcnr.das.arad, gcnr.das.rad, gcnr.slsc.arad, gcnr.slsc.rad];
        writematrix(gcnr_values, breast_details_file_name, 'Sheet', 'gCNR', 'range', destination_cell);
        cnr_values = [cnr.das.arad, cnr.das.rad, cnr.slsc.arad, cnr.slsc.rad];
        writematrix(cnr_values, breast_details_file_name, 'Sheet', 'CNR', 'range', destination_cell);
        contrast_values = [contrast.das.arad, contrast.das.rad, contrast.slsc.arad, contrast.slsc.rad];
        writematrix(contrast_values, breast_details_file_name, 'Sheet', 'Contrast', 'range', destination_cell);
        snr_values = [snr.das.arad, snr.das.rad, snr.slsc.arad, snr.slsc.rad];
        writematrix(snr_values, breast_details_file_name, 'Sheet', 'SNR', 'range', destination_cell);
    end

end
