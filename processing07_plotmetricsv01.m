addpath('/Volumes/One Touch/JHU/Backup/Breast Work/Reader_study/ReaderStudy/Codes/ultils')
location = '/Volumes/One Touch/JHU/Backup/Breast Work/Reader_study/ReaderStudy/';
target_desc_file_name = fullfile([location 'patient_details_pc.xlsx']);
mass_details = readtable(target_desc_file_name, 'Sheet', 'mass_details');
metric = "gCNR";
metric_file = readtable(target_desc_file_name, 'Sheet',metric);

num_files = size(metric_file, 1);
y = 1:num_files;
metric_vals = [metric_file(:, 3:4)];
metric_vals = metric_vals{:, :};
num_beamformers = size(metric_vals, 2);
beamformer = ["B-mode"; "SLSC"];

[sorted_idx, num_purefluids, num_cysts, num_benignsolids, num_malignantsolids, categories] = sort_masses_journal_readerstudy(mass_details);
num_masses = length(sorted_idx);