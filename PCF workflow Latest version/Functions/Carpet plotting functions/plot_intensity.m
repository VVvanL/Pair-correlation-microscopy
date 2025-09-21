function plot_intensity(Images,FileName,smoothing, pdfFileName, pdf)
    
    num_images = length(Images);  % Get the number of averaged matrices

    % Create a cell array to store the figures
    figures = cell(num_images, 1);

    for i = 1:num_images

        if smoothing % if true we will apply some smoothing to the entire intenisty carpet
            image_data = Smoothing(Images{i},2,0.9,size(Images{i},2));
        
        else 
            image_data = Images{i};  % Get the averaged matrix
        
        end 

        % Create a figure for visualization
        figures{i} = figure;
        % Display the matrix using imagesc with 'jet' colormap
        imagesc(image_data);
        h = gca; %
        h.XAxis.MinorTick = 'on'; 
        % Add title and labels as needed
        graph_title = FileName{1,i};
        gnewtitle = regexprep(graph_title, '\.tif$', '');
        gnewtitle = regexprep(gnewtitle, '_', '');
        title([gnewtitle]);
        xlabel('Pixels');
        ylabel('Time');

        % Set colormap to 'jet'
        colormap jet;
      
    end 

    % Save the figures to the PDF file if needed
    if pdf
        pdf_filename = [pdfFileName, '.pdf'];
        for i = 1:num_images
            % Save the figure in the existing PDF
            ax = get(figures{i}, 'CurrentAxes');
            exportgraphics(ax, pdf_filename, 'Append', true);
            
        end
    end
end

