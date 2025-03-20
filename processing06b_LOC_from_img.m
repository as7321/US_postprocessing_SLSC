clc;
clear;

addpath('F:\JHU\Backup\Breast Work\THI\Programs\Utils');
addpath('F:\JHU\Backup\GitRepositories\beamforming_functions');
addpath('F:\JHU\Backup\GitRepositories\image_quality_metrics\utils\regions_of_interest')


set(0, 'defaultAxesFontSize', 20, 'defaultlineLineWidth', 2, 'defaultErrorBarLineWidth', 0.1);

%breast_details_file_name = fullfile("C:\Users\aruni\OneDrive - Johns Hopkins\patient_details.xlsx")
%breast_details_file_name = fullfile("D:\Arunima\Work\ReaderStudy\patient_details_pc.xlsx");
%breast_details = readtable(breast_details_file_name, 'Sheet', 'file_path');
%breast_details = readtable(breast_details_file_name, 'Sheet', 'file_pathv02');


location = 'D:\Arunima\Work\ReaderStudy\';
breast_details_file_name = fullfile([location 'patient_details_pc.xlsx']);
mass_details = readtable(breast_details_file_name, 'Sheet', 'mass_details');
target_desc = readtable(breast_details_file_name, 'Sheet','roi');
num_masses = size(mass_details, 1);

%num_files = size(breast_details, 1)
writing =0;
maxM = 64;
units = 'mm';

for idx = [5]%:num_masses
    folder_name = cell2mat(mass_details.mass_number(mass_details.idx == idx));
    folder_path = fullfile([location 'Data\Processed\' folder_name]);
    [data_arad, data_rad] = load_breast_data(folder_path, idx);  
    rows= find(target_desc.idx==idx);
    for i = 1:length(rows)
        if strcmp(target_desc.Orientation(rows(i)), 'Rad') %either Rad or Trans
            roi_params_rad = generateRoiParams(...
                'ellipse', ...
                'targetCenter', [...
                target_desc.TargetCenterX(rows(i)); ...
                target_desc.TargetCenterY(rows(i))], ...
                'backgroundOffset', ...
                [target_desc.BackgroundOffsetX(rows(i)); ...
                target_desc.BackgroundOffsetY(rows(i))], ...
                'targetParams', [target_desc.RadiusX(rows(i)); target_desc.RadiusY(rows(i))]);
        elseif strcmp(target_desc.Orientation(rows(i)), 'Arad') %Arad or Sag
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

    formusimage(data_rad.x_axis, data_rad.z_axis, data_rad.DAS, "bmode");
         hold on;
         plotRoi(roi_params_rad);
         hold off;
    
         formusimage(data_rad.x_axis, data_rad.z_axis, data_rad.SLSC, "slsc");
         hold on;
         plotRoi(roi_params_rad);
         hold off;

    [mu_t, mu_b, sig_t, sig_b, region_t, region_b, mask_t, mask_b] = extractRoi(...
        units, data_rad.SLSC, roi_params_rad, ...
        'xAxis', data_rad.x_axis, ...
        'zAxis', data_rad.z_axis);

    [cc.target, cc.background] = getRoiSLSC(data_rad.SLSC, mask_t, mask_b);
    mean_cc.target(1) = 1;
    mean_cc.background(1) = 1;
    mean_cc.target(2:65) = mean(cc.target);
    mean_cc.background(2:65) = mean(cc.background);

    LOC_values = [mean_cc.target(2), mean_cc.background(2)]

    if writing
        destination_file = readtable(breast_details_file_name, 'Sheet','LOC');
        destination_cell = "D" + num2str(correct_row+1);
        writematrix(LOC_values, breast_details_file_name, 'Sheet', 'LOC', 'range', destination_cell);
    end
end
