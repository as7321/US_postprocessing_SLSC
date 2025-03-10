clc
clear
addpath('/Users/arunimasharma/Desktop/Work/JHU/Codes/utils');
addpath('/Volumes/One Touch/JHU/Backup/Breast Work/Reader_study/ReaderStudy/Codes/ultils');

set(0, 'defaultAxesFontSize', 20, 'defaultlineLineWidth', 2, 'defaultErrorBarLineWidth', 0.1);
c_map = [76, 109, 124;180, 200, 208; 33, 158, 188; 142, 202, 230;76, 133, 13;145, 200, 26;188, 110, 16; 239, 161, 67 ; 204, 151, 0; 255, 201, 54 ]/255;
location = '/Volumes/One Touch/JHU/Backup/Breast Work/Reader_study/ReaderStudy/';
target_desc_file_name = fullfile([location 'patient_details_pc.xlsx']);
mass_details = readtable(target_desc_file_name, 'Sheet', 'mass_details');
metric = "LOC";
metric_file = readtable(target_desc_file_name, 'Sheet',metric);

num_files = size(metric_file, 1);
metric_vals_arad = [metric_file(:, [5,6])];
metric_vals_rad = [metric_file(:, [3,4])];
metric_vals_arad = metric_vals_arad{:, :};
metric_vals_rad = metric_vals_rad{:, :};

num_beamformers = size(metric_vals_arad, 2);
beamformer = ["Lesion"; "Background"];

[sorted_idx, num_simplecysts, num_complicatedcysts, num_mixed, num_benignsolids,num_highrisk, num_malignantsolids, categories] = sort_masses_journal_readerstudy(mass_details);
num_masses = length(sorted_idx);
category = reshape(repmat(categories, num_beamformers, 1), [num_masses*num_beamformers, 1]);
beamformer_array = repmat(beamformer, num_masses, 1);

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

metric_all = reshape(values_sortedmasses', [num_masses*num_beamformers, 1]);

figure, hold on
mass_distribution = categorical(category, ["Simple Cysts", "Complicated Cysts", "Mixed", "Benign Solid","High Risk", "Malignant Solid"], 'Ordinal',1)
beamformer_distribution = categorical(beamformer_array, [{'Lesion'},{'Background'}], 'Ordinal',1);
b = boxchart(mass_distribution, metric_all, 'GroupByColor', beamformer_distribution)
legend("Lesion", "Background");
box;
yline(0.28, LineStyle=":", LineWidth=1)
ylabel('Lag One Coherence')

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
yline(0.28, LineStyle=":", LineWidth=1);
ylabel('Lag One Coherence')
title('Scatter plot to show LOC distribution');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%