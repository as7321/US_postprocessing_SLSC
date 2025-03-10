function [sorted_idx, num_purefluids, num_cysts, num_mixed, num_benignsolids,num_highrisk, num_solids, categories] = sort_masses_journal_readerstudy(result_file)

%%% Include and sort only Journal masses
num_files = size(result_file, 1);
y = 1:num_files;
n = 1;
idx_journal = [];
for idx = y
    if result_file.Include(result_file.idx==idx) == 1
       idx_journal(n) = idx;        
       n = n+1;
    end
end
n = 1;
sorted_idx = [];
%categories = [];
for idx = idx_journal
    if cell2mat(result_file.masstype(result_file.idx==idx)) == "Simple Cyst"
        sorted_idx(n) = idx;
        %idx_simplecyst = [idx_simplecyst idx];
        categories(n) = "Simple Cysts";
        n = n+1; 
    end
end
num_purefluids = n-1;
for idx = idx_journal
    if cell2mat(result_file.masstype(result_file.idx==idx)) == "Complicated Cyst"
        sorted_idx(n) = idx;
        %idx_complicatedcyst = [idx_complicatedcyst idx];
        categories(n) = "Complicated Cysts";
        n = n+1;
    end
end
num_cysts = n-1-num_purefluids;
for idx = idx_journal
    if cell2mat(result_file.masstype(result_file.idx==idx)) == "Mixed"
        sorted_idx(n) = idx;
        %idx_otherfluids = [idx_otherfluids idx];
        categories(n) = "Mixed";
        n = n+1;
    end
end
num_mixed = n-1-num_cysts-num_purefluids;
num_fluid = num_purefluids+num_cysts + num_mixed;
for idx = idx_journal
    if cell2mat(result_file.masstype(result_file.idx==idx)) == "Benign Solid"
        sorted_idx(n) = idx;
        %idx_benignsolids = [idx_benignsolids idx];
        categories(n) = "Benign Solid";
        n = n+1;
    end
end
num_benignsolids = n - num_fluid -1;

for idx = idx_journal
    if cell2mat(result_file.masstype(result_file.idx==idx)) == "High Risk"
        sorted_idx(n) = idx;
        %idx_malignantsolids = [idx_malignantsolids idx];
        categories(n) = "High Risk";
        n = n+1;
    end
end
num_highrisk = n -num_fluid- num_benignsolids - 1;
for idx = idx_journal
    if cell2mat(result_file.masstype(result_file.idx==idx)) == "Malignant Solid"
        sorted_idx(n) = idx;
        %idx_malignantsolids = [idx_malignantsolids idx];
        categories(n) = "Malignant Solid";
        n = n+1;
    end
end
num_solids = n-num_fluid-num_benignsolids-num_highrisk -1;