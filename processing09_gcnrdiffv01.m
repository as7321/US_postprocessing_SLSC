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

num_files = size(metric_file, 1);
metric_vals_arad = [metric_file(:, [3,5])];
metric_vals_rad = [metric_file(:, [4,6])];
metric_vals_arad = metric_vals_arad{:, :};
metric_vals_rad = metric_vals_rad{:, :};

num_beamformers = size(metric_vals_arad, 2);
beamformer = ["B-mode"; "SLSC"];

[sorted_idx, num_simplecysts, num_complicatedcysts, num_mixed, num_benignsolids,num_highrisk, num_malignantsolids, categories] = sort_masses_journal_readerstudy(mass_details);
num_masses = length(sorted_idx);
category = reshape(repmat(categories, num_beamformers, 1), [num_masses*num_beamformers, 1]);
beamformer_array = repmat(beamformer, num_masses, 1);

values_sortedmasses_arad = metric_vals_arad(sorted_idx, :);
values_sortedmasses_rad = metric_vals_rad(sorted_idx, :);


values_sortedmasses = zeros(num_masses, num_beamformers);
orientation_preference = strings(num_masses, 1);

num_fluid = num_simplecysts + num_complicatedcysts;
for idx = 1:num_fluid
    if values_sortedmasses_rad(idx,2)> values_sortedmasses_arad(idx,2)
       values_sortedmasses(idx, :) = values_sortedmasses_rad(idx,:);
       orientation_preference(idx) = 'Rad';
    else
        values_sortedmasses(idx, :) = values_sortedmasses_arad(idx,:);
        orientation_preference(idx) = 'Arad';
    end
end

for idx = num_fluid+1:num_masses
    if values_sortedmasses_rad(idx,2)> values_sortedmasses_arad(idx,2)
        values_sortedmasses(idx, :) = values_sortedmasses_arad(idx,:);
        orientation_preference(idx) = 'Arad';
    else
        values_sortedmasses(idx, :) = values_sortedmasses_rad(idx,:);
        orientation_preference(idx) = 'Rad';
    end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

