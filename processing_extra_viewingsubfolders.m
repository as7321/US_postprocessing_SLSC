location = 'D:\Arunima\Work\ReaderStudy\Data\Processed\';
folders = dir(location);
folders = folders(3:end);

for i = 1:length(folders)
    mass_num = folders(i);
    mass_name = mass_num.name
    complete_path = [location mass_name];
    cd(complete_path)
    ls *.mat
    pause
end