clc
clear
addpath('/Users/arunimasharma/Desktop/Work/JHU/Codes/utils');
addpath('E:/JHU/Backup/Breast Work/Reader_study/ReaderStudy/Codes/ultils');

set(0, 'defaultAxesFontSize', 20, 'defaultlineLineWidth', 2, 'defaultErrorBarLineWidth', 0.1);
c_map = [76, 109, 124;180, 200, 208; 33, 158, 188; 142, 202, 230;76, 133, 13;145, 200, 26;188, 110, 16; 239, 161, 67 ; 204, 151, 0; 255, 201, 54 ]/255;

location = '/Volumes/One Touch/JHU/Backup/Breast Work/Reader_study/ReaderStudy/';
location = 'E:/JHU/Backup/Breast Work/Reader_study/ReaderStudy/';
target_desc_file_name = fullfile([location 'patient_details_pc.xlsx']);
mass_details = readtable(target_desc_file_name, 'Sheet', 'mass_details');
%mass_details = readtable(target_desc_file_name, 'Sheet', 'mass_details-readerstudy');
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


%Positive for cyst detection - means
% Cysy identified as cyst - TP
% Cyst identified as solid - FN
% Solid identified as cyst - FP
% Solid identified as solid - TN

num_fluid = num_simplecysts + num_complicatedcysts;
num_solid = num_benignsolids + num_highrisk + num_malignantsolids;
%threshold = 0.73;
count = 0;
for threshold = 0:0.01:1
    [TP_bmode, FP_bmode, TN_bmode, FN_bmode, TP_slsc, FP_slsc, TN_slsc, FN_slsc] = deal(0);
    count = count + 1;
    th(count) = threshold;
    num_notused = 0;
    for idx = 1:length(sorted_idx)
        %if categories(idx) == "Simple Cysts" || categories(idx) == "Complicated Cysts"
        if categories(idx) == "Complicated Cysts"
            if values_sortedmasses(idx, 1) >=threshold
                TP_bmode = TP_bmode + 1;
            else
                FN_bmode = FN_bmode + 1;
            end
            if values_sortedmasses(idx, 2)>= threshold
                TP_slsc = TP_slsc+1;
            else
                FN_slsc = FN_slsc +1;
            end
        elseif categories(idx) == "Benign Solid" || categories(idx) == "High Risk" || categories(idx) == "Malignant Solid"
            if values_sortedmasses(idx, 1)< threshold
                TN_bmode = TN_bmode + 1;
            else
                FP_bmode = FP_bmode + 1;
            end
            if values_sortedmasses(idx, 2)< threshold
                TN_slsc = TN_slsc+1;
            else
                FP_slsc = FP_slsc +1;
            end
        else
            num_notused = num_notused +1;
        end
    end

    Sensitivity_bmode(count) = TP_bmode/(TP_bmode + FN_bmode);
    Sensitivity_slsc(count) = TP_slsc/(TP_slsc + FN_slsc);

    Specificity_bmode(count) = TN_bmode/(TN_bmode+ FP_bmode);
    Specificity_slsc(count) = TN_slsc/(TN_slsc + FP_slsc);
end

figure, hold on
plot(th, Sensitivity_bmode);
plot(th, Sensitivity_slsc);
xlabel("Threshold");
ylabel("Sensitivity");
plot(0.73, Sensitivity_bmode(73), 'Marker','o', 'MarkerFaceColor','k', 'Color','k', 'MarkerSize',9)
plot(0.73, Sensitivity_slsc(73), 'Marker','o', 'MarkerFaceColor','k', 'Color','k', 'MarkerSize',9)
legend("B-mode", "SLSC");

figure, hold on
plot(th, Specificity_bmode);
plot(th, Specificity_slsc);
xlabel("Threshold");
ylabel("Specificity");
plot(0.73, Specificity_bmode(73), 'Marker','o', 'MarkerFaceColor','k', 'Color','k', 'MarkerSize',9)
plot(0.73, Specificity_slsc(73), 'Marker','o', 'MarkerFaceColor','k', 'Color','k', 'MarkerSize',9)
legend("B-mode", "SLSC");

figure, hold on
plot(1-Specificity_bmode, Sensitivity_bmode);
plot(1-Specificity_slsc, Sensitivity_slsc);
xlabel("1-Specificity");
ylabel("Sensitivity");
aoc_bmode = trapz(Specificity_bmode, Sensitivity_bmode);
aoc_slsc = trapz(Specificity_slsc, Sensitivity_slsc);


%%%Below are the values for simple + complicated cysts
% sensitivity_pre = [0.708333
% 0.666667
% 0.5
% 0.958333
% 0.75
% 0.791667];
% 
% specificty_pre = [0.936709
% 0.759494
% 1
% 0.746835
% 0.911392
% 0.810127];
% 
% sensitivity_post = [0.75
% 0.958333
% 0.708333
% 1
% 0.625
% 0.75];
% 
% specificity_post = [0.911392
% 0.708861
% 0.987342
% 0.721519
% 0.911392
% 0.848101];

%Below are the values for complicated cysts
% sensitivity_pre = [0.583333
% 0.583333
% 0.416667
% 0.916667
% 0.666667
% 0.75];
% 
% specificty_pre = [0.936709
% 0.759494
% 1
% 0.746835
% 0.911392
% 0.810127];
% 
% sensitivity_post = [0.583333
% 0.916667
% 0.666667
% 1
% 0.666667
% 0.75];
% 
% specificity_post = [0.911392
% 0.708861
% 0.987342
% 0.721519
% 0.911392
% 0.848101];


%%Below are the values for ONLY complicated cysts and content detection:
% 81 solid masses and 13 complicated cysts
% sensitivity_pre = [0.461538462
% 0.538461538
% 0.692307692
% 0.769230769
% 0.615384615
% 0.692307692];

%80 solid (including the one malignant mixed)  and 13 complicated cysts
sensitivity_pre = [0.461538462
0.538461538
0.692307692
0.769230769
0.615384615
0.692307692;]

% specificty_pre = [0.814814815
% 0.518518519
% 0.814814815
% 0.543209877
% 0.740740741
% 0.75308642];

specificty_pre = [0.825
0.5375
0.825
0.55
0.75
0.7625]; 

% sensitivity_post = [0.538461538
% 0.923076923
% 0.769230769
% 1
% 0.615384615
% 0.846153846];

sensitivity_post = [0.538461538
0.923076923
0.769230769
1
0.615384615
0.846153846];

% specificity_post = [0.777777778
% 0.604938272
% 0.851851852
% 0.543209877
% 0.777777778
% 0.555555556];

specificity_post = [0.7875
0.625
0.8625
0.55
0.7875
0.5625];


plot(1-specificty_pre, sensitivity_pre, 'Marker', 'x', 'MarkerSize',10, 'Color','#0072BD', 'LineStyle','none');
plot(1-specificity_post, sensitivity_post, 'Marker','o', 'MarkerSize',10, 'Color', '#D95319', 'LineStyle','none')

legend("B-mode, gCNR", "SLSC, gCNR", 'B-mode, reader', 'SLSC, reader', 'Location','southeast');
xlim([-0.05, 1.05]);
ylim([0, 1.05]);
box;

x = categorical({'B-mode', 'SLSC'});
y = [aoc_bmode, aoc_slsc];
figure, 
b = bar(x, y)
b.FaceColor = 'flat'%[0.8500, 0.3250, 0.0980];
b.CData(2, :) = [0.8500, 0.3250, 0.0980];