metric_all = reshape(values_sortedmasses', [num_masses*num_beamformers, 1]);

figure, hold on
mass_distribution = categorical(category, ["Simple Cysts", "Complicated Cysts", "Mixed", "Benign Solid","High Risk", "Malignant Solid"], 'Ordinal',1)
beamformer_distribution = categorical(beamformer_array, [{'B-mode'},{'SLSC'}], 'Ordinal',1);
b = boxchart(mass_distribution, metric_all, 'GroupByColor', beamformer_distribution)
legend;
box;
yline(0.73, LineStyle=":", LineWidth=1)
ylabel('gCNR')

annotation('rectangle',...
    [0.389194444444445 0.111896348645464 0.127472222222222 0.812720848056536],...
    'Color','none',...
    'FaceColor',[0.901960784313726 0.901960784313726 0.901960784313726],...
    'FaceAlpha',0.3);

% Create rectangle
annotation('rectangle',...
    [0.647527777777779 0.110718492343934 0.127472222222222 0.812720848056536],...
    'Color','none',...
    'FaceColor',[0.901960784313726 0.901960784313726 0.901960784313726],...
    'FaceAlpha',0.3);

% Create rectangle
annotation('rectangle',...
    [0.130861111111111 0.110718492343934 0.127472222222222 0.812720848056537],...
    'Color','none',...
    'FaceColor',[0.901960784313726 0.901960784313726 0.901960784313726],...
    'FaceAlpha',0.3);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


for idx = 1:num_beamformers
    simplecysts{:, idx} = values_sortedmasses(1:num_simplecysts, idx);
    complicatedcysts{:, idx} = values_sortedmasses(num_simplecysts+1:num_simplecysts + num_complicatedcysts, idx);
    mixed{:, idx} = values_sortedmasses(num_simplecysts+num_complicatedcysts+1:num_simplecysts + num_complicatedcysts+num_mixed, idx);
    benignsolids{:, idx} = values_sortedmasses(num_simplecysts + num_complicatedcysts + num_mixed +1:num_simplecysts + num_complicatedcysts + num_mixed+num_benignsolids, idx);
    highrisk{:,idx} = values_sortedmasses(num_masses-num_highrisk-num_malignantsolids + 1:num_masses-num_malignantsolids, idx);
    malignantsolids{:, idx} = values_sortedmasses(num_masses-num_malignantsolids+1:num_masses, idx);
end

figure, hold on
for i = 1:num_beamformers
    scatter(i, simplecysts{:, i}, 30, c_map(i+3, :), 'filled');
    scatter(i+num_beamformers, complicatedcysts{:, i}, 30, c_map(i+3, :), 'filled');
    scatter(i+num_beamformers*2, mixed{:, i}, 30, c_map(i+3, :), 'filled');
    scatter(i+num_beamformers*3, benignsolids{:, i}, 30, c_map(i+3, :), 'filled');
    scatter(i+num_beamformers*4, highrisk{:, i}, 30, c_map(i+3, :), 'filled');
    scatter(i+num_beamformers*5, malignantsolids{:, i}, 30, c_map(i+3, :), 'filled');
end
yline(0.73, LineStyle=":", LineWidth=1);
ylabel('gCNR')
title('Scatter plot to show the gCNR distribution');


check_orientation = strings(159, 1);
for i = 1:159
if(any(sorted_idx(:)==i))
check_orientation(i, 1) = orientation_preference(sorted_idx==i);
else
check_orientation(i, 1) = 'NA';
end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
value_diff_sortedmasses = values_sortedmasses(:, 1) - values_sortedmasses(:, 2);
num_beamformers = 1;
beamformer = ["SLSC"]
metric_all = reshape(value_diff_sortedmasses', [num_masses*num_beamformers, 1]);

category = reshape(repmat(categories, num_beamformers, 1), [num_masses*num_beamformers, 1]);
beamformer_array = repmat(beamformer, num_masses, 1);
mass_content = [repmat("Fluid",1, num_fluid), repmat("Mixed", 1, num_mixed), repmat("Solid",1, num_benignsolids+num_highrisk+num_malignantsolids)];

figure, hold on
mass_distribution = categorical(category, ["Simple Cysts", "Complicated Cysts", "Mixed", "Benign Solid","High Risk", "Malignant Solid"], 'Ordinal',1)
beamformer_distribution = categorical(beamformer_array, [{'SLSC'}], 'Ordinal',1);
content_distribution = categorical(mass_content, [{'Simple Cyst'}, {'Compl'}, {'Mixed'}, {'Solid'}], 'Ordinal',1);
b = boxchart(mass_distribution, metric_all)% 'GroupByColor',mass_distribution)
%legend
box;
yline(0, LineStyle=":", LineWidth=1)
ylabel('gCNR Difference')
%b(3).SeriesIndex = 5;
%b(2).SeriesIndex = 6;
values_sortedmasses = value_diff_sortedmasses;

for idx = 1:num_beamformers
    simplecysts{:, idx} = values_sortedmasses(1:num_simplecysts, idx);
    complicatedcysts{:, idx} = values_sortedmasses(num_simplecysts+1:num_simplecysts + num_complicatedcysts, idx);
    mixed{:, idx} = values_sortedmasses(num_simplecysts+num_complicatedcysts+1:num_simplecysts + num_complicatedcysts+num_mixed, idx);
    benignsolids{:, idx} = values_sortedmasses(num_simplecysts + num_complicatedcysts + num_mixed +1:num_simplecysts + num_complicatedcysts + num_mixed+num_benignsolids, idx);
    highrisk{:,idx} = values_sortedmasses(num_masses-num_highrisk-num_malignantsolids + 1:num_masses-num_malignantsolids, idx);
    malignantsolids{:, idx} = values_sortedmasses(num_masses-num_malignantsolids+1:num_masses, idx);
end

figure, hold on
for i = 1:num_beamformers
    scatter(i, simplecysts{:, i}, 30, c_map(i+3, :), 'filled');
    scatter(i+num_beamformers, complicatedcysts{:, i}, 30, c_map(i+3, :), 'filled');
    scatter(i+num_beamformers*2, mixed{:, i}, 30, c_map(i+3, :), 'filled');
    scatter(i+num_beamformers*3, benignsolids{:, i}, 30, c_map(i+3, :), 'filled');
    scatter(i+num_beamformers*4, highrisk{:, i}, 30, c_map(i+3, :), 'filled');
    scatter(i+num_beamformers*5, malignantsolids{:, i}, 30, c_map(i+3, :), 'filled');
end
xlim([0, 7]);