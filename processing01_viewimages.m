clc;
clear;

addpath('D:\Arunima\Work\THI Breast Data\Data\Programs\Utils');
addpath('D:\Arunima\Work\GitRepositories\beamforming_functions');


set(0, 'defaultAxesFontSize', 20, 'defaultlineLineWidth', 2, 'defaultErrorBarLineWidth', 0.1);

%breast_details_file_name = fullfile("C:\Users\aruni\OneDrive - Johns Hopkins\patient_details.xlsx")
breast_details_file_name = fullfile("D:\Arunima\Work\ReaderStudy\patient_details_pc.xlsx");
breast_details = readtable(breast_details_file_name, 'Sheet', 'file_path');

num_files = size(breast_details, 1);
range_das = -60;
range_slsc = -60;
M_slsc = 7;
saving = 0;
maxM = 64;

for idx = 177:178%num_files

    Folder_name = cell2mat(breast_details.path(breast_details.idx == idx))
    frame_no = breast_details.frame(breast_details.idx == idx);
    file_name = sprintf('%d_layer0_idx%d_BDATA_RF.mat', frame_no, frame_no);
    complete_path = [Folder_name '\' file_name];

    disp("Loading data from " + complete_path);

    [delay_data,metadata,RxMux] = delay_US_linear('start_path', complete_path);
    [US_img,RF_sum,metadata,x_axis,z_axis] = beamformer_DAS_US_linear(delay_data,metadata,RxMux);
    metadata.US.SLSC.maxM = maxM;
    [slsc_img,~, metadata, x_axis, z_axis] = beamformer_SLSC_US_linear(delay_data, metadata, RxMux);
    slsc_img(slsc_img<0) = 0;
 
    formusimage(x_axis, z_axis, US_img, 'bmode', 'title', "B-mode")
    formusimage(x_axis, z_axis, slsc_img, 'slsc', 'title', "SLSC")
end

