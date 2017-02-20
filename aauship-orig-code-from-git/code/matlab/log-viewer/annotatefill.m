function [ output_args ] = annotatefill( start, stop, description, min, max )
%ANNOTATEFILL Fills the areas
%   Make sure to use 'hold on' on the plot where you want to use the
%   annotatefill function to overlay the annotations, alternatively, plot
%   the annotatefills before to make them appear below your graph.
%
%   The arguments are:
%     annotatefill( start, stop, description, min, max )
%
%   Example usage:
%     annotatefile = fopen([logpath,testname,'/annotate1416836228.84.log'],'r');
%     annotate = textscan(annotatefile, '%f%f%s', 'Delimiter', ';');
%     annotatefill(annotate{1},annotate{2},annotate{3},-300,300)

    for ii = 1:length(start)
        fill([start(ii),...
              start(ii),...
              stop(ii),...
              stop(ii)],...
             [max min min max],'y','FaceAlpha', 0.5)
        text(start(ii),max,description(ii),'rotation',90);
    end

end

