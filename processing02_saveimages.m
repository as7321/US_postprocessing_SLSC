clc;
clear;

addpath('D:\Arunima\Work\THI Breast Data\Data\Programs\Utils');
addpath('D:\Arunima\Work\GitRepositories\beamforming_functions');

breast_details_file_name = fullfile("D:\Arunima\Work\ReaderStudy\patient_details_pc.xlsx");
breast_details = readtable(breast_details_file_name, 'Sheet', 'file_path');
%breast_details = readtable(breast_details_file_name, 'Sheet', 'file_pathv02');

num_files = size(breast_details, 1);
saving = 1;
maxM = 64;

% for idx = 10%213:num_files
for idx = 218% 1:num_files

    Folder_name = cell2mat(breast_details.path(breast_details.idx == idx));
    frame_no = breast_details.frame(breast_details.idx == idx);
    file_name = sprintf('%d_layer0_idx%d_BDATA_RF.mat', frame_no, frame_no);
    complete_path = [Folder_name '\' file_name];

    disp("Loading data from " + complete_path);

    [delay_data,metadata,RxMux] = delay_US_linear('start_path', complete_path);
    [US_img,RF_sum,metadata,x_axis,z_axis] = beamformer_DAS_US_linear(delay_data,metadata,RxMux);
    metadata.US.SLSC.maxM = maxM;
    [slsc_img,~, metadata, x_axis, z_axis] = beamformer_SLSC_US_linear(delay_data, metadata, RxMux);

    if saving

        disp('Saving data')
        patient_num = cell2mat(breast_details.patient(breast_details.idx == idx));
        mass_num = cell2mat(breast_details.mass(breast_details.idx == idx));
        orientation = cell2mat(breast_details.orientation(breast_details.idx == idx));

        init_path = 'D:\Arunima\Work\ReaderStudy\Data\Processed\';
        
        Bmode_path = [init_path patient_num '-' mass_num]%'\' '-' orientation]
         if ~exist(Bmode_path,'dir')
            mkdir(Bmode_path);
        end

        filename = [Bmode_path '\' orientation '_img.mat'];
        DAS = US_img;
        SLSC = slsc_img;
        save(filename, 'x_axis', 'z_axis', 'DAS', 'SLSC', 'metadata');
    end
end