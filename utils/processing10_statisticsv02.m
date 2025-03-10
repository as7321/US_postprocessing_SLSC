clc
clear
addpath('/Users/arunimasharma/Desktop/Work/JHU/Codes/utils');
addpath('/Volumes/One Touch/JHU/Backup/Breast Work/Reader_study/ReaderStudy/Codes/ultils');

set(0, 'defaultAxesFontSize', 20, 'defaultlineLineWidth', 2, 'defaultErrorBarLineWidth', 0.1);
c_map = [76, 109, 124;180, 200, 208; 33, 158, 188; 142, 202, 230;76, 133, 13;145, 200, 26;188, 110, 16; 239, 161, 67 ; 204, 151, 0; 255, 201, 54 ]/255;
location = '/Volumes/One Touch/JHU/Backup/Breast Work/Reader_study/ReaderStudy/';
sheet_location = '/Users/arunimasharma/Desktop/Work/JHU/reader_study_paper/data/'
reader_names = ["Lisa.xlsx","Emily.xlsx","Eni.xlsx","Kelly.xlsx","Babita.xlsx","Joanna.xlsx"];
%sheet_name = reader_names(2);
writing = 0;
simple_cysts_mass_number = ["P010-Mass1", "P033-Mass2", "P035-Mass2", "P071-Mass2", "P075-Mass1", "P079-Mass2", "P080-Mass3", "P108-Mass3", "P108-Mass4", "P113-Mass3", "P118-Mass1", "P129-Mass1"];

for reader = 1:6
    sheet_name = reader_names(reader)
    target_desc_file_name = fullfile([location 'patient_details_pc.xlsx']);
    mass_details = readtable(target_desc_file_name, 'Sheet', 'mass_details');
    reader_study_results = fullfile([sheet_location + sheet_name]);
    study_file = readtable(reader_study_results);
    num_masses = height(study_file);
    count_solid =0;
    count_birads3 = 0;
    count_fluids = 0;
    count_mixed = 0;
    count_removed =0;
    [TP_pre, FP_pre, TN_pre, FN_pre, TP_post, FP_post, TN_post, FN_post] = deal(0);

    for i = 1:num_masses
        if strcmp(cell2mat(study_file.Category_truth_edited(i)), 'solid')
            count_solid = count_solid +1;
            if study_file.BIRADS_pre(i) == 5 || study_file.BIRADS_pre(i) == 4
                TN_pre = TN_pre + 1;
            else
                FP_pre = FP_pre + 1;
            end
            if study_file.BIRADS_post(i) == 5 || study_file.BIRADS_post(i) == 4
                TN_post = TN_post + 1;
            else
                FP_post = FP_post + 1;
            end
        end
        if strcmp(cell2mat(study_file.Category_truth_edited(i)), 'fluid') && ~ismember(study_file.Mass_number(i), simple_cysts_mass_number)
            count_fluids = count_fluids +1;
            if study_file.BIRADS_pre(i) == 2 || study_file.BIRADS_pre(i) == 3
                TP_pre = TP_pre + 1;
            else
                FN_pre = FN_pre + 1;
            end
            if study_file.BIRADS_post(i) == 2 || study_file.BIRADS_post(i) == 3
                TP_post = TP_post + 1;
            else
                FN_post = FN_post + 1;
            end
        end
        if strcmp(cell2mat(study_file.Category_truth_edited(i)), 'mixed')
            count_mixed = count_mixed +1;
        end
        if strcmp(cell2mat(study_file.Category_truth_edited(i)), 'unknown')
            count_birads3 = count_birads3 +1;
        end
        if strcmp(cell2mat(study_file.Category_truth_edited(i)), 'removed')
            count_removed = count_removed +1;
            %disp(study_file.Mass_number(i))
        end
    end
    sensitivity_pre = TP_pre/(TP_pre + FN_pre);
    sensitivity_post = TP_post/(TP_post + FN_post);
    specificity_pre = TN_pre/(TN_pre + FP_pre);
    specificity_post = TN_post/(TN_post + FP_post);

    if writing
        %destination_file = readtable(target_desc_file_name, 'Sheet','reader_study_results');
        row = reader + 1 + 7;
        destination_cell = "A" + num2str(row);
        details = [sheet_name, count_fluids, count_solid, count_mixed, count_birads3, count_removed];
        results_pre = [TP_pre, TN_pre, FP_pre, FN_pre, sensitivity_pre, specificity_pre];
        results_post = [TP_post, TN_post, FP_post, FN_post, sensitivity_post, specificity_post];
        to_write = [details, results_pre, results_post];
        writematrix(to_write, target_desc_file_name, 'Sheet', 'reader_study_results', 'range', destination_cell);
    end
end