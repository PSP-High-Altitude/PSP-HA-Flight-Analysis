function animFUNC(transform, mat_in, filename, i, tdiff)
set(transform, 'Matrix', mat_in);
drawnow;
% exportgraphics(gca,filename,"Append",true);
% frame = getframe();
%     im = frame2im(frame);
%     [imind,cm] = rgb2ind(im,256);
%     if i == 1
%          imwrite(imind,cm,filename,'gif', 'Loopcount',inf);
%     else
%          imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime',tdiff);
%     end
end