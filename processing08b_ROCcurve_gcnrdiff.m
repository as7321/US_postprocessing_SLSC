clc
clear
addpath('/Users/arunimasharma/Desktop/Work/JHU/Codes/utils');
addpath('/Volumes/One Touch/JHU/Backup/Breast Work/Reader_study/ReaderStudy/Codes/ultils');

set(0, 'defaultAxesFontSize', 20, 'defaultlineLineWidth', 2, 'defaultErrorBarLineWidth', 0.1);
c_map = [76, 109, 124;180, 200, 208; 33, 158, 188; 142, 202, 230;76, 133, 13;145, 200, 26;188, 110, 16; 239, 161, 67 ; 204, 151, 0; 255, 201, 54 ]/255;

location = '/Volumes/One Touch/JHU/Backup/Breast Work/Reader_study/ReaderStudy/';
target_desc_file_name = fullfile([location 'patient_details_pc.xlsx']);
mass_details = readtable(target_desc_file_name, 'Sheet', 'mass_details');
metric = "gCNR";
metric_file = readtable(target_desc_file_name, 'Sheet',metric);
metric_vals_arad = [metric_file(:, [3,5])];
metric_vals_rad = [metric_file(:, [4,6])];
metric_vals_arad = metric_vals_arad{:, :};
metric_vals_rad = metric_vals_rad{:, :};

[sorted_idx, num_simplecysts, num_complicatedcysts, num_mixed, num_benignsolids,num_highrisk, num_malignantsolids, categories] = sort_masses_journal_readerstudy(mass_details);
num_masses = length(sorted_idx);
num_beamformers = 2;

values_sortedmasses_arad = metric_vals_arad(sorted_idx, :);
values_sortedmasses_rad = metric_vals_rad(sorted_idx, :);
values_sortedmasses = zeros(num_masses, num_beamformers);

for mass = 1:num_masses
    idx = sorted_idx(mass);
    if strcmp(cell2mat(mass_details.Orientation(mass_details.idx==idx)), 'Rad')
        values_sortedmasses(mass, :) = values_sortedmasses_rad(mass,:);
    elseif strcmp(cell2mat(mass_details.Orientation(mass_details.idx==idx)), 'Arad')
        values_sortedmasses(mass, :) = values_sortedmasses_arad(mass,:);
    else
        display("Orientation not given idx =" + idx);
    end
end
values_diff_sortedmasses = values_sortedmasses(:, 1) - values_sortedmasses(:, 2);

%Positive for cyst detection - means
% Cysy identified as cyst - TP
% Cyst identified as solid - FN
% Solid identified as cyst - FP
% Solid identified as solid - TN

num_fluid = num_simplecysts + num_complicatedcysts;
num_solid = num_benignsolids + num_highrisk + num_malignantsolids;
%threshold = 0.73;
count = 0;
for threshold = min(values_diff_sortedmasses)-0.05:0.01:max(values_diff_sortedmasses)+0.05
    [TP_bmode, FP_bmode, TN_bmode, FN_bmode, TP_slsc, FP_slsc, TN_slsc, FN_slsc] = deal(0);
    count = count + 1;
    th(count) = threshold;
    num_notused = 0;
    for idx = 1:length(sorted_idx)
        %if categories(idx) == "Simple Cysts" || categories(idx) == "Complicated Cysts"
        if categories(idx) == "Complicated Cysts"
            if values_diff_sortedmasses(idx)<= threshold
                TP_slsc = TP_slsc+1;
            else
                FN_slsc = FN_slsc +1;
            end
        elseif categories(idx) == "Benign Solid" || categories(idx) == "High Risk" || categories(idx) == "Malignant Solid"
            if values_diff_sortedmasses(idx)> threshold
                TN_slsc = TN_slsc+1;
            else
                FP_slsc = FP_slsc +1;
            end
        else
            num_notused = num_notused +1;
        end
    end

    Sensitivity_slsc(count) = TP_slsc/(TP_slsc + FN_slsc);
    Specificity_slsc(count) = TN_slsc/(TN_slsc + FP_slsc);
end

figure, hold on
plot(th, Sensitivity_slsc);
xlabel("Threshold");
ylabel("Sensitivity");
%plot(0.73, Sensitivity_bmode(73), 'Marker','o', 'MarkerFaceColor','k', 'Color','k', 'MarkerSize',9)
%plot(0.73, Sensitivity_slsc(73), 'Marker','o', 'MarkerFaceColor','k', 'Color','k', 'MarkerSize',9)
title("Sensitivity of gCNR diffference");

figure, hold on
plot(th, Specificity_slsc);
xlabel("Threshold");
ylabel("Specificity");
%plot(0.73, Specificity_bmode(73), 'Marker','o', 'MarkerFaceColor','k', 'Color','k', 'MarkerSize',9)
%plot(0.73, Specificity_slsc(73), 'Marker','o', 'MarkerFaceColor','k', 'Color','k', 'MarkerSize',9)
title("Specificity of gCNR diffference");

figure, hold on
plot(1-Specificity_slsc, Sensitivity_slsc);
plot([0:0.1:1], [0:0.1:1], LineStyle="--")
xlabel("1-Specificity");
ylabel("Sensitivity");
title("ROC curve of gCNR diffference");
