%%% This function is used to get the coherence functions of a given region
%%% (target and background). 
%%% Inputs: coherence matrix - (axial points * scan lines * lags), 
%%% mask_t - [axial points * scan lines - logical] calculated from extractROI function
%%% mask_b - [axial points * scan lines - logical] calculated from extractROI function
%%% Outputs: target - coherence function (1*64) of all points present in tatget
%%%          background - coherence function of all points present in tissue


function [target_3d, background_3d] = getRoiSLSC(slsc, mask_t, mask_b)

count_t = 1;
count_b = 1;

for ax = 1:size(slsc, 1)
    for lat = 1:size(slsc, 2)
        if mask_t(ax, lat)
            target_3d(count_t, :) = slsc(ax, lat, 1);
            count_t = count_t + 1;
        end
        if mask_b(ax, lat)
            background_3d(count_b, :) = slsc(ax, lat, 1);
            count_b = count_b + 1;
        end
    end
end

