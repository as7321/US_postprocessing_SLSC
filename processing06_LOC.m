clc;
clear;

addpath('F:\JHU\Backup\Breast Work\THI\Programs\Utils');
addpath('F:\JHU\Backup\GitRepositories\beamforming_functions');
addpath('F:\JHU\Backup\GitRepositories\image_quality_metrics\utils\regions_of_interest')


set(0, 'defaultAxesFontSize', 20, 'defaultlineLineWidth', 2, 'defaultErrorBarLineWidth', 0.1);

%breast_details_file_name = fullfile("C:\Users\aruni\OneDrive - Johns Hopkins\patient_details.xlsx")
breast_details_file_name = fullfile("D:\Arunima\Work\ReaderStudy\patient_details_pc.xlsx");
%breast_details = readtable(breast_details_file_name, 'Sheet', 'file_path');
breast_details = readtable(breast_details_file_name, 'Sheet', 'file_pathv02');
target_desc = readtable(breast_details_file_name, 'Sheet','roi');

num_files = size(breast_details, 1)
writing =1;
maxM = 64;
units = 'mm';

for idx = [1]%43:num_files

    Folder_name = cell2mat(breast_details.path(breast_details.idx == idx))
    frame_no = breast_details.frame(breast_details.idx == idx);
    file_name = sprintf('%d_layer0_idx%d_BDATA_RF.mat', frame_no, frame_no);
    complete_path = [Folder_name '\' file_name];

    disp("Loading data from " + complete_path);
    orientation = breast_details.orientation(breast_details.idx == idx)
    if strcmp(orientation, 'Trans')
        orientation = 'Arad';
    elseif strcmp(orientation, 'Sag')
        orientation = 'Rad';
    end

    [delay_data,metadata,RxMux] = delay_US_linear('start_path', complete_path);
    [US_img,~,metadata,~,~] = beamformer_DAS_US_linear(delay_data,metadata,RxMux);
    metadata.US.SLSC.maxM = maxM;
    [slsc_img,cc_img, metadata, x_axis, z_axis] = beamformer_SLSC_US_linear(delay_data, metadata, RxMux);
    slsc_img(slsc_img<0) = 0;

    patient_number = cell2mat(breast_details.patient(breast_details.idx==idx));
    if length(patient_number) == 2
        patient_number_new = patient_number(1) + "00" + patient_number(2:end);
    elseif length(patient_number) == 3
        patient_number_new = patient_number(1) + "0" + patient_number(2:end);
    else
        patient_number_new = patient_number;
    end

    mass = cell2mat(breast_details.mass(breast_details.idx==idx));
    mass_detail = patient_number_new + "-" + mass
    rows= find(strcmp(target_desc.mass_number, mass_detail));
    for i = 1:length(rows)
        if strcmp(target_desc.Orientation(rows(i)), orientation)
            correct_row = rows(i);
            roi_params = generateRoiParams(...
                'ellipse', ...
                'targetCenter', [...
                target_desc.TargetCenterX(rows(i)); ...
                target_desc.TargetCenterY(rows(i))], ...
                'backgroundOffset', ...
                [target_desc.BackgroundOffsetX(rows(i)); ...
                target_desc.BackgroundOffsetY(rows(i))], ...
                'targetParams', [target_desc.RadiusX(rows(i)); target_desc.RadiusY(rows(i))]);
        elseif strcmp(target_desc.Orientation(rows(i)), orientation)
            correct_row = rows(i);
            roi_params = generateRoiParams(...
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

    formusimage(x_axis, z_axis, US_img, "bmode");
         hold on;
         plotRoi(roi_params);
         hold off;
    
         formusimage(x_axis, z_axis, slsc_img, "slsc");
         hold on;
         plotRoi(roi_params);
         hold off;

    [mu_t, mu_b, sig_t, sig_b, region_t, region_b, mask_t, mask_b] = extractRoi(...
        units, slsc_img, roi_params, ...
        'xAxis', x_axis, ...
        'zAxis', z_axis);

    [cc.target, cc.background] = getRoiCC(cc_img, mask_t, mask_b);
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
