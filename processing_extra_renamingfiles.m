%location = 'Y:\breast_beamformed_data\Processed'
location = 'D:\Arunima\Work\ReaderStudy\Data\Processed'
folders = dir(location);
folder_names = {folders(3:end).name};
num_masses = length(folder_names);
name_modified = strings(1, num_masses);
cd(location)
for i = 1:num_masses
    name = cell2mat(folder_names(i))
    len_massname = size(name, 2);
    if len_massname == 8
        name_modified(i) = [name(1) + "00" + name(2:end)];
        movefile(name, name_modified(i));
    elseif len_massname == 9
        name_modified(i) = [name(1) + "0" + name(2:end)];
        movefile(name, name_modified(i));
    else
        name_modified(i) = name;
    end
end
