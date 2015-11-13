function boldify(x,y,xshrnk,yshrnk)
%BOLDIFY Make lines and text bold for legible viewgraph plots.
%	BOLDIFY boldifies the lines and text of the current figure.
%	BOLDIFY(H) boldifies the graphics handle H. BOLDIFY recursively
%	boldifies all children as well.
%
%	BOLDIFY(X,Y) specifies an X-by-Y inch graph of the current figure.
%
%	BOLDIFY(X,Y,XS,YS) is a hack to handle MATLAB's kludgy output
%	mechanism -- for X and Y `small' (less than 5 inches or so),
%	MATLAB will clip the plot and/or its axes. The kludgy way to handle
%	this kludgy behavior is to shrink the vertical and horizontal
%	axes by the fractions XS and YS. E.g., `boldify(4,3,0.9,0.9)'
%	usually produces unclipped output. Note that this is only done
%	on the GCA -- for other axes, modify the code.

%	S. T. Smith <stsmith@ll.mit.edu>

% The name of this function does not represent an endorsement by the author
% of the egregious grammatical trend of verbing nouns.

if nargin == 1
   h = x;
else
   h = gcf;
   if nargin == 0
      set(gcf,'PaperPosition','default')
   end
end

if isempty(h), return, end	% bottom recursion

if nargin>=2	 % user specified graph size
   fsize = [x,y];
end

if exist('fsize') ~= 1
   set(gcf,'PaperUnits','inches')
   fsize = get(gcf,'PaperPosition');
   fsize = fsize(3:4);	 % figure size (X" x Y") on paper. 
end

% set the paper size if h is the current figure
if any(any(h == gcf))
   h = gcf;
   set(gcf,'PaperUnits','inches')
   psize = get(gcf,'PaperSize');
   set(gcf,'PaperPosition', ...
[(psize(1)-fsize(1))/2 (psize(2)-fsize(2))/2 fsize(1) fsize(2)]);

   %!KLUDGE! Shrink the gca's horizontal and vertical dimensions a little to
   % avoid annoying clipping of plot and labels
   if exist('xshrnk') == 1 & exist('yshrnk') == 1
      asize = get(gca,'Position');	% axes position (normalized)
      set(gca,'Position',[asize(1)+(1-xshrnk)*asize(3) asize(2)+(1-yshrnk)*asize(4) xshrnk*asize(3) yshrnk*asize(4)])
   end
end

for k=1:length(h)
   htype = get(h(k),'Type');
   if strcmp(htype,'axes')
      set(h(k),'Units','normalized')
      asize = get(h(k),'Position');	% axes position (normalized)
      asize = asize(3:4);
      
      set(h(k),'FontSize',12);	 % 12-pt tick mark labels
      set(h(k),'FontWeight','bold');	% bold tick mark labels
      set(h(k),'LineWidth',1);	 % 1-pt axes and ticks

      % set tick mark length
      fp = get(gcf,'Position'); fp = fp(3:4);
      [temp,j] = max(asize.*fp);
      scale = fsize(j);	% scale*normalized units -> inches
      if scale > 0
set(h(k),'TickLength',[1/8 2.5*1/8]/scale)	% Gives 1/8" ticks
      end

      set(get(h(k),'XLabel'),'FontSize',14)	% 14-pt bold labels
      set(get(h(k),'XLabel'),'FontWeight','bold')
      set(get(h(k),'XLabel'),'VerticalAlignment','top')
      % Set top of X label 1/8" below tick labels.
      % Currently, there is no method to position the tick labels, so
      % this is left undone (except that the label is moved down 3 points).
      if 0	% MATLAB seems buggy about this, so just comment out
set(get(h(k),'XLabel'),'units','points')
xp = get(get(h(k),'XLabel'),'Position');
set(get(h(k),'XLabel'),'Position', xp - [0 3 0])
      end

      set(get(h(k),'YLabel'),'FontSize',14)	% 14-pt bold labels
      set(get(h(k),'YLabel'),'FontWeight','bold')
      set(get(h(k),'YLabel'),'VerticalAlignment','baseline')

      set(get(h(k),'ZLabel'),'FontSize',14)	% 14-pt bold labels
      set(get(h(k),'ZLabel'),'FontWeight','bold')
      set(get(h(k),'ZLabel'),'VerticalAlignment','baseline')

      set(get(h(k),'Title'),'FontSize',16)	% 16-pt bold titles
      set(get(h(k),'Title'),'FontWeight','bold')
   
   elseif strcmp(htype,'text')
      set(h(k),'FontSize',14);	 % 14-pt bold descriptive labels
      set(h(k),'FontWeight','bold');
   elseif strcmp(htype,'line')
      set(h(k),'LineWidth',2);
      if strcmp(get(h(k),'LineStyle'),'.')
         set(h(k),'MarkerSize',18);	 % 18-pt markers
      end
   end

   boldify(get(h(k),'Children'))	 % recurse on children
end
