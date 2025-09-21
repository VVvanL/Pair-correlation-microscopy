function plot_ACF_carpets(ACF_carpet)

for i = 1:numel(ACF_carpet)
    corrResult = ACF_carpet{i};
    
    % Plot the data in each cell
    figure;
    imagesc(corrResult);
    colormap(jet);
    colorbar();
    title(['Data in Cell ', num2str(i)]);
end

end