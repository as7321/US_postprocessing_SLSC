clc
location = 'D:\Arunima\Work\ReaderStudy\Data\Processed'
folders = dir(location);
folder_names = {folders(3:end).name};
breast_details_file_name = fullfile("D:\Arunima\Work\ReaderStudy\patient_details.xlsx");
breast_details = readtable(breast_details_file_name, 'Sheet', 'file_pathv02');
mass_details = readtable(breast_details_file_name, 'Sheet', 'mass_details');
num_masses = size(mass_details, 1);
for idx = 1:num_masses
    patient_num = cell2mat(breast_details.patient(breast_details.idx == idx));
    mass_num = cell2mat(breast_details.mass(breast_details.idx == idx));
    mass_to_be_saved = [patient_num '-' mass_num]
    disp(mass_details.mass_number(idx))
    disp(folder_names(idx))
end
