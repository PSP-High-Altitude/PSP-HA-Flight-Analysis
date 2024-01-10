function animFUNC(transform, mat_in, filename, i, tdiff, save_file)
set(transform, 'Matrix', mat_in);
drawnow;
% exportgraphics(gca,filename,"Append",true);
frame = getframe();
if save_file == 1
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    fprintf("Writing frame {%d}... \n", i)
    if i == 1
         imwrite(imind,cm,filename,'gif', 'Loopcount',inf);
    else
         imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime',tdiff);
    end
end
end