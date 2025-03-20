function [data_arad, data_rad] = load_breast_data(path, idx)
if idx~=34 & idx~=36 & idx~=39 & idx~=70 & idx~=120
    data_rad = load([path '/Rad_img.mat']);
    data_arad = load([path '/Arad_img.mat']);
    data_arad.SLSC(data_arad.SLSC(:, :, :)<0) = 0;
    data_rad.SLSC(data_rad.SLSC(:, :, :)<0) = 0;
elseif idx == 34
    data_rad = load([path '/Rad_img.mat']);
    data_arad = load([path '/Rad_img.mat']);
    data_arad.SLSC(data_arad.SLSC(:, :, :)<0) = 0;
    data_rad.SLSC(data_rad.SLSC(:, :, :)<0) = 0;
elseif idx == 36
    data_rad = load([path '/Arad_img.mat']);
    data_arad = load([path '/Arad_img.mat']);
    data_arad.SLSC(data_arad.SLSC(:, :, :)<0) = 0;
    data_rad.SLSC(data_rad.SLSC(:, :, :)<0) = 0;
else
    data_rad = load([path '/Sag_img.mat']);
    data_arad = load([path '/Trans_img.mat']);
    data_arad.SLSC(data_arad.SLSC(:, :, :)<0) = 0;
    data_rad.SLSC(data_rad.SLSC(:, :, :)<0) = 0;
end
end